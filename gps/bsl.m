function [out] = bsl(in,shift)

% BSL  bit shifts left.
%
% Input:
%     in    : input bit stream as a matrix
%     shift : number of bits to shift
%
% Output:
%     out   : output bit stream as a matrix
%
% Prototype:
%     in  = [0 0 1 1 1];
%     out = bsl(in);
%     assert(all(out == [0 1 1 1 0]));
%
% See Also:
%     bsr
%
% Change Log:
%     1.  Written by David C. Stauffer in Jan 2009.
%     2.  Moved to gps subfolder in Feb 2009.
%     3.  Incorporated into DStauffman Matlab tools in Nov 2016.

switch nargin
    case 1
        shift = 1;
    case 2
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% shift bits
for i = 1:shift
    in = [in(2:end) in(1)];
end

% store output
out = in;