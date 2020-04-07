function [bin] = calculate_bin(num, dist)

% CALCULATE_BIN  calculates the bin numbers based on a given distribution.
%
% Prototype:
%     num  = 10;
%     dist = [0.5 0.3 0.2];
%     bin  = calculate_bin(num, dist);

% hard-coded values
check = true; % performs boundary checking on distribution

% calculate the cumulative distribution
cum_dist = [0, cumsum(dist(:)')];

% calculate the bins
bin = discretize_mex(rand(num, 1), cum_dist, check);