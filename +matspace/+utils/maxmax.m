function [result] = maxmax(x, dim)

% MAXMAX  Maximum over multiple dimensions.
%
% Summary:
%     maxmax(x) will return a scalar that is the maximum over all the elements
%     of x, regardless of dimensionality.
%
%     maxmax(x, dim) operates along the dimensions specified in dim.
%
%     Example: if X is 3x4x2, then
%         maxmax(X) is the maximum over all three dimensions, but
%         maxmax(X, [1 3]) will return a 1x4 vector.
%
% Input:
%     x      : matrix to be maxed
%     dim    : |opt| dimensions of x upon which to operate
%
% Output:
%     result : scalar maximum of x, unless optional dim was provided, in
%              which case the dimensions are determined by the dimensions not
%              maximized over.
%
% Prototype:
%     result = matspace.utils.maxmax([1 2 3; 4 -100 10]);
%     assert(result == 10);
%
% See Also:
%     max, matspace.utils.minmin
%
% Change Log:
%     1.  Written by Keith Rogers for SSC Toolbox, last updated Feb 2012.
%     2.  Incorporated by David C. Stauffer into matspace library in Nov 2016.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.

% Not EML Compliant due to for loop (Dimension argument must be constant)

% get sizes of all dimensions of x
d = size(x);

% check for optional inputs
switch nargin
    case 1
        % find all non-singelton dimensions
        dim = find(d > 1);
        if length(d) < 2
            % Simple vector input case
            result = max(x);
            return
        end
    case 2
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% preallocate to input, for case where no dimensions are specified
result = x;

% loop through and shrink to max of each dimension in sequence
for i = dim
    result = max(result,[],i);
end