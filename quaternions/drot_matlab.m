function [t] = drot_matlab(k,a) %#codegen

% DROT_MATLAB  derivative of transformation matrix for rotation about a single axis.
%
% Input:
%     k : (scalar) axis about which rotation is being made [enumerated number]
%          enumerated values are (1, 2, 3)
%              (1) for x-axis
%              (2) for y-axis
%              (3) for z-axis
%     a : (scalar) angle of rotation [radians]
%
% Output:
%     t : (3x3) direction cosine matrix [dimensionless]
%
% Prototype:
%     % simple 90deg z-rotation
%     k = 3;
%     a = pi/2;
%     t = drot_matlab(k,a)
%
% See Also:
%     rot
%
% Reference:
%     GEO GBARS ADD #2M91279, REV-C, Section 4.3.7, drot_matlab
%
% NOTES:
%     1.  Renamed from drot.m to avoid conflicting with a fortran function in the BLAS library,
%         which was causing weird compliation errors for the Matlab coder.
%
% CHANGE LOG:
%     1.  lineage: HARS (Romney), CARS(Romney, Hull), GARSE (Sims, Stauffer, Beck)
%     2.  Updated by Tom Trankle in July 2011 for #eml.
%     3.  Renamed by David Stauffer in June 2014 to avoid coder bug.
%     4.  Incorporated by David C. Stauffer into DStauffman tools in Nov 2016.

% alias values
ca = cos(a);
sa = sin(a);

% build direction cosine matrix
switch k
    case 1
        t = [0 0 0; 0 -sa ca; 0 -ca -sa];
    case 2
        t = [-sa 0 -ca; 0 0 0; ca 0 -sa];
    case 3
        t = [-sa ca 0; -ca -sa 0; 0 0 0];
    otherwise
        error('dstauffman:InvalidDrotAxis', 'Invalid axis: "%i"', k);
end