function [t] = rot(k,a) %#codegen

% ROT  direction cosine matrix for rotation about a single axis.
%
% Input:
%     k : (scalar) axis about which rotation is being made [enum]
%                  enumerated choices are (1, 2, or 3)
%                  corresponding to        x, y, or z axis
%     a : (scalar) angle of rotation                       [radi]
%
% Output:
%     t : (3x3) direction cosine matrix                    [ndim]
%
% Prototype:
%     % simple 90deg z-rotation
%     k = 3;
%     a = pi/2;
%     t = matspace.quaternions.rot(k,a)
%
% See Also:
%     drot_matlab, quat_to_dcm
%
% Change Log:
%     1.  lineage: HARS (Romney), CARS (Romney, Hull), GARSE (Sims, Stauffer, Beck)
%     2.  Updated by Matt Beck in June 2009.
%     3.  Updated by Tom Trankle in July 2011 for #eml support.
%     4.  Incorporated by David C. Stauffer into matspace in Nov 2016.
%     5.  Updated by David C. Stauffer in April 2020 to put into a package.

% sines of angle
ca = cos(a);
sa = sin(a);

% build direction cosine matrix
switch k
    case 1
        t = [1 0 0; 0 ca sa; 0 -sa ca];
    case 2
        t = [ca 0 -sa; 0 1 0; sa 0 ca];
    case 3
        t = [ca sa 0; -sa ca 0; 0 0 1];
end