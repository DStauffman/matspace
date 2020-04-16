function y = rms(x, dim) %#codegen

% RMS  calculates the real or imaginary Root Mean Square.
%
% Summary:
%     This function can handle input x of multiple dimension. The output y
%     will be sized based on the size of x and the dim input which specifies
%     the dimension along which the RMS is taken. This is illustrated
%     in the cases below.
%
% Input:
%     x   : (arbitrary) Input data [num]
%     dim : |opt| (scalar) dimension to take RMS along [num], defaults to first non-singular
%
% Output:
%     y   : (arbitrary) root mean square value of data [num]
%
% Prototype:
%     x   = [1 6 -2 9  5 -4 3 2;...
%            2 3  6 4 -9  7 5 1];
%     dim = 2;
%     y   = matspace.utils.rms(x,dim);
%
% See Also:
%     matspace.utils.unit, rms
%
% Change Log:
%     1.  Added to matspace library from GARSE in Sept 2013.
%     2.  Updated to match simpler code that is part of Matlab R2016A, but maintained to avoid
%         limitation of needing the signal_toolbox.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.

% use with or without dim command
if nargin == 1
    y = sqrt(mean(x .* conj(x)));
else
    y = sqrt(mean(x .* conj(x), dim));
end