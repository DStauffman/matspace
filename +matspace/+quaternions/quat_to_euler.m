function [euler] = quat_to_euler(q,seq)

% QUAT_TO_EULER  converts quaternion to Euler angles for 6 input angle sequences.
%
% Input:
%     q       : (4xN) x,y,z,s quaternion     [dimensionless]
%                     Where: 1 = X axis, or roll
%                            2 = Y axis, or pitch
%                            3 = Z axis, or yaw
%     seq     : (1x3) euler angle sequence   [enumerated]
%                     enumerated options are ([1 2 3]
%                                            [2 3 1]
%                                            [3 1 2]
%                                            [1 3 2]
%                                            [2 1 3]
%                                            [3 2 1])
%
% Output:
%     euler   : (3xN) Euler angles [radians]
%
% Prototype:
%     q(:,1) = [ 0;1;0;0];
%     q(:,2) = [ 0;0;1;0];
%     seq    = [3 1 2];
%     euler  = matspace.quaternions.quat_to_euler(q,seq)
%
% See Also:
%     matspace.quaternions.quat_mult, matspace.quaternions.quat_inv, matspace.quaternions.quat_norm,
%     matspace.quaternions.quat_prop, matspace.quaternions.quat_times_vector,
%     matspace.quaternions.quat_from_euler
%
% Reference:
%     1.  See Appendix E of Wertz, page 764. Also Appendix I of Kane, Likins, and Levinson, page 423
%
% Notes:
%     1.  Default rotation axis order used is 3-1-2, or yaw, roll, pitch.
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS (Romney, Hull), GARSE (Sims, Stauffer, Beck)
%     2.  Updated by Matt Beck in June 2009.
%     3.  Incorporated by David C. Stauffer into matspace in Nov 2016.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

% Imports
import matspace.quaternions.quat_to_dcm

% set default euler order
switch nargin
    case 1
        seq = [3 1 2];
    case 2
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% initialize output
n     = size(q,2);
euler = zeros(3,n);

%% Loop through quaternions
for i = 1:n
    % calculate DCM from quaternion
    C = quat_to_dcm(q(:,i));
    % Find values of dir cosine matrix terms
    seq_str = [int2str(seq(1)),int2str(seq(2)),int2str(seq(3))];
    % calculate terms based on sequence order
    switch seq_str
        case '123'
            %Identical to KLL pg 423
            group                     =  1;
            c2_c3                     =  C(1,1);
            s1_s2_c3_plus_s3_c1       =  C(2,1);
            minus_c1_s2_c3_plus_s3_s1 =  C(3,1);
            minus_c2_s3               =  C(1,2);
            minus_s1_s2_s3_plus_c3_c1 =  C(2,2);
            c1_s2_s3_plus_c3_s1       =  C(3,2);
            s2                        =  C(1,3);
            s1_c2                     =  C(2,3);
            c1_c2                     =  C(3,3);
        case '231'
            group                     =  1;
            c1_c2                     =  C(1,1);
            minus_c1_s2_c3_plus_s3_s1 =  C(1,2);
            c1_s2_s3_plus_c3_s1       =  C(1,3);
            s2                        =  C(2,1);
            c2_c3                     =  C(2,2);
            minus_c2_s3               =  C(2,3);
            s1_c2                     =  C(3,1);
            s1_s2_c3_plus_s3_c1       =  C(3,2);
            minus_s1_s2_s3_plus_c3_c1 =  C(3,3);
        case '312'
            group                     =  1;
            s1_s2_c3_plus_s3_c1       =  C(1,3);
            minus_c1_s2_c3_plus_s3_s1 =  C(2,3);
            minus_c2_s3               =  C(3,1);
            minus_s1_s2_s3_plus_c3_c1 =  C(1,1);
            c1_s2_s3_plus_c3_s1       =  C(2,1);
            s2                        =  C(3,2);
            s1_c2                     =  C(1,2);
            c1_c2                     =  C(2,2);
            c2_c3                     =  C(3,3);
        case '132'
            group                     =  2;
            c2_c3                     =  C(1,1);
            minus_c1_s2_c3_plus_s3_s1 =  C(2,1);
            s1_s2_c3_plus_s3_c1       = -C(3,1);
            s2                        = -C(1,2);
            c1_c2                     =  C(2,2);
            s1_c2                     =  C(3,2);
            minus_c2_s3               = -C(1,3);
            c1_s2_s3_plus_c3_s1       = -C(2,3);
            minus_s1_s2_s3_plus_c3_c1 =  C(3,3);
        case '213'
            group                     =  2;
            s1_s2_c3_plus_s3_c1       = -C(1,2);
            minus_c1_s2_c3_plus_s3_s1 =  C(3,2);
            minus_c2_s3               = -C(2,1);
            minus_s1_s2_s3_plus_c3_c1 =  C(1,1);
            c1_s2_s3_plus_c3_s1       = -C(3,1);
            s2                        = -C(2,3);
            s1_c2                     =  C(1,3);
            c1_c2                     =  C(3,3);
            c2_c3                     =  C(2,2);
        case '321'
            group                     =  2;
            s1_s2_c3_plus_s3_c1       = -C(2,3);
            minus_c1_s2_c3_plus_s3_s1 =  C(1,3);
            minus_c2_s3               = -C(3,2);
            minus_s1_s2_s3_plus_c3_c1 =  C(2,2);
            c1_s2_s3_plus_c3_s1       = -C(1,2);
            s2                        = -C(3,1);
            s1_c2                     =  C(2,1);
            c1_c2                     =  C(1,1);
            c2_c3                     =  C(3,3);
        otherwise
            error('matspace:QuatBadEulerSequence', 'Invalid axis rotation sequence: "%s".', seq_str);
    end

    %% Compute angles
    if s1_c2 == 0 && c1_c2 == 0
        theta1 = 0;
    else
        if group == 1
            theta1 = atan2(-s1_c2,c1_c2);
        else
            theta1 = atan2( s1_c2,c1_c2);
        end
    end
    %compute sin and cos
    s1 = sin(theta1);
    c1 = cos(theta1);
    %build remaining thetas
    s3     = s1_s2_c3_plus_s3_c1*c1       +  minus_c1_s2_c3_plus_s3_s1*s1;
    c3     = minus_s1_s2_s3_plus_c3_c1*c1 +        c1_s2_s3_plus_c3_s1*s1;
    theta3 = atan2(s3,c3);
    c2     = c2_c3*c3 - minus_c2_s3*s3;
    theta2 = atan2(s2,c2);

    %% Store output
    euler(:,i) = [theta1;theta2;theta3];
end