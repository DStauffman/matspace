function [out] = where(bool, a, b)

% WHERE  returns one of two values, based on the given boolean field.
%
% Input:
%     bool : (AxB) boolean array saying when to use a
%     a    : (AxB) array of values to use when boolean is true
%     b    : (AxB) array of values to use when boolean is false
%
% Output:
%     out  : (AxB) array of values output as appropriate
%
% Prototype:
%     bool = [true false false true];
%     a    = [1 3 5 7];
%     b    = [-2 -4 -6 -8];
%     out  = matspace.utils.where(bool, a, b);
%     assert(all(out == [1 -4 -6 7]));
%
% Notes:
%     1.  This function does not short-circuit.  `b` must be evaluated even when `bool` is true.
%
% Change Log:
%     1.  Written by David C. Stauffer in July 2019.  Inspired by the Python numpy.where function.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

% check inputs
assert(numel(bool) == numel(a), 'Input a (%i) must have the same number of elements as bool (%i).', numel(a), numel(bool));
assert(numel(bool) == numel(b), 'Input b (%i) must have the same number of elements as bool (%i).', numel(b), numel(bool));

% initialize the whole array to input 'b'
out = b;
% override where told with input 'a'
out(bool) = a(bool);