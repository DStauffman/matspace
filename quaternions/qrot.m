function q = qrot(k,a)

% QROT  construct quaternion expressing rotation about a single axis
%
% Input:
%     k   : (scalar) axis about which rotation is being made [enumerated number]
%                   enumerated values are (1, 2, 3)
%                   (1) for x-axis
%                   (2) for y-axis
%                   (3) for z-axis
%     a   : (1xN) angle of rotation [rad]
%
% Output:
%     q   : (4x1) unit x,y,z,s quaternion [ndim]
%
% Prototype:
%     q = qrot(3,pi/2);
%
% See Also:
%     quat_mult, rot
%
% Reference:
%     1.  Wertz, James R. (editor), Equations 12.11 in “Parameterization of the Attitude,”
%         Section 12.1, Spacecraft Attitude Determination and Control,
%         Kluwer Academic Publishers, 1978.
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS(Romney, Hull), GARSE (Sims, Stauffer)
%     2.  Updated by Scott Sims in June 2009.
%     3.  Updated by David Stauffer in Jan 2010.
%     4.  Incorporated by David C. Stauffer into DStauffman tools in Nov 2016.

% get the number of angles to process
num = length(a);

if num == 1
    % optimized scalar case
    q = [0; 0; 0; cos(a/2)];
    q(k) = sin(a/2);
else
    % generic vector case
    q = [zeros(3,num); cos(a/2)];
    q(k,:) = sin(a/2);
end