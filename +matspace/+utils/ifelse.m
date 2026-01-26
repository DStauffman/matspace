function [out] = ifelse(bool, a, b)

% WHERE  returns one of two values, based on the given boolean field and is vectorized.
%
% Input:
%     bool : (1x1) boolean saying when to use a
%     a    : (1x1) value to use when boolean is true
%     b    : (1x1) value to use when boolean is false
%
% Output:
%     out  : (1x1) value of output as appropriate
%
% Prototype:
%     bool = true;
%     a    = 'single';
%     b    = 'double';
%     out  = matspace.utils.ifelse(bool, a, b);
%     assert(out == "single");
%
% See Also:
%     where
%
% Notes:
%     1.  This function simply allows you to one line an if/else statement.
%
% Change Log:
%     1.  Written by David C. Stauffer in January 2026.

arguments
    bool (1, 1) logical
    a
    b
end

if bool
    out = a;
else
    out = b;
end