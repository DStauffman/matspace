function out = dms2d(in)

% D2DMS  converts an angle from degrees, minutes and seconds to degrees.
%
% Inputs:
%     in : 3xN array of angles with rows:
%         row 1 : whole degree part of angle(s)
%         row 2 : whole minute part of angle(s)
%         row 3 : fractional second part of angle(s)
%
% Outputs
%     out : scalar or row vector of angles in degrees
%
% Prototype:
%     dms = dms2d([3; 15; 45]);
%
% Change Log:
%     1.  Written by David STauffer for AA279 on 12 May 2007.
%     2.  Moved to utils/units in Feb 2009
%     3.  Incorporated into DStauffman library in Nov 2016.

% calculate size of array
m = size(in,1);

% give error if not a 3xN array
if m ~= 3
    error('dstauffman:UnexpectedArraySize', 'dms2d expects a 3xN array as input.');
end

% find fractional degrees by adding parts together
out = in(1,:) + in(2,:)/60 + in(3,:)/3600;