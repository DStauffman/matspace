function q = quat_from_euler(angles, seq)

% QUAT_FROM_EULER  convert set(s) of euler angles to quaternion(s).
%
% Summary:
%     Assumes angles are of (3 1 2) euler order and converts accordingly unless the
%     optional "seq" argument defines a different euler order. This function will
%     also take more than three angle sequences if desired.
%
% Input:
%             Where A = number of successive rotations, N = number of sequences to output - see note 1
%     angles :            (AxN)          euler angles [radians]
%             Where: 1 = X axis, or roll
%                    2 = Y axis, or pitch
%                    3 = Z axis, or yaw
%     seq    : |OPTIONAL| (1xA) or (Ax1) euler angle sequence [enumerated numeric] - see note 2
%
% Output:
%     dq     : (4xN) x,y,z,s quaternions [dimensionless]
%
% Prototype:
%     a   = [0.01; 0.02; 0.03];
%     b   = [0.04; 0.05; 0.06];
%     seq = [3 2 1];
%     quat_from_euler([a,b],seq)
%
% See Also:
%     dcm_to_quat, quat_to_euler
%
% Notes:
%     1.  This function will take one angle sequence, but an arbitrary number of angles.
%     2.  Enumerated values are some selective permutation of (1 2 3) without successive
%         repetition such as (3 1 2) or (3 1 3) but not (3 1 1) wherein 1 1 is a successive
%         repetition.  By default, it expects 3 1 2.
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS (Romney, Hull), GARSE (Sims, Stauffer)
%     2.  Updated per PGPR_1001 2009 June (Sims)
%     3.  Updated by David Stauffer in Jan 2010 for PGPR_1036.
%     4.  Incorporated by David C. Stauffer into DStauffman tools in Nov 2016.

% set default euler order
switch nargin
    case 1
        seq = [3 1 2];
    case 2
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% execute algorithm
n = size(angles,2);
q = zeros(4,n);

% loop through quaternions
for i=1:n
    q_temp = [0; 0; 0; 1];
    % apply each rotation
    for j=1:length(seq)
        q_single = qrot(seq(j),angles(j,i));
        q_temp = quat_mult(q_temp,q_single);
    end
    % save output
    q(:,i) = q_temp;
end