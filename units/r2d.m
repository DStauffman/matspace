function deg = r2d(rad)

% R2D  converts radians to degrees.
%
% Inputs:
%     rad : array of angles in radians
%
% Outputs:
%     deg : array of angles in degrees
%
% Prototype:
%     deg = r2d([pi pi/2 0]);
%
% Change Log:
%     1.  Written by David STauffer for AA279 on 12 May 2007.
%     2.  Moved to utils/units in Feb 2009
%     3.  Incorporated into matspace library in Nov 2016.

deg = 180/pi*rad;