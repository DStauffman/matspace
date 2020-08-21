function [q_A_B,angles,rms_err] = compute_att_fit(q_A,q_B)

% COMPUTE_ATT_FIT  computes the best fit delta quaternion between two quaternion histories.
%
% Summary:
%     This function determines the best fit (based on linear least squares) delta quaternion
%     that rotates from B to A, such that q_A = q_A_B*q_B
%
% Input:
%     q_A : (4xN) quaternion in frame A [ndim]
%     q_B : (4xN) quaternion in frame B [ndim]
%
% Output:
%     q_A_B   : (4x1) best fit delta quaternion from B to A [ndim]
%     angles  : (3x1) angle offsets (from A to B) of best fit delta quaternion. Angles correspond to conjugate of the quaternion. [rad]
%     rms_err : (1x1) root mean square error of best fit delta quaternion [rad]
%
% Prototype:
%     q_B        = repmat([0.5; 0.5;-0.5; 0.5],[1 10]);
%     % Angle of rotation to A from B
%     angle_true = [0.01; 0.1; -0.5];
%     seq        = [1 2 3];
%     q_A_B_true = matspace.quaternions.quat_from_euler(-angle_true, seq);
%     q_A        = matspace.quaternions.quat_mult(q_A_B_true, q_B);
%     [q_A_B_estm, angle_estm, rms_err] = matspace.quaternions.compute_att_fit(q_A, q_B)
%     % Compare estimated to true:
%     [q_A_B_estm, q_A_B_true, q_A_B_estm-q_A_B_true]
%     [angle_estm, angle_true, angle_estm-angle_true]
%
% See Also:
%     matspace.quaternions.quat_mult
%
% Change Log:
%     1.  Written by David C. Stauffer in Aug 2011 based on a routine from Evert Cooper.
%     2.  Updated by David C. Stauffer in Apr 2012 to incorporate comments from Tom Trankle
%         to clarify the order of inputs/output quaternion frames.
%     3.  Incorporated by David C. Stauffer into matspace in Nov 2016.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

% Imports
import matspace.quaternions.quat_angle_diff
import matspace.quaternions.quat_mult
import matspace.quaternions.quat_norm
import matspace.quaternions.quat_to_euler

% alias number of output arguments
num_out = nargout;

% remove NaNs from data
dropped_data = 0;
ix_nan_A = isnan(q_A(1,:));
if any(ix_nan_A)
    q_A = q_A(:,~ix_nan_A);
    q_B = q_B(:,~ix_nan_A);
end
ix_nan_B = isnan(q_B(1,:));
if any(ix_nan_B)
    q_A = q_A(:,~ix_nan_B);
    q_B = q_B(:,~ix_nan_B);
end
if dropped_data > 0
    warning('matspace:QuatAttFitNans', 'Dropped %i quaternions from fit calculations.', dropped_data);
end

% find number of points
n = size(q_A,2);
% check for consistency
if n ~= size(q_B,2)
    error('matspace:QuatAttBadSize', 'Unevely sized quaternions.');
end

% create linear system
R = [q_A(4,:); q_A(3,:); -q_A(2,:); -q_A(1,:); -q_A(3,:); q_A(4,:); q_A(1,:); -q_A(2,:); ...
    q_A(2,:); -q_A(1,:); q_A(4,:); -q_A(3,:); q_A(1,:); q_A(2,:); q_A(3,:); q_A(4,:) ];
A = reshape(R,[4 4 n]);
A = reshape(permute(A,[1 3 2]),[4*n 4]);
B = q_B(:);

% solve for best fit and re-normalize
%  Note: this looks a bit strange. We are computing q A/B. But we are
%  implementing what amounts to a B/A operation to do it.
q_A_B = quat_norm(A\B);
% flip vector of rotation
q_A_B(1:3) = -q_A_B(1:3);

% if desired, calculate the additional outputs
if num_out >= 2
    % calculate angle offsets
    angles = quat_to_euler(q_A_B,[1 2 3]);
end

if num_out >= 3
    % calculate the rms error
    q_A_est   = quat_mult(q_A_B,q_B);
    angle_err = quat_angle_diff(q_A,q_A_est);
    rms_err   = rms(angle_err,2);
end