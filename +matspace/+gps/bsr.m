function [out] = bsr(in, shift)

% BSR  bit shifts right.
%
% Input:
%     in    : input bit stream as a matrix
%     shift : number of bits to shift
%
% Output:
%     out : output bit stream as a matrix
%
% Prototype:
%     in = [0 0 1 1 1];
%     out = matspace.gps.bsr(in);
%     assert(all(out == [1 0 0 1 1]));
%
% See Also:
%     matspace.gps.brl
%
% Change Log:
%     1.  Written by David C. Stauffer in Jan 2009.
%     2.  Moved to gps subfolder in Feb 2009.
%     3.  Incorporated into matspace tools in Nov 2016.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.
%     5.  Updated by David C. Stauffer in January 2026 to use arguments.

arguments (Input)
    in {mustBeVector}
    shift (1, 1) double = 1
end
arguments (Output)
    out {mustBeVector}
end

% initialize
out = in;

% shift bits
for i = 1:shift
    out(:) = [out(end) out(1:end-1)];
end