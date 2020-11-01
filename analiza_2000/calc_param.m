%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			PARÁMETROS DE RADIACIÓN. 
%
% 			Manuel Sierra Castañer. 
%			Noviembre 2000.
%           Corregido y ampliado con todos los parámetros en agosto 2012.
%
%			Función que calcula los distintos parámetros
%			de radiación de la antena
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[Parametros]=calc_param(datos,sondas,ranuras,cortos,puntos,Vr,Ir,Vs,Is,E,Hx,Hy)

	frec=datos(1,4);
	h=datos(1,1);
	eps=datos(1,3);
    etag=120*pi/sqrt(eps);
    lamb0=299.792/frec;
    lambg=299.792/frec/sqrt(eps);
    npun=datos(2,4);
    nson=datos(2,1);

    % Cálculo del área de la antena en mm^2
    if datos(2,2)>9, % Solo en el caso en el que hay más de 10 ranuras. Si no se considera de prueba.
        circulo=[cortos; cortos(1,:)];
        circ=[sqrt(circulo(:,1).^2+circulo(:,2).^2) unwrap(atan2(circulo(:,2),circulo(:,1)))];
        area=abs(trapz(circ(:,2),(circ(:,1).^2)/2));
        Dirmax=10*log10(4*pi/(lamb0^2)*area);
    else
        area=0.5;
    end
    
    
    % Cálculo de las potencias
	if (datos(2,1)~=0),
      % Potencia disponible en la sonda
       Pdis=sum((sondas(:,5).^2)./real(sondas(:,7)))/8.0;
       Pin=0;
    for ns=1:nson,
        if (sondas(ns,5)~=0),
            Pin=Pin+0.5*real((conj(Vs(ns)).*Is(ns)));
        end
    end

   end
  
   if (datos(2,2)~=0),
      % Potencia radiada calculada como suma de potencias en ranuras
      % Esto supone que el modelo de método de los momentos tiene que ser
      % bueno, porque se está usando la matriz de acoplos calculada.
      % Mientras no estemos seguros, no vamos a utilizarlo, sino que nos
      % basaremos en la integración del campo radiado (es más exacto,
      % aunque más costoso computacionalmente)
      Prad=-.5*real(Ir'*Vr);
   end
   if (datos(2,1)~=0),
      % Coeficiente de reflexión
      Parametros(1,1)=10*log10(1-Pin/Pdis);
   else
      Parametros(1,1)=-1;
   end
   
    % Potencia residual en la antena version corregida 2012
    % Calculado mediante integración en una curva cerrada (comprobado)
    puntos2=[puntos; puntos(1,:)];
    phi_puntos=unwrap(atan2(puntos2(:,2),puntos2(:,1)));
    ro_puntos=sqrt(puntos2(:,1).^2+puntos2(:,2).^2);
    Sy=E.*conj(Hx);
    Sy=[Sy; Sy(1)];
    Sx=-E.*conj(Hy);
    Sx=[Sx; Sx(1)];
    Ppun=h/2*real(trapz(phi_puntos,ro_puntos.*(Sy.*sin(phi_puntos)+Sx.*cos(phi_puntos))));
    Prad3=Pin-Ppun;
    
   % Directividad
   if (datos(2,2)~=0),
       % Prad y directividad mediante integración diagrama
       % Ojo: se calcula con el número de ángulos definidos en opciones
       % Prefiero la versión de integración en ranuras
	   [Parametros(1,2),Prad2]=calc_dir(datos,ranuras,Vr.',Ir.');
       Dir=Parametros(1,2);
       Prad2;
       if (datos(2,2)>9), % Solo lo hemos calculado si hay más de 10 ranuras.
            Ef_apertura=100*10^((Dir-Dirmax)/10);
       end
   else
		Parametros(1,2)=-1;
   end
   if ((datos(2,2)==0)||(datos(2,1)==0)), 
		Parametros(1,4)=-1;
   else
        % Eficiencia de radiación en % 
        % Esta eficiencia es la potencia que radian las ranuras dividida
        % por la potencia incidente. Pero no tiene que ver con las pérdidas
        % sino con lo que llegaría al final de la guía al cortocircuito.
        % Asumimos que esa parte no se va a radiar bien.
        % La potencia radiada se obtiene como la de entrada menos la que 
        % que llega al final.
		Parametros(1,4)=Prad3/Pin*100; 
   end

    % Ganancia
	if (Parametros(1,2)~=-1),
		Parametros(1,3)=Parametros(1,2)+10*log10(Parametros(1,4)/100);
	else
		Parametros(1,3)=-1;
    end

   % Eficiencia total de antena en %
   if (Parametros(1,4)~=-1&& datos(2,2)>9),
      Parametros(1,4)=Parametros(1,4)*Pin/Pdis*(Ef_apertura/100);
   end
   % Presentación de datos final
   if (datos(2,2)~=0),
       frecuencia=frec;
       Coeficiente_reflexion=Parametros(1,1);
       if (datos(2,2)>9), % Solo lo hemos calculado si hay más de 10 ranuras.
            Directividad_por_area=Dirmax;
       end
       Directividad=Dir;
       Ganancia=Parametros(1,3);
       Pot_disponible=Pdis;
       Pot_entregada=Pin;
       Pot_radiada_ranuras=Prad;
       Pot_radiada_integ_diagrama=Prad2;
       Pot_radiada_puntos=Prad3;
       Pot_residual=Ppun;
       Eficiencia_reflex=Pin/Pdis*100;
       if (datos(2,2)>9), % Solo lo hemos calculado si hay más de 10 ranuras.
            Eficiencia_apertura=Ef_apertura;
       end
       Eficiencia_radiacion=Prad3/Pin*100;
       Pot_rad_rel=Prad/Pin;
       Pot_rad_diag_rel=Prad2/Pin;
       Ratio_pot_rad=Pot_rad_rel/Pot_rad_diag_rel;
       Pot_residual_rel=Ppun/Pin;
       Balance_ranuras=1-Pot_rad_rel-Pot_residual_rel;
       Balance_diagrama=1-Pot_rad_diag_rel-Pot_residual_rel;
       
   end
       
       