function [b1,b2] = get_prn_bits(sat)

% GET_PRN_BITS  gets the bit numbers to generate the desired prn sequence
%
% Input:
%     sat : satellite number (from 1-37)
%
% Output:
%     b1 : bit 1 for xor step in PRN sequence generator
%     b2 : bit 2 for xor step in PRN sequence generator
%
% Prototype:
%     [b1,b2] = get_prn_bits(19);
%
% See Also:
%     cor_prn, generate_prn
%
% Change Log:
%     1.  Written by David C. Stauffer for AA272C in Jan 2009.
%     2.  Moved to gps subfolder in Feb 2009.
%     3.  Incorporated into DStauffman Matlab tools in Nov 2016.

switch sat
    case 1
        b1 = 2;b2 = 6;
    case 2
        b1 = 3;b2 = 7;
    case 3
        b1 = 4;b2 = 8;
    case 4
        b1 = 5;b2 = 9;
    case 5
        b1 = 1;b2 = 9;
    case 6
        b1 = 2;b2 = 10;
    case 7
        b1 = 1;b2 = 8;
    case 8
        b1 = 2;b2 = 9;
    case 9
        b1 = 3;b2 = 10;
    case 10
        b1 = 2;b2 = 3;
    case 11
        b1 = 3;b2 = 4;
    case 12
        b1 = 5;b2 = 6;
    case 13
        b1 = 6;b2 = 7;
    case 14
        b1 = 7;b2 = 8;
    case 15
        b1 = 8;b2 = 9;
    case 16
        b1 = 9;b2 = 10;
    case 17
        b1 = 1;b2 = 4;
    case 18
        b1 = 2;b2 = 5;
    case 19
        b1 = 3;b2 = 6;
    case 20
        b1 = 4;b2 = 7;
    case 21
        b1 = 5;b2 = 8;
    case 22
        b1 = 6;b2 = 9;
    case 23
        b1 = 1;b2 = 3;
    case 24
        b1 = 4;b2 = 6;
    case 25
        b1 = 5;b2 = 7;
    case 26
        b1 = 6;b2 = 8;
    case 27
        b1 = 7;b2 = 9;
    case 28
        b1 = 8;b2 = 10;
    case 29
        b1 = 1;b2 = 6;
    case 30
        b1 = 2;b2 = 7;
    case 31
        b1 = 3;b2 = 8;
    case 32
        b1 = 4;b2 = 9;
    case 33
        b1 = 5;b2 = 10;
    case 34
        b1 = 4;b2 = 10;
    case 35
        b1 = 1;b2 = 7;
    case 36
        b1 = 2;b2 = 8;
    case 37
        b1 = 4;b2 = 10;
    otherwise
        error('dstauffman:GpsUnexpectedSatellite', 'Unexpected satellite number: "%s"', sat);
end