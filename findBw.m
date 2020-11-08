function [bw] = findBw(x, y)
%%%%%%%%%%%%%%%%DOES NOT WORK%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finds the beam width of a normalized radiation pattern. 
% ref is u0 for v and v0 for u
maximY = max(y);
y = y-maximY;
indexMax = find(y == 0);

% We separate the array into two symmetric parts
y = circshift(y, round(length(y)/2)-indexMax); % The maximum is moved to the center

y1 = y(1:length(y)/2); % Array separation
y1 = flip(y1);
x1 = x(1:length(x)/2); 
x1= flip(x1);

y2 = y(length(y)/2+1:end); % Array separation
x2 = x(length(x)/2+1:end);

% It is calculated the first time the value goes 3db under the maximum
% For y1, it is necessary to turn it around. Since we are in linear

[~, indexBw1] = min(abs(y1+3));
% indexBw1 = indexBw1 - 1;   % -1 because the first index is at 0
[~, indexBw2] = min(abs(y2+3));

theta1 = x1(indexBw1)
theta2 = x2(indexBw2)

bw = -theta1+theta2;
end

