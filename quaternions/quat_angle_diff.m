function [theta,comp] = quat_angle_diff(q1,q2)

% QUAT_ANGLE_DIFF  calculates the angular difference between two quaternions.
%
% Summary:
%     This function takes a two quaternions and calculates a delta quaternion between them.
%     It then uses the delta quaternion to generate both a total angular difference, and an
%     an angular difference expressed in X,Y,Z components based on the axis of rotation,
%     expressed in the original frame of the q1 input quaternion.  This function uses full
%     trignometric functions instead of any small angle approximations.
%
% Input:
%     q1    : (4xN) quaternion array 1 [ndim]
%     q2    : (4xN) quaternion array 2 [ndim]
%
% Output:
%     theta : (1xN) angular difference [rad]
%     comp  : (3xN) angle components in x,y,z frame [rad]
%
% Prototype:
%     q1    = [0.5;0.5;0.5;0.5];
%     dq1   = qrot(1,0.001);
%     dq2   = qrot(2,0.05);
%     q2    = [quat_mult(dq1,q1),quat_mult(dq2,q1)];
%     theta = quat_angle_diff(q1,q2);
%
% See Also:
%     quat_mult
%
% Reference:
%     This function is based on this representation of a unit quaternion:
%     q = [nx * sin(theta/2);
%          ny * sin(theta/2);
%          nz * sin(theta/2);
%            cos(theta/2)  ];
%     Where: <nx,ny,nz> are the three components of a unit vector of rotation axis and
%            theta is the angle of rotation
%
% Change Log:
%     1.  Written by David Stauffer in Feb 2010.
%     2.  Incorporated by David C. Stauffer into DStauffman tools in Nov 2016.

% calculate delta quaternion
dq = quat_mult(q2, quat_inv(q1));

% pull vector components out of delta quaternion
dv = dq(1:3,:);

% sum vector components to get sin(theta/2)^2
mag2 = sum(dv.^2,1);

% take square root to get sin(theta/2)
mag = realsqrt(mag2);
assert(all(mag <= 1), 'Magnitudes should always be less than or equal to one.');

% take inverse sine to get theta/2
theta_over_2 = asin(mag);

% multiply by 2 to get theta
theta = 2*theta_over_2;

% set any magnitude that is identically 0 to be 1 instead
% to avoid a divide by zero warning.
mag(mag == 0) = 1;

% normalize vector components
nv = bsxfun(@rdivide,dv,mag);

% find angle expressed in x,y,z components based on normalized vector
comp = bsxfun(@times,nv,theta);