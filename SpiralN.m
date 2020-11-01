
%%%%% SpiralN.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Function to obtain the positions and tilt of the slot pairs that form a
%   Radial Line Slot Antenna with an Archimedean spiral layout (spiral with
%   N turns and a distance among turns deltaR)
%
%   Input parameters:
%   -N: number of spiral turns
%   -deltaR: separation among successive spiral turns (mm)
%   -file: .mat file in which the antenna basic structure is saved
%
%   Output parameters:
%   -slots: matrix with dimensions (number of slots x 5):
%       1-x coordinate of each slot (mm)
%       2-y coordinate of each slot (mm)
%       3-Slots lengths(mm)
%       4-Slots widths (mm)
%       5-Slots tilt angles (º)
%   -nslots: number of slots
%   -ro: rho coordinate of each slot (mm)
%   -phi: phi coordinate of each slot (rad)
%	
%   Author: Tamara Salmerón Ruiz
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[ro,phi,nslots,slots]=SpiralN(N,deltaR,file)

%% 1-Setup

%The antenna basic structure is loaded
load(file)

%Constants that are used
frec=datos(1,4); %Central frequency (GHz)
epsr=datos(1,3); %Relative permittivity of the material that fills the RLSA
t=datos(1,2); %Thickness of the upper plate (mm)
lambda0=300/frec; %Vacuum wavelength (mm)
lambdag=lambda0/sqrt(epsr); %Waveguide wavelength (mm)
kg=2*pi/lambdag; %Wave number
epseff=0.4+0.6*epsr+0.21*(1-epsr)*sqrt(t./w);%Effective relative permittivity: 
%intermediate value between 1 and the relative permittivity of the material that fills the RLSA
lambdaeff=lambda0./sqrt(epseff); %Effective wavelength (mm)

%Parameters that can be modified
ro_min=0.6*lambdag;	%Distance between the feed and the first slot
deltaPhi=0.55*lambdag; %Distance between successive radiating elements
polarization=-1; %LHCP=-1; RHCP=+1;

%Archimedean spiral constant (ro=a*phi)
a=polarization*deltaR/(2*pi);

%% 2-Radiating elements positioning

%Coordinates of the first element
phi_ini=0;
ro_actual=ro_min;

%Initialization
phi_actual=0;
n=0;
phi=[];
ro=[];
alfa=[];

% The polar coordinates (ro,phi) of each radiating element are obtained,
% until N turns are completed
while (phi_actual>(-2*pi*N))
	n=n+2;
	phi_actual=phi_ini+(ro_actual-ro_min)/a;
	ro=[ro;ro_actual;ro_actual];
	phi=[phi;phi_actual;phi_actual];
	ro_actual=ro_actual+deltaPhi/sqrt(1+kg*deltaPhi+(kg*ro_actual)^2);
end
nslots=n;  %Number of slots

%% 3-Slots positioning

%It is taken into account that even slots are located at a distance of
%lambdag/4 from odd slots and their position is obtained
i=1;
while(i<nslots)
    var=atan2((lambdag/4),(ro(i)+(lambdag/4)));
    phi(i)=phi(i)-var/2;
    phi(i+1)=phi(i+1)+var/2;
    ro(i+1)=sqrt((ro(i)+lambdag/4)^2+(lambdag/4)^2);
    i=i+2;
end

%The position of each slot is plotted
polar(phi,ro,'b')
hold off

%Transformation to cartesian coordinates
xran=ro.*cos(phi);
yran=ro.*sin(phi);

%Every slot is cretaed with the same length and width
lran=(lambdaeff*0.48).*ones(nslots,1);
wran=w.*ones(nslots,1);

%Each slot is tilted +-45º with respect to the radial direction
phigr=mod(phi,2*pi).*(180/pi); %Phi component in degrees
gran=zeros(nslots,1);
i=1;
while(i<nslots)
    gran(i)=mod(phigr(i)+315,360); %The odd slots are tilted 315º
    gran(i+1)=mod(gran(i)+90,360); %The even slots are orthogonal to the odd ones
    i=i+2;
end

%Final matrix with all the information about the slots
slots=[xran, yran, lran, wran, gran];

clear ro_actual n ranuras