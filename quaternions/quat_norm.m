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
%     out    = quat_norm(x)
%
% See Also:
%     quat_mult, quat_inv, quat_prop, quat_times_vector, quat_to_dcm, quat_to_euler, quat_from_euler
%
% Notes:
%     1.  Could be replaced by unit function.
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS (Romney, Hull), GARSE (Sims, Stauffer, Beck)
%     2.  Updated by Matt Beck in June 2009.
%     3.  Updated by Tom Trankle in July 2011 for #eml.
%     4.  Incorporated by David C. Stauffer into matspace in Nov 2016.

% number of rows of x
n = size(x,1);

% norm of each column vector
w = realsqrt(sum(x.*x));

% expand w to have dimension of x, divide
out = x./(ones(n,1)*w);