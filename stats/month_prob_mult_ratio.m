function [mult_prob] = month_prob_mult_ratio(prob, ratio)

% MONTH_PROB_MULT_RATIO  multiplies a monthly probability by a given risk or hazard ratio.
%
% Input:
%     prob .... : (1xN) probability of event happening over one month
%     ratio ... : (scalar) multiplication ratio to apply to probability
%
% Output:
%     mult_prob : (1xN) equivalent multiplicative monthly probability
%
% Prototype:
%     prob      = [0, 0.1, 1];
%     ratio     = 2;
%     mult_prob = month_prob_mult_ratio(prob, ratio);
%     assert(all(abs(mult_prob - [0, 0.19, 1]) < 1e-12));
%
%     ratio = 0.5;
%     mult_prob = month_prob_mult_ratio(prob, ratio);
%     assert(all(abs(mult_prob - [0, 0.0513167, 1]) < 1e-7));
%
% Change Log:
%     1.  Written by David C. Staufer in January 2016.

% hard-coded values
MONTHS_PER_YEAR = 12;

% time to use in calculations
one_month = 1/MONTHS_PER_YEAR;

% convert the probability to a rate
rate = prob_to_rate(prob, one_month);

% scale the rate
mult_rate = rate * ratio;

% convert back to a probability
mult_prob = rate_to_prob(mult_rate, one_month);