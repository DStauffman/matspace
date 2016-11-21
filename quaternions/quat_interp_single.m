function [qout] = quat_interp_single(t, q, ti) %#codegen

% QUAT_INTERP  interpolate a quaternion from a monotonic time series of quaternions.
%
% Summary:
%     Performs interpolation where t must be monotonically increasing, and
%     ti must be in the interval specified by t.
%
% Input:
%     t    : (1x2) monotonically increasing time series [sec]
%     q    : (4x2) quaternion series [ndim] see note 1
%     ti   : (scalar) time of interpolation [sec]
%
% Output:
%     qout : (4x1) interpolated quaternion at ti [ndim] see note 1
%
% Prototype:
%     t = [1,5];
%     q = [[0;0;0;1],[0.5;-0.5;-0.5;0.5]];
%     quat_interp_single(t,q,3)
%
% See Also:
%     quat_interp
%
% Notes:
%     1.  All quaternions are [x;y;z;s].
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS(Romney, Hull), GARSE (Sims, Stauffer, Beck)
%     2.  Updated per PGPR_1001 2009 June (Sims and Stauffer)
%     3.  Incorporated by David C. Stauffer into DStauffman tools in Nov 2016.

% check for desired times that are outside the time vector
if ti < t(1) || ti > t(end)
    error('dstauffman:QInterpBadTimeBounds', 'Desired time not found within input time vector.');
end

% pull out bounding times and quaternions
t1 = t(1);
t2 = t(2);
q1 = q(:,1);
q2 = q(:,2);

% calculate delta quaternion
dq12       = quat_mult_single(q2,quat_inv(q1));
% find delta quaternion axis of rotation
vec        = dq12(1:3,:);
norm_vec   = realsqrt(sum(vec.^2));
% check for zero norm vectors
norm_fix   = norm_vec;
norm_fix(norm_fix == 0) = 1;
ax         = vec/norm_fix;
% find delta quaternion rotation angle
ang        = 2*asin(norm_vec);
% scale rotation angle based on time
scaled_ang = ang*(ti-t1)/(t2-t1);
% find scaled delta quaternion
dq         = [ax*sin(scaled_ang/2); cos(scaled_ang/2)];
% calculate desired quaternion
qout       = quat_mult_single(dq,q1);

% Enforce sign convention on scalar quaternion element.
% Scalar element (fourth element) of quaternion must not be negative.
% So change sign on entire quaternion if qout(4) is less than zero.
if qout(4) < 0
    qout   = - qout;
end