%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			PAR�METROS DE RADIACI�N. 
%
% 			Manuel Sierra Casta�er. 
%			Noviembre 2000.
%           Corregido y ampliado con todos los par�metros en agosto 2012.
%
%			Funci�n que calcula los distintos par�metros
%			de radiaci�n de la antena
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

    % C�lculo del �rea de la antena en mm^2
    if datos(2,2)>9, % Solo en el caso en el que hay m�s de 10 ranuras. Si no se considera de prueba.
        circulo=[cortos; cortos(1,:)];
        circ=[sqrt(circulo(:,1).^2+circulo(:,2).^2) unwrap(atan2(circulo(:,2),circulo(:,1)))];
        area=abs(trapz(circ(:,2),(circ(:,1).^2)/2));
        Dirmax=10*log10(4*pi/(lamb0^2)*area);
    else
        area=0.5;
    end
    
    
    % C�lculo de las potencias
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
      % Esto supone que el modelo de m�todo de los momentos tiene que ser
      % bueno, porque se est� usando la matriz de acoplos calculada.
      % Mientras no estemos seguros, no vamos a utilizarlo, sino que nos
      % basaremos en la integraci�n del campo radiado (es m�s exacto,
      % aunque m�s costoso computacionalmente)
      Prad=-.5*real(Ir'*Vr);
   end
   if (datos(2,1)~=0),
      % Coeficiente de reflexi�n
      Parametros(1,1)=10*log10(1-Pin/Pdis);
   else
      Parametros(1,1)=-1;
   end
   
    % Potencia residual en la antena version corregida 2012
    % Calculado mediante integraci�n en una curva cerrada (comprobado)
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
       % Prad y directividad mediante integraci�n diagrama
       % Ojo: se calcula con el n�mero de �ngulos definidos en opciones
       % Prefiero la versi�n de integraci�n en ranuras
	   [Parametros(1,2),Prad2]=calc_dir(datos,ranuras,Vr.',Ir.');
       Dir=Parametros(1,2);
       Prad2;
       if (datos(2,2)>9), % Solo lo hemos calculado si hay m�s de 10 ranuras.
            Ef_apertura=100*10^((Dir-Dirmax)/10);
       end
   else
		Parametros(1,2)=-1;
   end
   if ((datos(2,2)==0)||(datos(2,1)==0)), 
		Parametros(1,4)=-1;
   else
        % Eficiencia de radiaci�n en % 
        % Esta eficiencia es la potencia que radian las ranuras dividida
        % por la potencia incidente. Pero no tiene que ver con las p�rdidas
        % sino con lo que llegar�a al final de la gu�a al cortocircuito.
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
   % Presentaci�n de datos final
   if (datos(2,2)~=0),
       frecuencia=frec;
       Coeficiente_reflexion=Parametros(1,1);
       if (datos(2,2)>9), % Solo lo hemos calculado si hay m�s de 10 ranuras.
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
       if (datos(2,2)>9), % Solo lo hemos calculado si hay m�s de 10 ranuras.
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
       
       