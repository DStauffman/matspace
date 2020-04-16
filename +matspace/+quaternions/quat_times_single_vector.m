function [vec] = quat_times_single_vector(q, v)

% QUAT_TIMES_SINGLE_VECTOR  multiply one or more quaternions against a single vector.
%
% Summary:
%     Method
%         1.  qv = q(1:3) x v
%         2.  vec = v + 2*[ -( q(4) * qv ) + (q(1:3) x qv) ]
%
% Input:
%     q   : (4xN) x,y,z,s unit quaternions [dimensionless]
%     v   : (3x1) unit vector [dimensionless]
%
% Output:
%     vec : (3xN) vector [dimensionless]
%
% Prototype:
%     vec = matspace.quaternions.quat_times_single_vector([[0; 0; 0; 1], [0.5; 0.5; 0.5; 0.5]], [1; 0; 0])
%
% See Also:
%     matspace.quaternions.quat_times_vector
%
% Notes:
%     1.  Method is for one or more quaternions, but only one vector.
%     2.  If 'q' is an inertial-to-body quaternion and 'v' is the inertial-frame vector, then the
%         results will be the body-frame vector.
%
% Change Log:
%     1.  lineage: GARSE (Sims, Stauffer, Davis, Beck)
%     2.  Updated by Scott Sims in June 2009.
%     3.  Incorporated by David C. Stauffer into matspace in Nov 2016.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

% get number of quaternions
num_q = size(q,2);

% build first cross product vector
qv = [q(2,:)*v(3)-q(3,:)*v(2); ...
      q(3,:)*v(1)-q(1,:)*v(3); ...
      q(1,:)*v(2)-q(2,:)*v(1)];

% build combined vector
vec = v*ones(1,num_q) + 2*(-([1;1;1]*q(4,:)) .* qv + ...
     [q(2,:).*qv(3,:)-q(3,:).*qv(2,:);...
      q(3,:).*qv(1,:)-q(1,:).*qv(3,:);...
      q(1,:).*qv(2,:)-q(2,:).*qv(1,:)]);