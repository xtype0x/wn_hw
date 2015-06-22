function[outputCircles,outputLines] = plotRecPwr(X,Y,Z,R,maxRecPwr,timeShifts)
% PLOTRECPWR Plot circles and lines for the received power in KML format
%
% Input:
%   X,Y:                coordinates (lat/lon) of the vehicles
%   Z:                  height of the circle (represents rec. power level)
%   R:                  circle radius
%   maxRecPwr:          maximum received power
%   timeShifts:         time shifts (for animation in case of multiple
%                       timesteps)
% Output:
%   outputCircles:      circles representing rec. power level
%   outputLines:        lines that connect Tx, Rx, and circles
%
% Copyright (c) 2014, Mate Boban

% If only four input arguments are provided, assume this is the
% visualization of a simulation with a single timestep
if nargin ==6
elseif nargin==5
    timeShifts = zeros(size(X));
else
    error('Wrong number of input arguments!');
end

outputCircles = [];
outputLines = [];
% Use Google's date format:
S = 'yyyy-mm-ddTHH:MM:SSZ';

% Remove rows where Z is Inf (no result for rec. power)
X = X(Z<Inf,:);
Y = Y(Z<Inf,:);
Z = Z(Z<Inf);
timeShifts = timeShifts(Z<Inf);

% Rounding rec. power to nearest integer so there are no errors during
% color selection 
Z = round(Z);
Z = max(.5,Z);
% Set colormap
clr = jet(maxRecPwr);

% NB: for plotting purpose, assumption is that the time interval is
% 1 second
tStart = datestr(timeShifts,S);
tEnd = datestr(timeShifts+1/24/60/60,S);

for i = 1:size(X,1)
    color = Z(i);
    if color < 1
        color = 1;
    end
    currentColor = clr(color,:);
    % Plot circles. Circles are at rec. power height at the receiver
    outputCircles = ...
        [outputCircles,externalCode.googleearth.ge_circle(X(i,1),Y(i,1),R,...
        'divisions',5,...
        'lineWidth',5.0,...
        'lineColor',['ff',plotFunctions.rgbCol2hexCol(currentColor)],...
        'altitude',.5,...
        'altitudeMode','relativeToGround',...
        'timeSpanStart',tStart(i,:),...
        'timeSpanStop',tEnd(i,:),...
        'polyColor','00000000')];
    outputCircles = ...
        [outputCircles,externalCode.googleearth.ge_circle(X(i,2),Y(i,2),R,...
        'divisions',5,...
        'lineWidth',5.0,...
        'lineColor',['ff',plotFunctions.rgbCol2hexCol(currentColor)],...
        'altitude',Z(i),...
        'altitudeMode','relativeToGround',...
        'timeSpanStart',tStart(i,:),...
        'timeSpanStop',tEnd(i,:),...
        'polyColor','00000000')];
    % Plot line. Line goes from ground level at the transmitter to rec.
    % power height at the receiver 
    outputLines = [outputLines,externalCode.googleearth.ge_plot3([X(i,1) X(i,2)],...
        [Y(i,1) Y(i,2)],[0 Z(i)],...
        'lineWidth',2,...
        'lineColor',['ff',plotFunctions.rgbCol2hexCol(currentColor)],...
        'timeSpanStart',tStart(i,:),...
        'timeSpanStop',tEnd(i,:),...
        'name','out01')];
    % Plot line from circle to receiver below it
    outputLines = [outputLines,externalCode.googleearth.ge_plot3([X(i,2) X(i,2)],...
        [Y(i,2) Y(i,2)],[0 Z(i)],...
        'lineWidth',2,...
        'lineColor',['ff',plotFunctions.rgbCol2hexCol(currentColor)],...
        'timeSpanStart',tStart(i,:),...
        'timeSpanStop',tEnd(i,:),...
        'name','out01')];
end