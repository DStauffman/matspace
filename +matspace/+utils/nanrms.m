function y = nanrms(x, dim, all_nan_value) %#codegen

% NANRMS  calculates the real or imaginary Root Mean Square while ignoring NaNs.
%
% Summary:
%     This function can handle input x of multiple dimension. The output y
%     will be sized based on the size of x and the dim input which specifies
%     the dimension along which the RMS is taken.
%
% Input:
%     x   : (arbitrary) Input data [num]
%     dim : |opt| (scalar) dimension to take RMS along [num], defaults to first non-singular
%     all_nan_value : |opt| (scalar) value to use when all inputs are NaN, defaults to NaN
%
% Output:
%     y   : (arbitrary) root mean square value of data [num]
%
% Prototype:
%     data  = [1 6 -2 nan 5 -4 3 2; 2 3 6 4 -9 nan 5 1];
%     dim   = 2;
%     value = matspace.utils.nanrms(data,dim);
%     assert(value(1) == rms(data(1,~isnan(data(1,:))), dim));
%     assert(value(2) == rms(data(2,~isnan(data(2,:))), dim));
%
% See Also:
%     rms, matspace.utils.nanmean
%
% Change Log:
%     1.  Written by David C. Stauffer in September 2017.
%     2.  Updated by David C. Stauffer in February 2019 to potentially replace NaN results with a
%         specified value.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.

% Imports
import matspace.utils.nanmean

% optional inputs
switch nargin
    case 1
        dim = [];
        all_nan_value = nan;
    case 2
        all_nan_value = nan;
    case 3
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% use with or without dim command and have nanmean do the heavy lifting
if isempty(dim)
    y = sqrt(nanmean(x .* conj(x)));
else
    y = sqrt(nanmean(x .* conj(x), dim));
end

% replace remaining NaNs with some other value (like zero)
if ~isnan(all_nan_value)
    y(isnan(y)) = all_nan_value;
end