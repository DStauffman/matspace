function [c] = quat_mult_single(a,b) %#codegen

% QUAT_MULT_SINGLE  multiply two single quaternions together.
%
% Input:
%     a  : (4x1) x,y,z,s quaternion representing A w/r/t B [dimensionless]
%     b  : (4x1) x,y,z,s quaternion representing B w/r/t C [dimensionless]
%
% Output:
%     c  : (4x1) x,y,z,s quaternion representing A w/r/t C [dimensionless]
%
% Prototype:
%     a = [.5;-.5;.5;-.5];
%     b = [-.5;.5;-.5;.5];
%     c = matspace.quaternions.quat_mult_single(a,b)
%
% See Also:
%     matspace.quaternions.quat_mult
%
% Reference:
%     1.  LMSC-D766977, Tutorial on Attitude Kinematics (Including Quaternions),
%         Don Reid, October 1980
%
% Notes:
%     1.  Version optimized for single multiplications
%     2.  the quaternions 'a' and 'b' describe successive reference frame changes,
%         i.e., a is expressed in the coordinate system resulting from b, not in
%         the original coordinate system
%
% Change Log:
%     1.  lineage: GARSE (Sims, Stauffer, Davis, Beck)
%     2.  Updated by Scott Sims in Jun 2009.
%     3.  Incorporated by David C. Stauffer into matspace in Nov 2016.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

% perform multiplication
c = [ a(4)  a(3) -a(2)  a(1); ...
     -a(3)  a(4)  a(1)  a(2); ...
      a(2) -a(1)  a(4)  a(3); ...
     -a(1) -a(2) -a(3)  a(4)] * b;

% force scalar component to be positive
if c(4)<0
    c = -c;
end