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
%     dms = matspace.units.d2dms(38.45);
%     assert(all(abs(dms - [38; 27; 0]) < 1e-10));
%
% Change Log:
%     1.  Written by David C. Stauffer for AA279 on 29 Apr 2007.
%     2.  Moved to utils/units in Feb 2009.
%     3.  Incorporated into matspace library in Nov 2016.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

arguments
    in (1, :) double {mustBeVector}
end

% calculate size of array
n = size(in, 2);

% initialize output
out = zeros(3,n);

% find whole degrees
out(1,:) = floor(in);
% find whole minutes
out(2,:) = floor(mod(in,1)*60);
% find fractional seconds
out(3,:) = (mod(in,1) - out(2,:)/60) * 3600;