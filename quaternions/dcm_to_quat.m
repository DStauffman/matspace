function [q] = dcm_to_quat(dcm)

% DCM_TO_QUAT  convert a direction cosine matrix to a quaternion.
%
% Input:
%     dcm : (3x3xN) or (9xN) direction cosine matrix [ndim] see note 1
%
% Output:
%     q   : (4xN) x,y,z,s quaternion [ndim]
%                 where the scalar element of the quaternion "s" or
%                 q(4) will always be greater than or equal to zero
%
% Prototype:
%     dcm = [1 0 0; 0 cos(pi/3) sin(pi/3); 0 -sin(pi/3) cos(pi/3)];
%     q1  = dcm_to_quat(dcm);
%     q2  = dcm_to_quat(repmat(dcm,[1 1 5]));
%     q3  = dcm_to_quat(repmat(dcm(:),[1 5]));
%
% See Also:
%     quat_to_dcm
%
% Reference:
%     1.  Wertz, James R. (editor), "Spacecraft Attitude Determination and Control,"
%         Section 12.1, "Parameterization of the Attitude", pg 415
%
%     2.  Reid, Donald B., "Conversion from DCM to Euler Parameters,"
%         Section 3.2 of "A Tutorial on Attitude Kinematics Including
%         Quaternions," (unpublished notes), 1980, p. 3-4 to 3-5
%         Paper kept on GN&C Share, \\lmmsgroups\data\GN&C_Share\
%         Located at \\lmmsgroups\data\GN&C_Share\Learning_Lab\Quaternions\Reid1980.PDF in Mar 2010.
%
% Notes:
%     1.  When passing a 9xN DCM, the element order is columnwise per the MATLAB colon (:)
%         operator, i.e. dcm2 = dcm1(:);
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS(Romney, Hull), GARSE (Sims, Stauffer, Beck)
%     3.  Incorporated by David C. Stauffer into DStauffman tools in March 2008.
%     2.  Updated by David Stauffer in Mar 2010 to allow vectorized inputs and outputs.

%% find number of DCMs
[n1,n2,n3] = size(dcm);
if n1 == 3 && n2 == 3
    num     = n3;
    two_dim = false;
elseif n1 == 9 && n3 == 1
    num     = n2;
    two_dim = true;
else
    error('matspace:BadDcmSize', 'Unexpected dimensions for ''dcm''');
end

%% preallocate q
q = zeros(4,num);

%% optimized scalar case for 3x3 DCM (original version of this function)
if num == 1 && ~two_dim
    % Using the method in Don Reid's tutorial, p. 3-5
    t = dcm(1,1) + dcm(2,2) + dcm(3,3);
    q1_sq = (1 + 2*dcm(1,1)-t)/4;
    q2_sq = (1 + 2*dcm(2,2)-t)/4;
    q3_sq = (1 + 2*dcm(3,3)-t)/4;
    q4_sq = (1 + t)/4;
    [~,f] = max([q1_sq q2_sq q3_sq q4_sq]);
    % create quaternion based on largest component
    switch f
        case 1
            q(1) = realsqrt(q1_sq);
            q(2) = (dcm(1,2) + dcm(2,1))/(4*q(1));
            q(3) = (dcm(1,3) + dcm(3,1))/(4*q(1));
            q(4) = (dcm(2,3) - dcm(3,2))/(4*q(1));
        case 2
            q(2) = realsqrt(q2_sq);
            q(1) = (dcm(1,2) + dcm(2,1))/(4*q(2));
            q(3) = (dcm(2,3) + dcm(3,2))/(4*q(2));
            q(4) = (dcm(3,1) - dcm(1,3))/(4*q(2));
        case 3
            q(3) = realsqrt(q3_sq);
            q(1) = (dcm(1,3) + dcm(3,1))/(4*q(3));
            q(2) = (dcm(2,3) + dcm(3,2))/(4*q(3));
            q(4) = (dcm(1,2) - dcm(2,1))/(4*q(3));
        case 4
            q(4) = realsqrt(q4_sq);
            q(1) = (dcm(2,3) - dcm(3,2))/(4*q(4));
            q(2) = (dcm(3,1) - dcm(1,3))/(4*q(4));
            q(3) = (dcm(1,2) - dcm(2,1))/(4*q(4));
    end
    % negate vector as needed such that quaternion scalar component is positive
    if q(4)<0
        q = -q;
    end
else
    %% vectorized version of function, based on HARS code for 'axes_to_quat'
    if two_dim
        x = dcm([1 4 7],:);
        y = dcm([2 5 8],:);
        z = dcm([3 6 9],:);
    else
        x = squeeze(dcm(1,:,:));
        y = squeeze(dcm(2,:,:));
        z = squeeze(dcm(3,:,:));
    end
    t = x(1,:) + y(2,:) + z(3,:);
    % (Using the method in Don Reid's tutorial, p. 3-5)
    q1_sq = (1 + 2*x(1,:)-t)/4;
    q2_sq = (1 + 2*y(2,:)-t)/4;
    q3_sq = (1 + 2*z(3,:)-t)/4;
    q4_sq = (1 + t)/4;
    [~,indx] = max([q1_sq; q2_sq; q3_sq; q4_sq]);
    % create quaternion based on largest component
    % component 1
    f = (indx==1);
    q(1,f) = sqrt(q1_sq(f));
    q(2,f) = (x(2,f) + y(1,f))./(4*q(1,f));
    q(3,f) = (x(3,f) + z(1,f))./(4*q(1,f));
    q(4,f) = (y(3,f) - z(2,f))./(4*q(1,f));
    % component 2
    f = (indx==2);
    q(2,f) = sqrt(q2_sq(f));
    q(1,f) = (x(2,f) + y(1,f))./(4*q(2,f));
    q(3,f) = (y(3,f) + z(2,f))./(4*q(2,f));
    q(4,f) = (z(1,f) - x(3,f))./(4*q(2,f));
    % component 3
    f = (indx==3);
    q(3,f) = sqrt(q3_sq(f));
    q(1,f) = (x(3,f) + z(1,f))./(4*q(3,f));
    q(2,f) = (y(3,f) + z(2,f))./(4*q(3,f));
    q(4,f) = (x(2,f) - y(1,f))./(4*q(3,f));
    % component 4
    f = (indx==4);
    q(4,f) = sqrt(q4_sq(f));
    q(1,f) = (y(3,f) - z(2,f))./(4*q(4,f));
    q(2,f) = (z(1,f) - x(3,f))./(4*q(4,f));
    q(3,f) = (x(2,f) - y(1,f))./(4*q(4,f));
    % negate vector as needed such that quaternion scalar component is positive
    q(:,q(4,:)<0) = -q(:,q(4,:)<0);
end