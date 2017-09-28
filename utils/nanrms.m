function y = nanrms(x, dim) %#codegen

% NANRMS  calculates the real or imaginary Root Mean Square while ignoring NaNs.
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
%     y   = rms(x,dim);
%
% See Also:
%     rms, nanmean
%
% Change Log:
%     1.  Written by David C. Stauffer in September 2017.

% use with or without dim command
if nargin == 1
    y = sqrt(nanmean(x .* conj(x)));
else
    y = sqrt(nanmean(x .* conj(x), dim));
end