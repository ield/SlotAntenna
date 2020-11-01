%%%%% MaskIsoflux20.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Function to calculate the maximum and minimum directivity masks to
%   obtain an isoflux pattern with an edge of coverage of +-20º
%
%   Input parameters:
%   -resTheta: number of analyzed points in Theta
%   -resPhi: number of analyzed cuts in Phi
%
%   Output parameters:
%   -Dmax: maximum copolar target pattern
%   -Dmin: minimum copolar target pattern
%   -XPmax: maximum crosspolar target pattern
%
%   Author: Tamara Salmerón
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Dmax,Dmin,XPmax]=MaskIsoflux20(resTheta,resPhi)

%Angular range in theta
theta=linspace(-pi/2,pi/2,resTheta);

%Three different regions are obtained in our target patterns
endSL=find(theta>(-20*pi/180),1,'first'); %End of the sidelobes
endMB=find(theta>(20*pi/180),1,'first')-1; %End of the main beam
theta1=theta(1:(endSL-1)); %Region 1 (sidelobes)
theta2=theta(endSL:endMB); %Region 2 (main beam)
theta3=theta((endMB+1):end); %Region 3 (sidelobes)

%Number of points in each region
res1=length(theta1);
res2=length(theta2); 
res3=length(theta3); 

%Shape of the isoflux mask
rt=6380; %Earth radius (km)
horbit=650; %LEO orbit height (km)
G2=20*log10((1+horbit/rt)*cos(theta2)-sqrt(1-(1+horbit/rt)^2*(sin(theta2)).^2)); %Isoflux mask (no normalization)
Gnorm2=G2-ones(1,res2).*max(G2); %Normalized mask

%Maximum and minimum patterns in the main beam
G2max=Gnorm2+ones(1,res2).*10; %CP max
G2min=Gnorm2+ones(1,res2).*(-5); %CP min
G2maxXP=G2min-ones(1,res2).*11; %XP max (11 dB below the minimum copolar value)

%Maximum and minimum patterns in the sidelobes (negative angles)
G1min=-60*ones(1,res1); %CP max
G1max=linspace(-10,10,res1); %CP min
G1maxXP=G1min-ones(1,res1).*11; %XP max

%Maximum and minimum patterns in the sidelobes (positive angles)
G3min=-60*ones(1,res3); %CP max
G3max=fliplr(linspace(-10,10,res3)); %CP min
G3maxXP=G3min-ones(1,res3).*11; %XP max

DmaxdB= [G1max G2max G3max]; %CP max
DmindB= [G1min G2min G3min]; %CP min
XPmaxdB=[G1maxXP G2maxXP G3maxXP]; %XP max

%The masks should be satisfied in all of the phi cuts
for i=1:resPhi
    Dmax(i,:)=DmaxdB;
    Dmin(i,:)=DmindB;
    XPmax(i,:)=XPmaxdB;
end

%The target patterns are stored in a .mat file
save Galibo20.mat theta Dmax Dmin XPmax

%The target patterns are plotted
for jj=1:resPhi
    figure
    plot(theta*360/(2*pi),Dmax,'b')
    hold all
    plot(theta*360/(2*pi),Dmin,'r',theta*360/(2*pi),XPmax,'m')
    hold off
    ylabel('D(\theta) (dB)')
    xlabel('\theta (º)')
    xlim([-90 90])
    ylim([-60 15])
end

