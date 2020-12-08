%			Analiza.m  29/9/98  Análisis a 1 frecuencia
%			Manuel Sierra Castañer
%
%		Parámetros de entrada:
%
%	
%  datos: contiene datos fijos de la estructura:
%	datos(1,1)=h(altura entre placas de la guía en mm),
%	datos(1,2)=t(grosor de la placa superior en mm),
%	datos(1,3)=epsilonr (Constante dieléctrica en la guía),
%	datos(1,4)=freq	 (frecuencia central en GHz),
%	datos(2,1)=nsondas (número de sondas de alimentación),
%	datos(2,2)=nran (número de ranuras de radiación),
%	datos(2,3)=nsc (número de cortos),
%	datos(2,4)=npuntos (número de puntos de medida),
%
%  ranuras(nran,5) que contiene los datos de las ranuras de radiación
%	ranuras(*,1)=xran (posición en cartesianas)
%	ranuras(*,2)=yran (posición en cartesianas)
% 	ranuras(*,3)=lran (longitud en mm).
%	ranuras(*,4)=wran (anchura en mm).
%	ranuras(*,5)=gran (inclinación respecto del eje x rad)
%
%  cortos(nsc,3) datos la posición de las sondas en cortocircuito.
%	cortos(*,1)=xcor (posición en cartesianas en mm)
%	cortos(*,2)=ycor (posición en cartesianas en mm)
%	cortos(*,3)=dcor (diametro del cortocircuito en mm)
%
%  sondas(nson,7) que contiene datos de las sondas de alimentación.
%	sondas(*,1)=xson (posición en cartesianas en mm)
%	sondas(*,2)=yson (posición en cartesianas en mm)
%	sondas(*,3)=lson (longitud de las sondas en mm)
%	sondas(*,4)=dson (diametro de las sondas en mm)
%	sondas(*,5)=mson (módulo de la tensión de alimentación)
%  sondas(*,6)=fson (fase de la tensión de alimentación rad)
%	sondas(*,7)=zson (impedancia equivalente del generador)
%
%  puntos(npun,2) datos de los puntos de prueba de campo eléctrico.
%	puntos(*,1)=xpun (posición en cartesianas)
%	puntos(*,2)=ypun (posición en cartesianas)
%
function[Vs,Is,Ic,Vr,Ir,E,Hx,Hy]=Analiza(datos,ranuras,cortos,sondas,puntos)

ranuras;
sondas;
puntos;
%
%  Salida
Vs=[];
Is=[];
Ic=[];
Vr=[];
Ir=[];
E=[];
Hx=[];
Hy=[];
% Indicadores de existencia de elementos
son=1-isempty(sondas);
rad=1-isempty(ranuras);
punt=1-isempty(puntos);
npun=datos(2,4)
if datos(2,3)==0, 
    fin=0;
else
    fin=1;
end

%
%
% Atención! No hay alimentación.
if (son==0),
  fprintf(1,'\nNo hay fuente de alimentación.\n');
  return;
end
%
% Captura de datos:
%
h=datos(1,1);
t=datos(1,2);
epsr=datos(1,3);
freqw=datos(1,4);
%
if (datos(2,3)==0),
    fin=0;
end
clear datos
%
% Longitudes y números de onda:
%
lamb0=299.792/freqw;
lambg=lamb0/sqrt(epsr);
k0=2*pi/lamb0;
kg=2*pi/lambg;
eta0=120*pi;
etag=eta0/sqrt(epsr);
%
% Datos de las ranuras de radiación:
%
if rad==1,
	p_ran=ranuras(:,1)+ 1i.*ranuras(:,2);	
	alpha=ranuras(:,5);     % (nran,1) inclinación respecto al eje X
	l=ranuras(:,3);         % (nran,1) longitud
	w=ranuras(:,4);
%
%	parámetros auxiliares del modelo de ranuras de radiación:
%
	[nran,aux]=size(ranuras);	% nº de ranuras de radiación
	epssup=0.4+0.6*epsr+0.21*(1-epsr)*sqrt(t./w);
	lambsup=lamb0./sqrt(epssup); %OK
	yosup=((2.93*t./w+4.77*sqrt((1+epsr)/2)-4.3.*log10(w))*1e-3);
	xdelta=(-1.73+8.39*exp(-3.53*t)+w*17.38*exp(-0.57*t));
	deltals=lambsup.*(atan(xdelta.*yosup))/pi;
	clear xdelta epssup w
%
else nran=0;
end
clear t ranuras
%
% Datos del cortocircuito:
%
[nsc,aux]=size(cortos);		% nº de cortos
if (fin==1),
	p_corto=cortos(:,1)+ 1i.*cortos(:,2); 	%(nsc,1) sondas en corto
	rcorto=cortos(:,3)/2.;
	rcorto=rcorto.';
   Zeq_corto=etag/(2*pi)*(.3817*(log(5.6726./rcorto))+(4.13e-3./rcorto)); %OK
   clear rcorto
else nsc=0;
end
clear cortos 
%
% Datos de las sondas de alimentación:
%
[nson,aux]=size(sondas);	% nº de sondas
if (son==1),
	p_son=sondas(:,1)+1i*sondas(:,2);	%(nson,1) sondas de alimentación
	lsonda=sondas(:,3);
	lsonda=lsonda.';
	rsonda=sondas(:,4)/2.;		
	rsonda=rsonda.';
	Rs=diag(sondas(:,7));
	Ct=(4.7+23.3*rsonda+1000/36*(rsonda.^2)./(h-lsonda)).*epsr;
	Zl=-1i*1e6./(2*pi*freqw*Ct);
	Cs=2*pi*epsr./log((1.142*rsonda+.038)./rsonda);
    Ls=100/9*epsr./Cs;
	Zeq_sonda=1000*sqrt(Ls./Cs);
	beta=2*pi/299.792*freqw*sqrt(epsr);
	alfa=.037-.0037*freqw*lsonda+.000116*(freqw*lsonda).^2-6.72e-7*(freqw*lsonda).^3;
	gamma=(alfa+1i*beta);
	dlsonda=299.792/sqrt(epsr)/(2*pi*freqw).*atan(2e-6*pi.*freqw*Zeq_sonda.*Ct);
    Vgs=sondas(:,5).*exp(1i*sondas(:,6));
    clear sondas Cs Ls Ct alfa beta freqw epsr rsonda
else Vgs=[];
   nson=0;
end

%
% parámetros de ajuste:
if(rad==1)
	coefHr=.66+.34*cos(kg*l/4); %OK
	coefY=0.72+0.28*cos(l*k0/4); %OK
end
%
%%% Obtención de los acoplos entre ranuras de radiación: (nran,nran)
if rad==1,
  ll=l*ones(1,nran);
  rorelat=p_ran*ones(1,nran)-ones(nran,1)*p_ran.';
  firelat=angle(-rorelat)-ones(nran,1)*alpha.';
  rorelat=abs(rorelat)*kg;
  rorelat=max(rorelat,realmin);
%
% Acoplos internos entre ranuras de radiación: (nran,nran)
  Hrr=cos(kg/2*ll.*cos(firelat)).*sin(firelat);
  Hrr=Hrr./(1-(kg/pi*ll.*cos(firelat)).^2);
  Hrr=Hrr.*(Hrr.').*sqrt(2./(pi*rorelat)).*(l*l.');
  Hrr=-Hrr.*exp(-1i*rorelat)*exp(1i*pi/4)*kg/(pi*pi*etag*h);	
  for n=1:nran,
     Hrr(n,n)=1/(etag*pi*lambg*h)*l(n)*l(n)*coefHr(n);   %OK 
  end
  clear coefHr
% 
% Acoplos externos entre ranuras: (nran,nran)
  rorelat=rorelat*k0/kg;
  Yrr=cos(k0/2*ll.*cos(firelat)).*sin(firelat);
  Yrr=Yrr./(1-(k0/pi*ll.*cos(firelat)).^2);
  Yrr=Yrr.*(Yrr.').*(l*l.')./rorelat;
  Yrr=-Yrr.*exp(-1i*rorelat)*4*1i*k0/(pi*pi*eta0*lamb0);	 
  for n=1:nran,
      Yrr(n,n)=4/(3*pi*eta0)*(2*l(n)/lamb0)^2*coefY(n);
  % Asocio la parte imaginaria a los acoplos externos:
      Yrr(n,n)=Yrr(n,n)-1i*2*yosup(n)/tan(pi/lambsup(n)*(l(n)+deltals(n))); 
  end
  %
  clear ll rorelat firelat coefY yosup lambsup deltals 
%
else Hrr=[];
     Yrr=[];
end
  
clear lambg lamb0 k0 eta0
%
% Obtención de los acoplos entre ranuras de radiación y corto: (nran,nsc)
if (fin==1 && rad==1),
  rorelat=p_ran*ones(1,nsc)-ones(nran,1)*p_corto.';
  firelat=angle(-rorelat)-alpha*ones(1,nsc);
  rorelat=abs(rorelat)*kg;
  rorelat=max(rorelat,realmin);
  ll=l*ones(1,nsc);
  Hrc=cos(kg/2*ll.*cos(firelat)).*sin(firelat).*sqrt(2./(pi*rorelat));
  Hrc=Hrc.*ll./(1-(kg/pi*ll.*cos(firelat)).^2).*exp(-1i*rorelat);
  Hrc=-Hrc*kg/(2*pi)*exp(1i*pi/4);
  clear rorelat firelat ll
else Hrc=[];
end
%
% Obtención de los acoplos mutuos entre cortos: (nsc,nsc)
if fin==1,
  rorelat=p_corto*ones(1,nsc)-ones(nsc,1)*p_corto.';
  rorelat=abs(rorelat)*kg;
  rorelat=max(rorelat,realmin);
  Hcc=-etag*kg*h/4*(sqrt(2./(pi*rorelat)).*exp(-1i*rorelat))*exp(1i*pi/4);
  for n=1:nsc,
	Hcc(n,n)=etag*kg*h/4+1i*2*Zeq_corto(n)*tan(kg*h/2);
  end
  clear rorelat Zeq_corto
else Hcc=[];
end;	%Fin de acoplos de cortocircuitos
%
if (son==1) 	%Análisis con sondas de alimentación
%	
% Obtención de acoplos entre sondas de alimentación:
%
Ga=(cosh(gamma.*dlsonda)-cosh(gamma.*(lsonda+dlsonda)))./sinh(gamma.*(lsonda+dlsonda));
% Acoplos mutuos
  rorelat=p_son*ones(1,nson)-ones(nson,1)*p_son.';
  rorelat=abs(rorelat)*kg;
  rorelat=max(rorelat,realmin);
  Hss=-(etag/(4*h*kg))*(Ga.'*Ga).*(sqrt(2./(pi*rorelat)).*exp(-1i*rorelat))*exp(1i*pi/4);
% Obtención de la impedancia de entrada (parte real como eq. potencias y parte img. como imp):
  for n=1:nson,
	 Zs=Zeq_sonda(n)*(Zl(n)*cosh(gamma(n)*lsonda(n))+Zeq_sonda(n)*sinh(gamma(n)*lsonda(n)));
	 Zs=Zs/(Zeq_sonda(n)*cosh(gamma(n)*lsonda(n))+Zl(n)*sinh(gamma(n)*lsonda(n)));
 	 Hss(n,n)=etag*abs(Ga(n))^2/(4*kg*h)+1i*imag(Zs);
  end
  clear rorelat Zs Zeq_sonda dlsonda gamma lsonda Zl
else Hss=[];
end
%
% Obtención de acoplos entre sondas de alim. y ranuras de rad.:(nran,nson)
if (son==1 && rad==1),
  rorelat=p_ran*ones(1,nson)-ones(nran,1)*p_son.';
  firelat=angle(-rorelat)-alpha*ones(1,nson);  
  rorelat=abs(rorelat)*kg;
  rorelat=max(rorelat,realmin);
  ll=l*ones(1,nson);
  Hrs=cos(kg/2*ll.*cos(firelat)).*sin(firelat).*sqrt(2./(pi*rorelat));
  Hrs=Hrs.*ll./(1-(kg/pi*ll.*cos(firelat)).^2).*exp(-1i*rorelat);
  Hrs=(ones(nran,1)*(Ga))/(2*pi*h).*Hrs*exp(1i*pi/4);
  clear rorelat firelat ll
else Hrs=[];
end
%
% Obtención de acoplos entre sondas de alim y sondas en cc.:(nsc,nson)
if (son==1 && fin==1),
  rorelat=p_corto*ones(1,nson)-ones(nsc,1)*p_son.';
  rorelat=abs(rorelat)*kg;
  rorelat=max(rorelat,realmin);
  Hcs=-(ones(nsc,1)*Ga).*sqrt(2./(pi*rorelat)).*exp(-1i*rorelat);
  Hcs=etag/4*Hcs*exp(1i*pi/4);
  clear rorelat
else Hcs=[];
end
%
%  Fin de acoplos de sondas de alimentación
%
%% OBTENCIÓN DE LAS TENSIONES DE EXCITACIÓN DE LAS RANURAS DE RADIACIÓN 
%% Y DE LOS CAMPOS ELÉCTRICOS EN LAS SONDAS DE PRUEBA                    %%
%
	H=[Hss+Rs Hcs.' -Hrs.';
	   Hcs Hcc -Hrc.';
	   Hrs Hrc Hrr+Yrr];
	Dat=[Vgs;zeros(nsc,1);zeros(nran,1)];
   Sol=inv(H)*Dat;
   clear Hcc Hcs Hrc Hrr Hrs Hss
%
   if(son==1)
		Is=Sol(1:nson);
        Vs=Vgs-Rs*Is;
   end
   if(fin==1)
        Ic=Sol(nson+1:nson+nsc);
   end
   if(rad==1)
		Vr=Sol(nson+nsc+1:nson+nsc+nran);
        Ir=-Yrr*Vr;
   end
   clear Sol H Dat Yrr Rs Vgs

   % Campo en los puntos de prueba
p_pun=puntos(:,1)+1i.*puntos(:,2);	%(npun,1) puntos de campo E

if rad==1,
%	Contribución de las ranuras de radiación  %OK
   rho=p_ran*ones(1,npun)-ones(nran,1)*p_pun.';
   phi=angle(-rho)-alpha*ones(1,npun);
   phi1=angle(-rho);
   rho=max(kg*abs(rho),realmin);
   ll=l*ones(1,npun);
   Err=cos(kg/2*ll.*cos(phi)).*sin(phi);
   Err=Err./(1-(kg/pi*ll.*cos(phi)).^2);
   Err=Err.*sqrt(2./(pi*rho)).*ll;
   Err=Err.*exp(-1i*rho)*exp(1i*pi/4)*kg/(2*pi*h);
   Hrrx=Err/etag.*sin(phi1);
   Hrry=-Err/etag.*cos(phi1);
   Er=Err.'*Vr;
   Hrx=Hrrx.'*Vr;
   Hry=Hrry.'*Vr;
%
   clear rho phi Err ll Hrrx Hrry
   else
      Er=0;
      Hrx=0;
      Hry=0;
   end
%	Contribución de las sondas en cortocircuito  %OK
   if (fin==1),
      rho=p_corto*ones(1,npun)-ones(nsc,1)*p_pun.';
      phi=angle(-rho);
      rho=max(kg*abs(rho),realmin);
   	  Ecc=kg*etag/4.*sqrt(2./(pi*rho));
      Ecc=-(Ecc.*exp(-1i*rho)*exp(1i*pi/4));
      Hccx=Ecc/etag.*sin(phi);
      Hccy=-Ecc/etag.*cos(phi);
      Ec=Ecc.'*Ic;
      Hcx=Hccx.'*Ic;
      Hcy=Hccy.'*Ic;
   	clear rho Ecc Hccx Hccy
   else
      Ec=0;
      Hcx=0;
      Hcy=0;
   end;
%	Contribución de las sondas de alimentación   %OK
   if (son==1),
      rho=p_son*ones(1,npun)-ones(nson,1)*p_pun.';
      phi=angle(-rho);
      rho=max(kg*abs(rho),realmin);
      Ess=Ga.'*ones(1,npun).*etag/(4*h).*sqrt(2./(pi*rho));
      Ess=-(Ess.*exp(-1i*rho)*exp(1i*pi/4));
      Hssx=Ess/etag.*sin(phi);
      Hssy=-Ess/etag.*cos(phi);
      Es=Ess.'*Is;
      Hsx=Hssx.'*Is;
      Hsy=Hssy.'*Is;
      clear rho Ess Hssx Hssy
   else
      Hsx=0;
      Hsy=0;
      Es=0;
   end
   E=Er+Ec+Es;
   Hx=Hsx+Hrx+Hcx;
   Hy=Hsy+Hry+Hcy;




clear Ga etag h alpha l n aux kg
clear Er Ec Es son fin rad punt npun nson nsc nran p_pun p_son p_corto p_ran
return
