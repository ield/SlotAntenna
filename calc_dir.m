%_________________________________________________________________
%			CALC_DIR
%_________________________________________________________________
%	Función que calcula la directividad en dB.
%_________________________________________________________________

function[dir_dB,Pradd]=Calc_dir(datos,Ranuras,Vk,Ik)

frec=datos(1,4);
n_theta=datos(5,1);
n_phi=datos(5,2);
theta=linspace(0,90,n_theta);
phi=linspace(0,360,n_phi);

[Eth1,Eph1]=eradia2(frec,theta,phi,Ranuras,Vk);

Eth2=abs(Eth1).^2;
Eph2=abs(Eph1).^2;
modulo=Eth2+Eph2;
if (min(n_theta,n_phi)>1)
	[Enorm,fila]=max(modulo);
	[Enorm,col]=max(Enorm);
	fila=fila(col);
	Maximo=[theta(col),phi(fila)];
elseif nph==1,
	[Enorm,col]=max(modulo);
	Maximo=[theta(col),phi];
elseif nth==1,
	[Enorm,fila]=max(modulo);
	Maximo=[theta,phi(fila)];
end
clear Eth1 Eph1 fila col


%	CALCULO DE LA INTEGRAL
eta0=120*pi;
sth=sin(theta'*pi/180);
int=modulo'.*(sth*ones(1,n_phi));
intl=trapz(theta'*pi/180,int);
Pradd=trapz(phi'*pi/180,intl')/(2*eta0);
gan_dire=4*pi*Enorm/(2*eta0)/Pradd;
dir_dB=10*log10(gan_dire);

clear int intl Prad theta phi sth modulo
clear Eth2 Eph2

return