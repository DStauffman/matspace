function [rate] = mp2ar(prob)

% MP2AR  is a wrapper to MONTHLY_PROBABILITY_TO_ANNUAL_RATE, which converts a given monthly
%     probability into the equivalent annual rate.
%
% Input:
%     prob : (1xN) monthly probability [ndim]
%
% Output:
%     rate : (1xN) equivalent annual rate [ndim]
%
% See Also:
%     matspace.stats.prob_to_rate, matspace.stats.monthly_probability_to_annual_rate
%
% Prototype:
%     prob = [0 0.04, 0.08, 0.35, 1];
%     rate = matspace.stats.mp2ar(prob);
%     assert(all(abs(rate(1:end-1) - [0 0.48986393 1.00057931 5.16939499]) < 1e-7));
%     assert(isinf(rate(end)));
%
% Change Log:
%     1.  Written by David C. Stauffer in January 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

import matspace.stats.monthly_probability_to_annual_rate
rate = monthly_probability_to_annual_rate(prob);