%%%%% ErrorFuncPencil.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Function that calculates the error between the achieved radiation
%   pattern and the target pencil beam pattern (controlled sidelobe level 
%   is possible).
%   Both the CP and XP errors are taken into account and the final error is
%   obtained as a weighted sum.
%
%   Input parameters:
%   -x: vector with the optimization parameters
%       1)Distance among the spiral turns (1 value)
%       2)Slot lengths in the control points (2*Nturns values)
%       3)Variation in the position of the control points (2*Nturns
%       values)
%   -Nturns: number of spiral turns
%   -Dmax,Dmin: maximum and minimum copolar target patterns
%   -XPmax: maximum crosspolar target pattern
%   -angPencil: Angle in which the main beam finishes (degrees)
%   -datos,cortos,sondas,puntos: antenna characteristics (Aplanar format)
%   -file: .mat file in which the antenna basic structure is saved
%
%   Author: Tamara Salmer?n
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function error=ErrorFuncPencil(x, Nturns, Dmax,Dmin, angPencil, datos,cortos,sondas,puntos,file)

%Optimization parameters
deltaR=x(1); %Distance among the spiral turns
lengthc=x(2:2*Nturns+1); %Slot lengths in the control points
varPos=x(2*Nturns+2:end); %Variation in the position of the control points

%Resolution in theta and phi
resTheta=datos(5,1);
resPhi=datos(5,2);

%Theta range
theta=linspace(-pi/2,pi/2,resTheta);

%The complete spiral is obtained
[ranuras]=modifSpiral(Nturns,deltaR,lengthc,varPos,file);
numran=size(ranuras,1);
datos(2,2)=numran;

% Conversion to radians
if datos(2,2)~=0, ranuras(:,5)=ranuras(:,5)*pi/180;	 end

%The antenna directivity is calculated
[Vs,Is,Ic,Vr,Ir,E,Hx,Hy]=analiza(datos,ranuras,cortos,sondas,puntos);
[Ecp2,Exp2]=calc_cpo(datos,ranuras,Vr);
[d0,Pradd]=calc_dir(datos,ranuras,Vr);

dirdB=Ecp2+d0*ones(resPhi,resTheta); %Copolar
dirXP=Exp2+d0*ones(resPhi,resTheta); %Crosspolar

%The different sections are distinguished
startMB=find(theta>(-angPencil*pi/180),1,'first'); %Start of the main beam
endMB=find(theta>(angPencil*pi/180),1,'first')-1; %End of the main beam

% Type 1 error function: error in the main beam region, with maximum and
% minimum requirements
vector_error1=((dirdB(:,startMB:endMB)-((Dmax(:,startMB:endMB)+Dmin)/2))./((Dmax(:,startMB:endMB)-Dmin)./2)).^6;

% Type 2 error function: error in the sidelobes, only with maximum requirements
vector_error2=2.^(dirdB(:,1:startMB-1)-Dmax(:,1:startMB-1));
vector_error3=2.^(dirdB(:,endMB+1:end)-Dmax(:,endMB+1:end)); 

% Total error.
error=sum(sum(vector_error1))+sum(sum(vector_error2))+sum(sum(vector_error3));
