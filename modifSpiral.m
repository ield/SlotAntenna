
%%%%% modifSpiral.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Function to design a complete spiral from the data about the control
%   points.
%
%   First, it creates an Archimedean spiral with N turns and a distance
%   among turns deltaR. Then, it modifies the position of the control
%   points. Finally, it determines the slots lengths interpolating the
%   lengths in the control points.
%
%   Input parameters:
%   -Nturns: number of spiral turns
%   -deltaR: separation among successive spiral turns (mm)
%   -lengthc: lengths in the control points (mm)
%   -varPos: variation in the position of the control points (mm)
%   -file: .mat file in which the antenna basic structure is saved
%
%   Output parameters:
%   -slots: matrix with dimensions (number of slots x 5):
%       1-x coordinate of each slot (mm)
%       2-y coordinate of each slot (mm)
%       3-Slots lengths(mm)
%       4-Slots widths (mm)
%       5-Slots tilt angles (º)
%	
%   Author: Tamara Salmerón Ruiz
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[slots]=modifSpiral(Nturns,deltaR,lengthc,varPos,file)

%The antenna basic structure is loaded
load(file)

%Constants that are used
frec=datos(1,4); %central frequency (GHz)
epsr=datos(1,3); %Relative permittivity of the material that fills the RLSA
lambda0=300/frec; %Vacuum wavelength (mm)
lambdag=lambda0/sqrt(epsr); %Waveguide wavelength (mm)
nCont=2*Nturns; %Number of control points

%The initial position of each element that forms the spiral is obtained
[ro,phi,nslots,slots]=SpiralN(Nturns,deltaR,file);

%We consider that the ro and phi coordinates of each radiating element are
%the mean values of the coordinates of the two slots that form it 
i=1;
phielem=zeros(nslots/2,1);
roelem=zeros(nslots/2,1);
while(i<nslots)
    j=(i+1)/2;
    phielem(j)=(phi(i)+phi(i+1))/2;
    roelem(j)=(ro(i)+ro(i+1))/2;
    i=i+2;
end

%The initial position of the control points is determined
romin=roelem(1);
rocnt=zeros(1,nCont);
for icont=1:nCont,
    rocnt(icont)=romin+deltaR/2*(icont-1); %2 control points in each turn
end

%The position of each control point suffers a variation and the position of
%all the remaining slots is calculated with an interpolation
[roelem,rocnt] = InterpPos(rocnt, phielem, varPos);

%An interpolation is used to calculate the length of every slot pair
lelem=interp1(rocnt,lengthc,roelem,'linear','extrap');

%It is taken into account that even slots are located at a distance of
%lambdag/4 from odd slots and their position is obtained
ro=zeros(nslots,1);
phi=zeros(nslots,1);
ro(1:2:nslots-1)=roelem; %Odd slots
phi(1:2:nslots-1)=phielem;
phi(2:2:nslots)=phielem; 

i=1;
while(i<nslots)
    var=atan2((lambdag/4),(ro(i)+(lambdag/4)));
    phi(i)=phi(i)-var/2;
    phi(i+1)=phi(i+1)+var/2;
    ro(i+1)=sqrt((ro(i)+lambdag/4)^2+(lambdag/4)^2); %Even slots
    i=i+2;
end

%Transformation to cartesian coordinates
xran=ro.*cos(phi);
yran=ro.*sin(phi);

%The two slots that form a radiating element have the same length
lran=zeros(nslots,1);
lran(1:2:nslots-1)=lelem; %Odd slots
lran(2:2:nslots)=lelem; %Even slots

%Every slot is cretaed with the same width
wran=w.*ones(nslots,1);

%Each slot is tilted +-45º with respect to the radial direction
phigr=mod(phi,2*pi).*(180/pi);  %Phi component in degrees
gran=zeros(nslots,1);

i=1;
while(i<nslots)
    gran(i)=mod(phigr(i)+315,360); %The odd slots are tilted 315º
    gran(i+1)=mod(gran(i)+90,360); %The even slots are orthogonal to the odd ones
    i=i+2;
end

%Final matrix with all the information about the slots
slots=[xran, yran, lran, wran, gran];