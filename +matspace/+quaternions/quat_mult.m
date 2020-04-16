function [c] = quat_mult(a,b) %#codegen

% QUAT_MULT  multiply quaternions together.
%
% Input:
%     a  : (4xN) quaternion(s) representing A w/r/t B [ndim]
%     b  : (4xN) quaternion(s) representing B w/r/t C [ndim]
%
% Output:
%     c  : (4xN) quaternion(s) representing A w/r/t C [ndim]
%
% Prototype:
%     a  = [ 0; 0; 0; 1];
%     b  = [ 0; 0; 1; 0];
%     q1 = [ 0.5;-0.5; 0.5; 0.5]
%     q2 = [-0.5; 0.5;-0.5; 0.5]
%     c  = matspace.quaternions.quat_mult([a,q1],[b,q2])
%
% See Also:
%     matspace.quaternions.quat_norm, matspace.quaternions.quat_inv, matspace.quaternions.quat_prop,
%     matspace.quaternions.quat_times_vector, matspace.quaternions.quat_to_dcm,
%     matspace.quaternions.quat_to_euler, matspace.quaternions.quat_from_euler
%
% Notes:
%     Each of (a,b) may be either a single quaternion (4x1) or an array of quaternions (4xn).
%
%     If 'a' and 'b' are both single quaternions, then return b*a. If either (but not both) is an
%     array of quaternions, then return the product of the single quaternion times each element of
%     the array.  If both are rows of quaternions, multiply corresponding columns. 'c' will have
%     size 4x1 in the first case, and 4xn in the other cases.
%
%     The quaternions 'a' and 'b' describe successive reference frame changes, i.e., a is expressed
%     in the coordinate system resulting from b, not in the original coordinate system.  In Don
%     Reid's tutorial, this is called the R- version.
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS (Romney, Hull), GARSE (Sims, Stauffer, Beck).
%     2.  Updated by Matt Beck in June 2009.
%     3.  Incorporated by David C. Stauffer into matspace in Nov 2016.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

% check for vectorized inputs
na = numel(a);
nb = numel(b);

if ((na==4) && (nb==4))
    % single quaternion inputs case
    c = [ a(4)  a(3) -a(2)  a(1); ...
         -a(3)  a(4)  a(1)  a(2); ...
          a(2) -a(1)  a(4)  a(3); ...
         -a(1) -a(2) -a(3)  a(4)] * b;
    if c(4)<0
        c = -c;
    end
else
    % vectorized inputs
    a1 = a(1,:);
    a2 = a(2,:);
    a3 = a(3,:);
    a4 = a(4,:);
    b1 = b(1,:);
    b2 = b(2,:);
    b3 = b(3,:);
    b4 = b(4,:);
    c = [ b1.*a4 + b2.*a3 - b3.*a2 + b4.*a1; ...
         -b1.*a3 + b2.*a4 + b3.*a1 + b4.*a2; ...
          b1.*a2 - b2.*a1 + b3.*a4 + b4.*a3; ...
         -b1.*a1 - b2.*a2 - b3.*a3 + b4.*a4];
    % enforce positive sign on scalar component
    c(:,c(4,:)<0) = -c(:,c(4,:)<0);
end