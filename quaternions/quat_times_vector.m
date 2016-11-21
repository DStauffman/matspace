function [vec] = quat_times_vector(q, v)

% QUAT_TIMES_VECTOR  multiplies a vector by a quaternion.
%
% Summary:
%     Method
%         1.  qv = q(1:3) x v
%         2.  vec = v + 2*[ -( q(4) * qv ) + (q(1:3) x qv) ]
% 
% Input:
%    q   : (4xn or 4x1) quaternion(s)    [ndim]
%    v   : (3xn or 3x1) input vector(s)  [ndim]
%
% OUTPUT:
%    vec : (3xn) product vector(s)       [ndim]
%
% PROTOTYPE:
%    q     = [[0;1;0;0], [1;0;0;0]];
%    v     = [[1;0;0], [2;0;0]];
%    [vec] = quat_times_vector(q,v)
% 
% Prototype:
%     vec = quat_times_vector([0; 0; 0; 1], [1; 1; 1]);
%
% Notes:
%     1.  If 'q' is an inertial-to-body quaternion and 'v' is the inertial-frame vector, then the
%         result will be the body-frame vector.
%     2.  This function is redundant with quat_times_single_vector.  Maybe keep just this one?
%     3.  Would really like to have only one branch that handles all three cases relatively quickly.
% 
% Change Log:
%     1.  Originally written by Bruce Romney.
%     2.  Added to DStauffman's Library in March 2008.

% Get the size of the vectors and quaternions
num_q = size(q,2);
num_v = size(v,2);

% One or more quaternions, but only one vector.
if num_v == 1
    qv = [q(2,:)*v(3)-q(3,:)*v(2); ...
          q(3,:)*v(1)-q(1,:)*v(3); ...
          q(1,:)*v(2)-q(2,:)*v(1)];
    vec = v*ones(1,num_q) + 2*(-(ones(3,1)*q(4,:)) .* qv + ...
        [q(2,:).*qv(3,:)-q(3,:).*qv(2,:);...
         q(3,:).*qv(1,:)-q(1,:).*qv(3,:);...
         q(1,:).*qv(2,:)-q(2,:).*qv(1,:)]);
% One quaternion, multiple vectors.
elseif num_q == 1
    qv = [q(2)*v(3,:)-q(3)*v(2,:); ...
         q(3)*v(1,:)-q(1)*v(3,:); ...
         q(1)*v(2,:)-q(2)*v(1,:)];
    vec = v + 2*(-q(4) * qv + ...
        [q(2)*qv(3,:)-q(3)*qv(2,:);...
         q(3)*qv(1,:)-q(1)*qv(3,:);...
         q(1)*qv(2,:)-q(2)*qv(1,:)]);
% Multiple quaternions, multiple vectors.
else
    qv = [q(2,:).*v(3,:)-q(3,:).*v(2,:); ...
         q(3,:).*v(1,:)-q(1,:).*v(3,:); ...
         q(1,:).*v(2,:)-q(2,:).*v(1,:)];
    vec = v + 2*(-(ones(3,1)*q(4,:)) .* qv + ...
        [q(2,:).*qv(3,:)-q(3,:).*qv(2,:);...
         q(3,:).*qv(1,:)-q(1,:).*qv(3,:);...
         q(1,:).*qv(2,:)-q(2,:).*qv(1,:)]);
end