%%%%% InterpPos.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Function that obtains the final radial position of the control points
%   and interpolates the rho coordinate of all the slots that form the
%   spiral
%
%   Input parameters:
%   -rocnt: initial radial position of the control points
%   -phi: phi coordinate of all the radiating elements
%   -varPos: desired variation in the position of the control points with
%   respect to the perfect Archimedean spiral
%
%   Output parameters:
%   -rocnt: final radial position of the control points
%   -ro: rho coordinate of each slot (mm)
%	
%   Author: Tamara Salmerón Ruiz
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ro,rocnt] = InterpPos(rocnt, phi,varPos)

nControl=length(rocnt); %Number of control points

%The phi coordinate of the control points is defined
for i=1:nControl
    phicnt(i)=-pi*(i-1); %2 control points in each turn
end

%The initial position of the control points is modified and the perfect
%spiral layout is disturbed
for j=1:nControl
    rocnt(j:1:nControl)=rocnt(j:1:nControl)+varPos(j);
end

%The rho coordinate of all the slots is interpolated
ro=interp1(phicnt,rocnt,phi,'linear','extrap');





