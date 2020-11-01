%			calc_cpo.m
%	Función que calcula el campo radiado en dB.
function [Ecp2,Exp2]=Calc_cpo(datos,Ranuras,Vk)

%  	FUNCIÓN QUE CALCULA EL CAMPO RADIADO POR UN AGRUPAMIENTO 
% 	PLANO DE RANURAS DE IGUAL ANCHURA PARA UN DETERMINADO NÚMERO 
% 	DE DIRECCIONES (theta,phi).

%  	COMO RESULTADO SE OBTIENEN LOS MÓDULOS AL CUADRADO DEL
% 	MÁXIMO VALOR DE CAMPO Y DE LAS COMPONENTES 
%	copolar y contrapolar DEL CAMPO E.
%
%	Datos generales
frec=datos(1,4);
pol=datos(5,3);
l_pol=datos(5,4);
nph=datos(5,2);
nth=datos(5,1);
nptos=nth*nph;
Eth1=[];
Eph1=[];
for i=1:nth,
	theta(i)=datos(4,1)+(i-1)*(datos(4,2)-datos(4,1))/(nth-1);
end
for i=1:nph,
	phi(i)=(datos(4,3)+(i-1)*(datos(4,4)-datos(4,3))/(nph-1))-l_pol;
end

%	Longitud de onda:
lambda=299.792/(frec);
%	Nº de ranuras que forman el agrupamiento:
nran=length(Vk);
%	Coordenadas polares de los centros de las ranuras:
ro_ran=sqrt(Ranuras(:,1).^2+Ranuras(:,2).^2);
fi_ran=atan2(Ranuras(:,2),Ranuras(:,1));
%	Longitudes en mm.:
lk=Ranuras(:,3);
lk=lk';
psik=Ranuras(:,5);   % Coordenada Phi + inclinación
psik=psik';

%	Coordenadas cartesianas de los centros de las ranuras:
rk=[Ranuras(:,1),Ranuras(:,2),zeros(nran,1)];

% vector unitario en z
zun=[0;0;1];

% 	VECTOR UNITARIO QUE DETERMINA LA ORIENTACION DE CADA RANURA;(3*nran)
alfak=[cos(psik);sin(psik);zeros(1,nran)];
% 	VECTOR UNITARIO ORTOGONAL A CADA RANURA;(3*NRAN)
betak=[-sin(psik);cos(psik);zeros(1,nran)];

for i=1:nph
   sth=sin(theta*pi/180);
   cth=cos(theta*pi/180);
   sph=ones(1,nth).*sin(phi(i)*pi/180);
   cph=ones(1,nth).*cos(phi(i)*pi/180);
% 	VECTOR r UNITARIO EN CARTESIANAS PARA CADA DIRECCION;(3*NTH)
   run=[sth.*cph;sth.*sph;cth];
%	VECTOR teta UNITARIO EN CARTESIANAS PARA CADA DIRECCION;(3*NTH)
   thun=[cth.*cph;cth.*sph;-sth];
% 	VECTOR fi UNITARIO EN CARTESIANAS PARA CADA DIRECCION;(3*NTH)
   phiun=[-sph;cph;zeros(1,nth)];

% DIAGRAMA DE RADIACION
  
%	DIAGRAMA DE CADA RANURA CON DISTRIBUCION COSENO
%	DIMENSIONES: nran*nth
   u=((lk'*ones(1,nth)).*(alfak'*run))/lambda;
   pattel=cos(pi*u)./(1-4*u.*u);

% 	fa ES EL FACTOR DE FASE DEBIDA A LA POSICION DE CADA RANURA, 
% 	PARA CADA DIRECCION CONSIDERADA. DIMENSIONES: nran*nth
   fa=exp(1i*(2*pi/lambda)*(rk*run));

% 	fvec CONTIENE EL SUMATORIO DE LAS CONTRIBUCIONES DE TODAS
% 	LAS RANURAS PARA CADA UNA DE LAS DIRECCIONES.(3*nth)
   fvec=2/pi*(betak.*(ones(3,1)*(lk.*Vk.')))*(fa.*pattel);

%  	CALCULO DE LAS COMPONENTES CARTESIANAS DEL CAMPO
   E=vecp(run,vecp(zun,fvec))/lambda;

%  Eth1 ES UNA MATRIZ (nph*nth) QUE TIENE LA COMPONENTE theta 
   Eth1=[Eth1;ones(1,3)*(thun.*E)];

%  Eph1 ES UNA MATRIZ (nph*nth) QUE TIENE LA COMPONENTE phi
   Eph1=[Eph1;ones(1,3)*(phiun.*E)];

end

% 	PARA LIBERAR MEMORIA:
clear E pattel u fa fvec alfak betak zun thun phiun sth cth

% 	CALCULO DE LA COPOLAR Y LA CONTRAPOLAR


if (pol==1), 		% Polarización circular a izdas
	Exp1=(Eth1+j*Eph1)/sqrt(2).*(exp(j*pi/180*phi).'*ones(1,nth));
	Ecp1=(Eth1-j*Eph1)/sqrt(2).*(exp(-j*pi/180*phi).'*ones(1,nth));
elseif (pol==2),	% Polarización circular a dchas
	Ecp1=(Eth1+j*Eph1)/sqrt(2).*(exp(j*pi/180*phi).'*ones(1,nth));
	Exp1=(Eth1-j*Eph1)/sqrt(2).*(exp(-j*pi/180*phi).'*ones(1,nth));
elseif (pol==3),
	Ecp1=Eth1.*(sin(pi/180*phi).'*ones(1,nth))+Eph1.*(cos(pi/180*phi).'*ones(1,nth));
   Exp1=Eth1.*(cos(pi/180*phi).'*ones(1,nth))-Eph1.*(sin(pi/180*phi).'*ones(1,nth));
end

%phasediagrad=180/pi*angle(Ecp1)

Eth2=abs(Eth1).^2;
Eph2=abs(Eph1).^2;
Ecp2=abs(Ecp1).^2;
Exp2=abs(Exp1).^2;

clear Eth1 Eph1 Ecp1 Exp1  sph cph

%  Eth2 Y Eph2 SON LOS CUADRADOS DE LOS VALORES ABSOLUTOS
% DE LAS COMPONENTES theta Y phi RESP.;(NTH*NPH)

modulo=Eth2+Eph2;
if (min(nth,nph)>1)
	[Enorm,fila]=max(modulo);
	[Enorm,col]=max(Enorm);
	fila=fila(col);
	maximo=[theta(col),phi(fila)];
elseif nph==1,
	[Enorm,col]=max(modulo);
	maximo=[theta(col),phi];
elseif nth==1,
	[Enorm,fila]=max(modulo);
	maximo=[theta,phi(fila)];
end
clear modulo fila col

%	Normalización:

Ecp2=10*log10(Ecp2/Enorm);
Exp2=10*log10(Exp2/Enorm);
clear Enorm
return

