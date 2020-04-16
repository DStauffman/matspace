function qout = quat_interp(t, q, ti, inclusive) %#codegen

% QUAT_INTERP  interpolate quaternions from a monotonic time series of quaternions.
%
% Summary:
%     Performs interpolation where t must be monotonically increasing, and
%     ti must be in the interval specified by t, unless inclusive is false.
%
% Input:
%     t         : (1xA) monotonically increasing time series [sec]
%     q         : (4xA) quaternion series [ndim] see note 1
%     ti        : (1xB) time of interpolation [sec]
%     inclusive : |opt| (scalar) true/false flag to only allow ti inclusion within the bounds of t [bool]
%
% Output:
%     qout      : (4xB) interpolated quaternion at ti [ndim] see note 1
%
% Prototype:
%     t  = [1,3,5];
%     q  = [[0;0;0;1],[0;0;0.1961;0.9806],[0.5;-0.5;-0.5;0.5]];
%     ti = [1 2 4.5 5];
%     matspace.quaternions.quat_interp(t,q,ti)
%
% See Also:
%     matspace.quaternions.quat_interp_single
%
% Notes:
%     1.  All quaternions are [x;y;z;s].
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS(Romney, Hull), GARSE (Sims, Stauffer, Beck)
%     2.  Updated per by Scott Sims and David C. Stauffer in June 2009.
%     3.  Optimizing by David C. Stauffer in Oct 2013 for case where you already have
%         most of your desired time points.
%     4.  Incorporated by David C. Stauffer into matspace in Nov 2016.
%     5.  Updated by David C. Stauffer in April 2020 to put into a package.

%% Imports
import matspace.quaternions.quat_inv
import matspace.quaternions.quat_mult
import matspace.quaternions.quat_norm

%% Initializations
% number of data points to find
num   = length(ti);

% initialize output
qout  = nan(4,num);

% optional inputs
switch nargin
    case 3
        inclusive = false;
    case 4
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

%% Scalar case
% optimization for simple use case(s), where ti is a scalar and contained in t
switch num
    case 0
        return
    case 1
        ix = find(ti == t,1,'first');
        if ~isempty(ix)
            qout = q(:,ix);
            return
        end
    otherwise
        % nop
end

%% Check time bounds
% check for desired times that are outside the time vector
ix_exclusive = ti < t(1) | ti > t(end);
if any(ix_exclusive)
    if inclusive
        warning('matspace:QuatInterpExtrap','Desired time not found within input time vector.');
    else
        error('matspace:QuatInterpExtrap', 'Desired time not found within input time vector.');
    end
end

%% Given times
% find desired points that are contained in input time vector
[ix_known,ix_input] = ismember(ti,t);

% set quaternions directly to known values
qout(:,ix_known) = q(:,ix_input(ix_known));

% find other points to be calculated
ix_calc = ~ix_known & ~ix_exclusive;

%% Calculations
% find index within t to surround ti
index = nan(1,num);
% If not compiling, then you can do a for i = find(ix_calc) and skip the if ix_calc(i) line,
% which may make the non-compiled matlab version faster
for i = find(ix_calc)
    temp = find(ti(i) <= t,1,'first');
    if temp(1) ~= 1
        index(i) = temp(1);
    else
        index(i) = temp(1) + 1;
    end
end
% If you want to compile this function, then you need this instead of the last for loop,
% plus a coder.extrinsic('warning') line.  These are not kept, because it makes the MATLAB-only
% version less efficient:
% for i = 1:length(ix_calc)
%     if ix_calc(i)
%         temp = find(ti(i) <= t,1,'first');
%         if temp(1) ~= 1
%             index(i) = temp(1);
%         else
%             index(i) = temp(1) + 1;
%         end
%     end
% end

% remove points that are NaN, either they weren't in the time vector, or they were next to a drop out
% and cannot be interpolated.
index(isnan(index)) = [];
% pull out bounding times and quaternions
t1 = t(index-1);
t2 = t(index);
q1 = q(:,index-1);
q2 = q(:,index);
% calculate delta quaternion
dq12       = quat_norm(quat_mult(q2,quat_inv(q1)));
% find delta quaternion axis of rotation
vec        = dq12(1:3,:);
norm_vec   = realsqrt(sum(vec.^2));
% check for zero norm vectors
norm_fix   = norm_vec;
norm_fix(norm_fix == 0) = 1;
ax         = bsxfun(@rdivide,vec,norm_fix);
% find delta quaternion rotation angle
ang        = 2*asin(norm_vec);
% scale rotation angle based on time
scaled_ang = ang.*(ti(ix_calc)-t1)./(t2-t1);
% find scaled delta quaternion
dq         = [bsxfun(@times,ax,sin(scaled_ang/2)); cos(scaled_ang/2)];
% calculate desired quaternion
qout_temp  = quat_norm(quat_mult(dq,q1));
% store into output structure
qout(:,ix_calc) = qout_temp;

%% Sign convention
% Enforce sign convention on scalar quaternion element.
% Scalar element (fourth element) of quaternion must not be negative.
% So change sign on entire quaternion if qout(4) is less than zero.
qout(:,qout(4,:) < 0) = -qout(:,qout(4,:) < 0);