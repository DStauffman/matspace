function [q_inv] = quat_inv(q)  %#codegen

% QUAT_INV  returns the inverses of normalized quaternions.
%
% Input:
%     q     : (4xN) quaternion
%
% Output:
%     q_inv : (4xN) inverse quaternion
%
% Prototype:
%     q = [0.5; -0.5; -0.5; 0.5];
%     q_inv = matspace.quaternions.quat_inv(q);
%     assert(all(q_inv == [-0.5; 0.5; 0.5; 0.5]));
%
% See Also:
%     matspace.quaternions.quat_mult, matspace.quaternions.quat_norm
%
% Change Log.
%     1.  Added to matspace library in March 2008.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.
%     3.  Updated by David C. Stauffer in January 2026 to use arguments.

arguments (Input)
    q (4, :) double
end
arguments (Output)
    q_inv (4, :) double
end

% invert the quaternions, by negating the first three terms, leaving scalar as before
q_inv = [-q(1,:); -q(2,:); -q(3,:); q(4,:)];