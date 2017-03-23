function [prob] = annual_rate_to_monthly_probability(rate)

% ANNUAL_RATE_TO_MONTHLY_PROBABILITY  converts a given annual rate to a monthly probability.
%
% Input:
%     rate : (1xN) annual rate [ndim]
%
% Output:
%     prob : (1xN) equivalent monthly probability [ndim]
%
% See Also:
%     rate_to_prob
%
% Prototype:
%     rate = [0, 0.5, 1, 5, inf];
%     prob = annual_rate_to_monthly_probability(rate);
%     assert(all(abs(prob - [0, 0.04081054, 0.07995559, 0.34075937, 1]) < 1e-7));
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2016.

% hard-coded values
MONTHS_PER_YEAR = 12;

% divide rate and calculate probability
prob = rate_to_prob(rate/MONTHS_PER_YEAR);