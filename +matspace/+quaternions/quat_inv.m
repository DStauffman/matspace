function [q_inv] = quat_inv(q) %#codegen

% QUAT_INV  returns the inverses of normalized quaternions.
%
% Input:
%     q     : (4xN) quaternion
%
% Output:
%     q_inv : (4xN) inverse quaternion
%
% Prototype:
%     q = [0;0;0;1];
%     q_inv = matspace.quaternions.quat_inv(q);
%
% See Also:
%     matspace.quaternions.quat_mult, matspace.quaternions.quat_norm
%
% Change Log.
%     1.  Added to matspace library in March 2008.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

% invert the quaternions, by negating the first three terms, leaving scalar as before
q_inv = [-q(1,:); -q(2,:); -q(3,:); q(4,:)];