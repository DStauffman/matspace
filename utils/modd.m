function [out] = modd(x,y)

% MODD is a version of mod(x,y) that returns y instead of 0 when x = n*y.
%
% Input:
%     x : (AxB) input values
%     y : (scalar) or (AxB) modulo value
%
% Output:
%     out : (AxB) modulus after division
%
% Prototype:
%     x   = [0 1 2 3 4 5 6 7 8];
%     y   = 4;
%     out = modd(x, y);
%     assert(all(out == [4 1 2 3 4 1 2 3 4]));
%
% See Also:
%     mod
%
% Change Log:
%     1.  Written by David Stauffer in June 2013.
%     2.  Added to DStauffman MATLAB library in December 2015.

% calculate the shifted modulus
out = mod(x-1, y) + 1;