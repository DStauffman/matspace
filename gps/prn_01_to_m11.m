function out = prn_01_to_m11(in)

% PRN_01_TO_m11  shifts from (0,1) to (1,-1)
%
% Input:
%     in  : PRN sequence of 0's and 1's
%
% Output:
%     out : PRN sequence of 1's and -1's
%
% Prototype:
%     in  = [1 1 1 0 0 1 1];
%     out = prn_01_to_m11(in);
%     assert(all(out == [-1 -1 -1 1 1 -1 -1]));
%
% Change Log:
%     1.  Written by David C. Stauffer for AA272C in Jan 2009.
%     2.  Moved to gps subfolder in Feb 2009.
%     3.  Incorporated into matspace tools in Nov 2016.

out = 1*(in==0) + -1*(in==1);