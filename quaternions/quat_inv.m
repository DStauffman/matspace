function [q_inv] = quat_inv(q) %#codegen

% QUAT_INV  finds the inverse of a normalized quaternion.
%
% Input:
%     q     : (4xN) quaternion
%
% Output:
%     q_inv : (4xN) inverse quaternion
%
% Prototype:
%     q = [0;0;0;1];
%     q_inv = quat_inv(q);
%
% See Also:
%     quat_mult, quat_norm
%
% Change Log.
%     1.  Added to DStauffman's library in March 2008.

% initialize to original quaternion
q_inv = q;

% negate first three terms leaving scalar as before
q_inv([1 2 3],:) = - q_inv([1 2 3],:);