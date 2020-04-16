function out = quat_norm(x) %#codegen

% QUAT_NORM  normalize each column of the input quaternion.
%
% Input:
%     x      : (4xN) quaternion  [ndim]
%
% Output:
%     out    : (4xN) normalized quaternion  [ndim]
%
% Prototype:
%     x(:,1) = [0.1;0;0;1];
%     x(:,2) = [0;0;0.2;1];
%     out    = matspace.quaternions.quat_norm(x)
%
% See Also:
%     matspace.quaternions.quat_mult, matspace.quaternions.quat_inv, matspace.quaternions.quat_prop,
%     matspace.quaternions.quat_times_vector, matspace.quaternions.quat_to_dcm,
%     matspace.quaternions.quat_to_euler, matspace.quaternions.quat_from_euler
%
% Notes:
%     1.  Could be replaced by unit function.
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS (Romney, Hull), GARSE (Sims, Stauffer, Beck)
%     2.  Updated by Matt Beck in June 2009.
%     3.  Updated by Tom Trankle in July 2011 for #eml.
%     4.  Incorporated by David C. Stauffer into matspace in Nov 2016.
%     5.  Updated by David C. Stauffer in April 2020 to put into a package.

% number of rows of x
n = size(x,1);

% norm of each column vector
w = realsqrt(sum(x.*x));

% expand w to have dimension of x, divide
out = x./(ones(n,1)*w);