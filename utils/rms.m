function y = rms(x,dim)

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
%     y   = rms(x,dim);
%
% See Also:
%     unit
%
% Change Log:
%     1.  Added to DStauffman's library from GARSE in Sept 2013.

% check for simple cases, or when no specified dimension
if nargin == 1
    if isvector(x)
        % simple calculation for vector case
        y   = norm(x)/sqrt(length(x));
        return
    else
        % find dimension to process
        dim = find(size(x)~=1,1,'first');
        if isempty(dim)
            dim = 1;
        end
    end
end
% general case, once dimension is specified
y = realsqrt(sum(x.*conj(x),dim)/size(x,dim));