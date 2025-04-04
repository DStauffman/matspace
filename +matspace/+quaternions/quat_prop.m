function quat_new = quat_prop(quat, delta_ang, renorm) %#codegen

% QUAT_PROP  approximate propagation of a quaternion using a small delta angle.
%
% Input:
%     quat        :   (4x1) normalized input quaternion  [dimensionless]
%     delta_ang   :   (3x1) delta angles in x,y,z order  [radians]
%
% Output:
%     quat_new    :   (4x1) propagated quaternion, optionally renormalized [dimensionless]
%
% Prototype:
%     quat      = [0;0;0;1];
%     delta_ang = [0.01,0.02,0.03];
%     renorm    = true;
%     quat_new  = matspace.quaternions.quat_prop(quat, delta_ang, renorm);
%
% See Also:
%     matspace.quaternions.quat_mult, matspace.quaternions.quat_inv, matspace.quaternions.quat_norm,
%     matspace.quaternions.quat_times_vector, matspace.quaternions.quat_to_dcm,
%     matspace.quaternions.quat_to_euler, matspace.quaternions.quat_from_euler
%
% Reference:
%     1.  See Wei eqn 5.75, pg 327.
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS (Romney, Hull), GARSE (Sims, Stauffer, Beck)
%     2.  Updated by Matt Beck in June 2009.
%     3.  Updated by Tom Trankle in July 2011 for #eml support.
%     4.  Incorporated by David C. Stauffer into matspace in Nov 2016.
%     5.  Updated by David C. Stauffer in December 2018 to enforce positive scalar component and
%         optionally renormalize.
%     6.  Updated by David C. Stauffer in April 2020 to put into a package.

% imports
import matspace.quaternions.quat_norm

% optional inputs
switch nargin
    case 2
        renorm = true;
    case 3
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% compute angle rate matrix
W = [      0         delta_ang(3)   -delta_ang(2)   delta_ang(1);...
     -delta_ang(3)        0          delta_ang(1)   delta_ang(2);...
      delta_ang(2)  -delta_ang(1)        0          delta_ang(3);...
     -delta_ang(1)  -delta_ang(2)   -delta_ang(3)        0     ];

% compute delta quaternion
delta_quaternion = 0.5*W*quat;

% propagate over delta
quat_new = quat + delta_quaternion;
if quat_new(4) < 0
    quat_new = -quat_new;
end

% optionally renormalize
if renorm
    quat_new = quat_norm(quat_new);
end