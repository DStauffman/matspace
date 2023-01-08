function rad = d2r(deg)

% D2R  converts degrees to radians.
%
% Inputs:
%     deg : array of angles in degrees
%
% Outputs:
%     rad : array of angles in radians
%
% Prototype:
%     rad = matspace.units.d2r([180 90 0]);
%     assert(all(rad == [pi pi/2 0]));
%
% Change Log:
%     1.  Written by David C. Stauffer for AA279 on 12 May 2007.
%     2.  Moved to utils/units in Feb 2009
%     3.  Incorporated into matspace library in Nov 2016.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

arguments
    deg {mustBeNumeric}
end

rad = pi/180*deg;