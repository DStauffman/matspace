function [annual] = cm2ap(monthly)

% CM2AP is a wrapper to CONVERT_MONTHLY_TO_ANNUAL_PROBABILITY, which converts a given monthly
%     probability into the equivalent annual one.
%
% Input:
%     monthly : (1xN) monthly probability [ndim]
%
% Output:
%     annual : (1xN) annual probability [ndim]
%
% Prototype:
%     annual  = [0, 0.1, 1];
%     monthly = matspace.stats.ca2mp(annual);
%     assert(all(abs(monthly - [0, 0.00874161, 1]) < 1e-7));
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2016.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

arguments
    monthly double
end

% Imports
import matspace.stats.convert_monthly_to_annual_probability

% calculate annual probability
annual = convert_monthly_to_annual_probability(monthly);