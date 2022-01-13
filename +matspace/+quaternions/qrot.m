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
%     q = matspace.quaternions.qrot(3, pi/2);
%
% See Also:
%     matspace.quaternions.quat_mult, matspace.quaternions.rot
%
% Reference:
%     1.  Wertz, James R. (editor), Equations 12.11 in "Parameterization of the Attitude",
%         Section 12.1, Spacecraft Attitude Determination and Control,
%         Kluwer Academic Publishers, 1978.
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS(Romney, Hull), GARSE (Sims, Stauffer)
%     2.  Updated by Scott Sims in June 2009.
%     3.  Updated by David C. Stauffer in Jan 2010.
%     4.  Incorporated by David C. Stauffer into matspace in Nov 2016.
%     5.  Updated by David C. Stauffer in April 2020 to put into a package.

if isscalar(k) && isscalar(a)
    % optimized scalar case
    q = [0; 0; 0; cos(a/2)];
    q(k) = sin(a/2);
elseif isscalar(k)
    % single axis, multiple angle case
    num = length(a);
    q = zeros(4, num);
    q(4, :) = cos(a/2);
    q(k, :) = sin(a/2);
elseif isscalar(a)
    % single angle, multiple axes case
    num = length(k);
    q = zeros(4, num);
    q(4, :) = cos(a/2);
    if num > 0
        ix = sub2ind([4 num], k, 1:num);
        q(ix) = sin(a/2);
    end
else
    % generic vector case
    num = length(k);
    assert(num == length(a));
    q = zeros(4, num);
    q(4, :) = cos(a/2);
    if num > 0
        ix = sub2ind([4 num], k, 1:num);
        q(ix) = sin(a/2);
    end
end
% enforce positive scalar
q(:, q(4, :) < 0) = -q(:, q(4, :) < 0);