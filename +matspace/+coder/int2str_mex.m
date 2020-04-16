function [s] = int2str_mex(n)

% Coder compatible version of int2str.
%
% Input:
%     n : (scalar) integer
%
% Output:
%     s : (row) string representation
%
% Prototype:
%     s = matspace.coder.int2str_mex(105);
%     assert(strcmp(s, '105'));
%
% Change Log:
%     1.  Written by David C. Stauffer in November 2017.
%     2.  Moved to package by David C. Stauffer in April 2020.

% initialize output
s = '';

% determine the sign
is_neg = n < 0;

% convert to always positive
n = abs(n);

% loop through digits
while n > 0
    % get the current digit
    c = mod( n, 10 ); % get current character
    % convert to a string and append
    s = [uint8(c+'0'),s]; %#ok<AGROW>
    % reduce dimension
    n = ( n -  c ) / 10;
end

% potentially add the sign
if is_neg
    s = ['-', s];
end