%%%%% MaskIsoflux20.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Function to calculate the maximum and minimum directivity masks to
%   obtain a pencil beam pattern with controlled sidelobe level
%
%   Input parameters:
%   -resTheta: number of analyzed points in Theta
%   -resPhi: number of analyzed cuts in Phi
%
%   Output parameters:
%   -Dmax: maximum copolar target pattern
%   -Dmin: minimum copolar target pattern
%   -angPencil: half of the width of the main beam (degrees)
%
%   Author: Tamara Salmer?n
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Dmax,Dmin,angPencil]=MaskPencil(resTheta,resPhi, data)

%% 1-Setup

%Plot setup
set(0,'defaultaxesfontsize',14);
set(0,'defaulttextfontsize',14);
set(0,'defaultlinelinewidth',1.5);
set(0,'DefaultAxesXGrid','on','DefaultAxesYGrid','on','DefaultAxesZGrid','on')

%Parameters that can be modified in Optim.m (at the beginning)
bw=data(1); %Main beam width (at -3 dB) (degrees)
angPencil=bw/2; %half of the width of the main beam (degrees)
angSec=20; %Angle that determines the end of the sidelobes
Gmax=data(2); %Gain (dBi)
Gmin=data(3); %Difference between the maximum and minimum gain in the main beam (dB)
LobSec=data(4); %Desired sidelobe level (dB)
Gfin=35; %Difference between the maximum gain in theta=0 and theta=90 (dB)

%% 2-Definition of angular regions

%Angles that define the beginning of a new region of the mask (degrees)
MaxAngles=[-angSec -angPencil angPencil angSec];

MinAngles=[-angPencil angPencil];

%Angular range in theta
theta=linspace(-pi/2,pi/2,resTheta);

%The different regions of the mask are obtained, taking into account the
%resolution in theta

%Maximum directivity regions
for i=1:length(MaxAngles)
      finMax(i)=find(theta>(MaxAngles(i)*pi/180),1,'first')-1;
end
thmax1=theta(1:finMax(1));
thmax2=theta(finMax(1)+1:finMax(2));
thmax3=theta(finMax(2)+1:finMax(3));
thmax4=theta(finMax(3)+1:finMax(4));
thmax5=theta(finMax(4)+1:end);

%Minimum diretivity regions
for i=1:length(MinAngles)
      finMin(i)=find(theta>(MinAngles(i)*pi/180),1,'first')-1;
end
thmin=theta(finMin(1)+1:finMin(2));

%Resolution in theta in each region
resMax=[length(thmax1) length(thmax2) length(thmax3) length(thmax4) length(thmax5)];
resMin=length(thmin);

%% 3-Directivity masks in each region

%Sidelobes (negative values of theta)
G1max=linspace(Gmax-Gfin,Gmax-LobSec,resMax(1));
G2max=linspace(Gmax-LobSec,Gmax,resMax(2));

%Main beam
G3min=(Gmax-Gmin)*ones(1,resMin);
G3max=Gmax*ones(1,resMax(3));

%Sidelobes (positive values of theta)
G4max=fliplr(linspace(Gmax-LobSec,Gmax,resMax(4)));
G5max=fliplr(linspace(Gmax-Gfin,Gmax-LobSec,resMax(5)));

%All the values of the directivity masks are put together
DmaxdB= [G1max G2max G3max G4max G5max]; %Maximum
DmindB= G3min; %Minimum


%The masks should be satisfied in all of the phi cuts
for i=1:resPhi
    Dmax(i,:)=DmaxdB;
    Dmin(i,:)=DmindB;
end

%% 4-Plot
% for jj=1:resPhi
    figure
    plot(theta*360/(2*pi),Dmax(1,:),'b')
    hold on
    plot(thmin*360/(2*pi),Dmin(1,:),'r')
    hold off
    ylabel('D(\theta) (dB)')
    xlabel('\theta')
    xlim([-90 90])
% end
thetaGal=theta;

%The target patterns are stored in a .mat file
save GaliboPincel.mat Dmax Dmin thetaGal thmin
