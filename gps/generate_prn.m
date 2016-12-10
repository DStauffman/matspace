function [prn] = generate_prn(sat,len)

% GENERATE_PRN  generates the prn bit stream.
%
% Input:
%     sat : satellite number (from 1-37)
%     len : (optional) length specification
%
% Output:
%     prn : psuedo-random number for specified satellite
%
% Prototype:
%     prn = generate_prn(1);
%     assert(all((prn == 0) | (prn == 1)));
%
% See Also:
%     cor_prn, get_prn_bits
%
% Change Log:
%     1.  Written by David C. Stauffer in Jan 2009.
%     2.  Moved to gps subfolder in Feb 2009.
%     3.  Incorporated into DStauffman Matlab tools in Nov 2016.

switch nargin
    case 1
        len = 1023;
    case 2
        % nop
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%s"', nargin);
end

% find which bits to mod based on the satellite number
[bit1,bit2] = get_prn_bits(sat);

% initialize generators
g1 = ones(1,10);
g2 = ones(1,10);

% initialize output
prn = zeros(1,len);

% loop through bits
for i=1:len
    % calculate new values for generators
    g1n = bplus(g1([3 10]));
    g2n = bplus(g2([2 3 6 8 9 10]));
    g2i = bplus(g2([bit1 bit2]));

    % calculate output bit and append to PRN
    xgi = bplus([g1(10) g2i]);
    prn(i) = xgi;

    % shift generators
    g1 = [g1n g1(1:end-1)];
    g2 = [g2n g2(1:end-1)];
end


%% Subfunctions
function out = bplus(in)
% bplus does modulo 2 addition (exclusive or) on vector input
out = mod(sum(in),2);