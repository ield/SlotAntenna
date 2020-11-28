function [maxDir_res, sll_res, error] = optimizeH(h)


%%%%% Optim.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Function to optimize the slots lengths and positions to obtain a RLSA
%   with an arbitrary pattern and circular polarization.
%   It minimizes the error between the target radiation pattern and the
%   achieved one, taking into account both the copolar and crosspolar
%   components.
%
%   The optimization scheme is based on the analysis with the Aplanar
%   software.
%
%   Input parameters:
%   -resTheta: number of analyzed points in Theta
%   -resPhi: number of analyzed cuts in Phi
%
%   Output parameters:
%   -slotsSol: matrix with the final information about the optimized slots
%   -nslotsSol: final number of slots
%
%   Author: Tamara Salmer?n
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Things to change for every simulation
% freq: lin46
% sizeAntenna: lin48
% MaxGain: lin74
% Polarization: lin106
% Name of the saved antenna: lin 169
% Data to be printed: depending on polarization 225 or 232
% Name of the saved file: lin 243.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function [slotsSol,nslotsSol]=Optim(resTheta,resPhi)

%% 1-Initial setup
allFreq = [7.5 8.15];           % All central frequency is GHz
freqText = ['rx'; 'tx'];
indexFreq = 1;

bw = [-0.25 0 0.25];            % Offset to the central frequency
bwText = ['fl'; 'fc'; 'fh'];      % freq low, freq cent, freq high
indexBw = 1;                    % It is best to see them work in the lower frequency because they are less effective

freq = allFreq(indexFreq) + bw(indexBw);    %  Frequency (GHz)
lambda0=300/freq %Vacuum wavelength (mm)
sizeAntenna = 400;  %Size of the antenna in mm


%Parameters that can be modified
% Nturns=floor((sizeAntenna/lambda0-1)/2); %Number of spiral turns
Nturns = 8;
Ncont=2*Nturns; %Number of control points
isoflux=0; %Isoflux=1 to obtain an isoflux pattern. Isoflux=0 to obtain a pencil beam pattern

%The antenna basic structure is loaded
file='structurelowf.mat';
load(file)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Values to modify: 
% It is important to insert them here and savet them in
% datos of struclowf. They are the values below. The values are adjusted to
% our initial theoretical design.

datos(1,4) = freq;
% h = 12;         % Height of the waveguide (mm). Evaluate different values.
datos(1,1) = h;
t = 0.4;          % Thickness of the upper plate (mm)
datos(1,2) = t;
bw = 7;        % Main beam width (at -3 dB) (degrees)
datos(3,1) = bw;
Gmax = 31;      % Gain (dBi)
datos(3,2) = Gmax;
Gmin = 2;       %Difference between the maximum and minimum gain in the main beam (dB)
datos(3,3) = Gmin;
LobSec = 22;    %Desired sidelobe level (dB)
datos(3,4) = LobSec;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Other constants that are used
freq=datos(1,4) %Frequency (GHz)
epsr=datos(1,3) %Relative permittivity of the material that fills the RLSA
t=datos(1,2); %Thickness of the upper plate (mm)
h=datos(1,1); %Height of the waveguide (mm)

%Waveguide wavelength (mm)
lambdag=lambda0/sqrt(epsr); 

%Effective relative permittivity: intermediate value between 1 and the
%relative permittivity of the material that fills the RLSA
epseff=0.4+0.6*epsr+0.21*(1-epsr)*sqrt(t./w);   % w is the slot width. Formula in tamara's pfc pag 12 2.26
lambdaeff=lambda0./sqrt(epseff);                % Initial Lres

%Resolution in theta
% IMPORTANT!!!!!!!!!!: The program works if and only if resTheta == resPhi
resTheta=181; % Number of theta angles
datos(5,1)= resTheta;
%Resolution in phi
% resPhi=181; % Number of phi angles
% datos(5,2)= resPhi;
resPhi=3; % Number of phi angles
datos(5,2)= resPhi;

%Type of polarization (LHCP-->1 RHCP-->2)
datos(5,3)= 1;

%M?nimo y m?ximo theta y phi
datos(4,1)=-90;
datos(4,2)=90;
datos(4,3)=-90;
datos(4,4)=90;

theta=linspace(-pi/2,pi/2,resTheta); %Rango completo de coordenadas theta
phi = linspace (-pi,pi,resPhi); %Rango completo de coordenadas phi
save(file);
%% 2-Optimization target masks

[Dmax,Dmin,angPincel]=MaskPencil(resTheta,resPhi, datos(3,:)); %Pencil beam with controlled SLL mask
%% 3-Optimization initial values and bounds

deltaRini=lambdag; %Initial value of the distance between successive turns
longcIni=0.48*lambdaeff*ones(1,Ncont); %Initial values of lengths in the control points
varPosIni=zeros(1,Ncont); %Initial values of the variation of the position of the control points

%All the initial values are gathered together in a vector
xIni=[deltaRini longcIni varPosIni];

%Optimization options
% options=optimset('Algorithm','active-set','Maxiter',2e3,'MaxFunEvals',2e3);
options=optimset('Algorithm','active-set','Maxiter',2e3,'MaxFunEvals',2e3, 'PlotFcns', {@optimplotx, @optimplotfval,@optimplotfunccount,@optimplotconstrviolation});
%Bounds of the optimization parameters
lb=[0.9*lambdag 0.39*lambdaeff*ones(1,Ncont) -0.05*lambdag*ones(1,Ncont)]; %Lower bounds
ub=[1*lambdag 0.49*lambdaeff*ones(1,Ncont) 0.05*lambdag*ones(1,Ncont)]; %Upper bounds

%% 4-Optimization process
%Pencil beam with controlled SLL
[xsol,fval,exitflag,output] = fmincon(@(x) ErrorFuncPencil(x, Nturns, Dmax,Dmin, angPincel, datos,cortos,sondas,puntos,file),xIni,[],[],[],[],lb,ub,[],options);


%% 5-Results

deltaRsol=xsol(1); %Separation between successive turns
longcsol=xsol(2:Nturns*2+1); %Lengths in the control points
varPossol=xsol(Nturns*2+2:end); %Variation in the position of the control points

%The final complete spiral is obtained
[slotsSol]=modifSpiral(Nturns,deltaRsol,longcsol,varPossol,file)
nslotsSol=size(slotsSol,1)
datos(2,2)=nslotsSol;

%Conversion from degrees to radians
if datos(2,1)~=0, sondas(:,6)=sondas(:,6)*pi/180;  end
if datos(2,2)~=0, slotsSol(:,5)=slotsSol(:,5)*pi/180;	 end

%The directivity of the resulting antenna is obtained
[Vs,Is,Ic,Vr,Ir,E,Hx,Hy]=analiza(datos,slotsSol,cortos,sondas,puntos);
[Ecp2,Exp2]=calc_cpo(datos,slotsSol,Vr);
[d0,Pradd]=calc_dir(datos,slotsSol,Vr);

dirSoldB=Ecp2+d0*ones(resPhi,resTheta); %CP component
dirXPdB=Exp2+d0*ones(resPhi,resTheta); %XP component

%Conversion from radians to degrees
if datos(2,2)~=0, slotsSol(:,5)=slotsSol(:,5)*180/pi;	 end

for jj=1:resPhi,
	phicoor(jj)=(datos(4,3)+(jj-1)*(datos(4,4)-datos(4,3))/(resPhi-1));
end
% Definition of thmin to plot Dmin
load('GaliboPincel.mat');
thmin_plot = thmin;
save('GaliboPincel.mat');

%% Obtention of the final values

maxDir = zeros(1, 2);
sll = zeros(1, 2);
for jj = 1:2
    maxDir(jj) = max(dirSoldB(jj, :));
    sll(jj) = calcSLL(dirSoldB(jj, :));
    
end
maxDir_res = max(maxDir);
sll_res = min(sll);

error = sqrt((29-maxDir_res)^2*(maxDir_res<29)+(20-sll_res)^2*(sll_res<20));

end

