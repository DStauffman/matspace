function [bin] = calculate_bin(num, dist)

% CALCULATE_BIN  calculates the bin numbers based on a given distribution.
%
% Input:
%     num : (scalar) number of points to calculate
%     dist : (1xN) distributions of probabilities for each bin, should sum to 1 [num]
%
% Output:
%     bin : (1xnum) Bins, from 1 to length(dist) that each random draw went into [num]
%
% Prototype:
%     num  = 10;
%     dist = [0.5 0.3 0.2];
%     bin  = matspace.utils.calculate_bin(num, dist);
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

% Imports
import matspace.coder.discretize_mex

% hard-coded values
check = true; % performs boundary checking on distribution

% calculate the cumulative distribution
cum_dist = [0, cumsum(dist(:)')];

% calculate the bins
bin = discretize_mex(rand(num, 1), cum_dist, check);