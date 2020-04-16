function [dcm] = quat_to_dcm(q) %#codegen

% QUAT_TO_DCM  convert quaternion to a direction cosine matrix.
%
% Input:
%     q   :   (4x1) quaternion [ndim]
%
% Output:
%     dcm :   (3x3) direction cosine matrix [ndim]
%
% Prototype:
%     q   = [0.5; -0.5; 0.5; 0.5];
%     dcm = matspace.quaternions.quat_to_dcm(q)
%
% See Also:
%     matspace.quaternions.quat_mult, matspace.quaternions.quat_inv, matspace.quaternions.quat_norm,
%     matspace.quaternions.quat_prop, matspace.quaternions.quat_times_vector,
%     matspace.quaternions.quat_to_euler, matspace.quaternions.quat_from_euler
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS (Romney, Hull), GARSE (Sims, Stauffer, Beck)
%     2.  Updated by Matt Beck in June 2009.
%     3.  Updated by Tom Trankle in July 2011 for #eml support.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

% build dcm components
dcm      = zeros(3);
dcm(1,1) = q(4)^2+q(1)^2-q(2)^2-q(3)^2;
dcm(1,2) = 2*(q(1)*q(2)+q(3)*q(4));
dcm(1,3) = 2*(q(1)*q(3)-q(2)*q(4));
dcm(2,1) = 2*(q(1)*q(2)-q(3)*q(4));
dcm(2,2) = q(4)^2-q(1)^2+q(2)^2-q(3)^2;
dcm(2,3) = 2*(q(2)*q(3)+q(1)*q(4));
dcm(3,1) = 2*(q(1)*q(3)+q(2)*q(4));
dcm(3,2) = 2*(q(2)*q(3)-q(1)*q(4));
dcm(3,3) = q(4)^2-q(1)^2-q(2)^2+q(3)^2;