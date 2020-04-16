function [f,fib] = fibinacci(x)

% FIBINACCI  calculates the xth fibinacci number non-recursively.
%
% Input:
%     x   : Fibinacci number to calculate [num]
%
% Output:
%     f   : Desired fibinacci number [num]
%     fib : (1xN) Series of the fibinacci numbers up to the one specified [num]
%
% Prototype:
%     [f, fib] = matspace.utils.fibinacci(10);
%     assert(f == 55);
%     assert(all(fib == [0 1 1 2 3 5 8 13 21 34 55]));
%
% See Also:
%     sum, cumsum
%
% Notes:
%     1.  This implementation is non-recursive, and instead uses a built-in for loop.
%
% Change Log:
%     1.  Written by David C. Stauffer circa 2010.
%     2.  Incorporated into matspace library in Nov 2016.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.

% deal with simple special cases
if x == 0
    fib = 0;
elseif x == 1
    fib = [0 1];
else
    % general case
    fib = zeros(1,x+1);
    fib(2) = 1;
    % after setting up the first two values, use them to calculate the next ones
    for i = 3:x+1
        fib(i) = fib(i-2) + fib(i-1);
    end
end

% return the final value
f = fib(end);