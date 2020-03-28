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
%     rad = r2d([180 90 0]);
%
% Change Log:
%     1.  Written by David STauffer for AA279 on 12 May 2007.
%     2.  Moved to utils/units in Feb 2009
%     3.  Incorporated into matspace library in Nov 2016.

rad = pi/180*deg;