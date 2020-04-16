function [prob] = ar2mp(rate)

% AR2MP  is a wrapper to ANNUAL_RATE_TO_MONTHLY_PROBABILITY, which converts a given annual
%     rate into the equivalent monthly probability.
%
% Input:
%     rate : (1xN) annual rate [ndim]
%
% Output:
%     prob : (1xN) equivalent monthly probability [ndim]
%
% See Also:
%     matspace.stats.rate_to_prob
%
% Prototype:
%     rate = [0, 0.5, 1, 5, inf];
%     prob = matspace.stats.annual_rate_to_monthly_probability(rate);
%     assert(all(abs(prob - [0, 0.04081054, 0.07995559, 0.34075937, 1]) < 1e-7));
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2016.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

import matspace.stats.annual_rate_to_monthly_probability
[prob] = annual_rate_to_monthly_probability(rate);