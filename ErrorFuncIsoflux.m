%%%%% ErrorFuncIsoflux.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Function that calculates the error between the achieved radiation
%   pattern and the target isoflux pattern.
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
%   -angMask: Angle in which the main beam finishes (degrees)
%   -datos,cortos,sondas,puntos: antenna characteristics (Aplanar format)
%   -file: .mat file in which the antenna basic structure is saved
%
%   Author: Tamara Salmerón
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function error=ErrorFuncIsoflux(x, Nturns, Dmax,Dmin,XPmax, angMask, datos,cortos,sondas,puntos,file)

%Parameters that can be modified
alpha=0.5; %Weighting factor

%Optimization parameters
deltaR=x(1); %Distance among the spiral turns
lengthc=x(2:2*Nturns+1); %Slot lengths in the control points
varPos=x(2*Nturns+2:end); %Variation in the position of the control points

%Resolution in theta and phi
resTheta=datos(5,1);
resPhi=datos(5,2);

%The complete spiral is obtained
[ranuras]=modifSpiral(Nturns,deltaR,lengthc,varPos,file);
numran=size(ranuras,1)
datos(2,2)=numran;

% Conversion from degrees to radians
if datos(2,2)~=0, ranuras(:,5)=ranuras(:,5)*pi/180;	 end

%The antenna directivity is calculated
[Vs,Is,Ic,Vr,Ir,E,Hx,Hy]=Analiza(datos,ranuras,cortos,sondas,puntos);
[Ecp2,Exp2]=Calc_cpo(datos,ranuras,Vr);
[d0,Pradd]=Calc_dir(datos,ranuras,Vr)

dirCP=Ecp2+d0*ones(resPhi,resTheta); %Copolar
dirXP=Exp2+d0*ones(resPhi,resTheta); %Crosspolar

%Theta range
theta=linspace(-pi/2,pi/2,resTheta); 

%The different sections are distinguished
endSL=find(theta>(-angMask*pi/180),1,'first'); %End of the sidelobes
endMB=find(theta>(angMask*pi/180),1,'first')-1; %End of the main beam

% Type 1 error function: error in the main beam region, with maximum and
% minimum requirements
vector_error1=((dirCP(:,endSL:endMB)-((Dmax(:,endSL:endMB)+Dmin(:,endSL:endMB))/2))./((Dmax(:,endSL:endMB)-Dmin(:,endSL:endMB))./2)).^6;

% Type 2 error function: only maximum requirements
vector_error2=2.^(dirCP(:,1:endSL-1)-Dmax(:,1:endSL-1)); %Sidelobes (CP pattern)
vector_error3=2.^(dirCP(:,endMB+1:end)-Dmax(:,endMB+1:end)); %Sidelobes (CP pattern)
vector_error4=1.1.^(dirXP(:,endSL:endMB)-XPmax(:,endSL:endMB)); %Error that is caused by the XP fields

%Total error
f1=sum(sum(vector_error1))+sum(sum(vector_error2))+sum(sum(vector_error3));
f2=sum(sum(vector_error4));
error=f1+alpha*f2
