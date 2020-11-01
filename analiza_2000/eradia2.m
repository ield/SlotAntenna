%______________________________________________________________________
%		eradia2.m
%_______________________________________________________________________
%  	FUNCIÓN QUE CALCULA EL CAMPO RADIADO POR UN AGRUPAMIENTO 
% 	PLANO DE RANURAS DE IGUAL ANCHURA PARA UN DETERMINADO NÚMERO 
% 	DE DIRECCIONES (theta,phi).

%  	COMO RESULTADO SE OBTIENEN LOS MÓDULOS AL CUADRADO DEL
% 	MÁXIMO VALOR DE CAMPO Y DE LAS COMPONENTES 
%	theta, phi, circular a dchas. y circular a izqdas. DEL CAMPO E.
%
function[Eth1,Eph1]=Eradia2(frec,theta,phi,Ranuras,Vk)
%
%	Longitud de onda:
lambda=299.792/(frec);
%	Nº de ranuras que forman el agrupamiento:
nran=length(Vk);
%	Coordenadas polares de los centros de las ranuras:
ro_ran=sqrt(Ranuras(:,1).^2+Ranuras(:,2).^2);
fi_ran=atan2(Ranuras(:,2),Ranuras(:,1));
%	Inclinación respecto a la dirección radial:
incli_ran=Ranuras(:,5)-fi_ran;
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

nph=length(phi);
nth=length(theta);

Eth1=[];
Eph1=[];
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
   % Hay un problema de indeterminación con 0/0
   for n=1:nran,
       for m=1:nth,
           if (1-4*u(n,m)^2)==0,
               pattel(n,m)=pi/4;
           else
               pattel(n,m)=cos(pi*u(n,m))./(1-4*u(n,m).*u(n,m));
           end
       end
   end
% 	fa ES EL FACTOR DE FASE DEBIDA A LA POSICION DE CADA RANURA, 
% 	PARA CADA DIRECCION CONSIDERADA. DIMENSIONES: nran*nth
   fa=exp(1i*(2*pi/lambda)*(rk*run));


% 	fvec CONTIENE EL SUMATORIO DE LAS CONTRIBUCIONES DE TODAS
% 	LAS RANURAS PARA CADA UNA DE LAS DIRECCIONES.(3*nth)
   fvec=2/pi*(betak.*(ones(3,1)*(lk.*Vk)))*(fa.*pattel);

%  	CALCULO DE LAS COMPONENTES CARTESIANAS DEL CAMPO
   E=vecp(run,vecp(zun,fvec))/lambda;

%  Eth1 ES UNA MATRIZ (nph*nth) QUE TIENE LA COMPONENTE theta 
   Eth1=[Eth1;ones(1,3)*(thun.*E)];

%  Eph1 ES UNA MATRIZ (nph*nth) QUE TIENE LA COMPONENTE phi
   Eph1=[Eph1;ones(1,3)*(phiun.*E)];

end;

% 	PARA LIBERAR MEMORIA:
clear E pattel u fa fvec alfak betak zun thun phiun sth cth sph cph

return