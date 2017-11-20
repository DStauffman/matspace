function [s] = int2str2(n)

% Coder compatible version of int2str.

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