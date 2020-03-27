function out = d2dms(in)

% D2DMS  converts an angle from degrees to degrees, minutes and seconds.
%
% Inputs:
%     in : scalar or row vector of angles in degrees
%
% Outputs
%     out : 3xN array of angles with rows:
%         row 1 : whole degree part of angle(s)
%         row 2 : whole minute part of angle(s)
%         row 3 : fractional second part of angle(s)
%
% Prototype:
%     dms = d2dms(38.45);
%
% Change Log:
%     1.  Written by David STauffer for AA279 on 29 Apr 2007.
%     2.  Moved to utils/units in Feb 2009.
%     3.  Incorporated into DStauffman library in Nov 2016.

% calculate size of array
[m,n] = size(in);

% give error if not a row vector
if m ~= 1
    error('matspace:UnexpectedArraySize', 'd2dms expects a scalar or row vector as input');
end

% initialize output
out = zeros(3,n);

% find whole degrees
out(1,:) = floor(in);
% find whole minutes
out(2,:) = floor(mod(in,1)*60);
% find fractional seconds
out(3,:) = (mod(in,1) - out(2,:)/60) * 3600;