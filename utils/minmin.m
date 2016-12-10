function [result] = minmin(x, dim)

% MINMIN  Minimum over multiple dimensions.
%
% Summary:
%     minmin(x) will return a scalar that is the minimum over all the elements
%     of x, regardless of dimensionality.
%
%     minmin(x, dim) operates along the dimensions specified in dim.
%
%     Example: if X is 3x4x2, then
%         minmin(X) is the minimum over all three dimensions, but
%         minmin(X, [1 3]) will return a 1x4 vector.
%
% Input:
%     x      : matrix to be minimized
%     dim    : |opt| dimensions of x upon which to operate
%
% Output:
%     result : scalar minimum of x, unless optional dim was provided, in
%              which case the dimensions are determined by the dimensions not
%              minimized over.
%
% Prototype:
%     result = minmin([1 2 3; 4 -100 10]);
%     assert(result == -100);
%
% See Also:
%     min, maxmax
%
% Change Log:
%     1.  Written by Keith Rogers for SSC Toolbox, last updated Feb 2012.
%     2.  Incorporated by David C. Stauffer into DStauffman library in Nov 2016.

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
            result = min(x);
            return
        end
    case 2
        % nop
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%s"', nargin);
end

% preallocate to input, for case where no dimensions are specified
result = x;

% loop through and shrink to min of each dimension in sequence
for i = dim
    result = min(result, [], i);
end