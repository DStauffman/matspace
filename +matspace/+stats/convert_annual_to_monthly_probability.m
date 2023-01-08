function [monthly] = convert_annual_to_monthly_probability(annual)

% CONVERT_ANNUAL_TO_MONTHLY_PROBABILITY  converts a given annual probability into the
%     equivalent monthly one.
%
% Input:
%     annual : (1xN) annual probability [ndim]
%
% Output:
%     monthly : (1xN) monthly probability [ndim]
%
% Prototype:
%     annual  = [0, 0.1, 1];
%     monthly = matspace.stats.convert_annual_to_monthly_probability(annual);
%     assert(all(abs(monthly - [0, 0.00874161, 1]) < 1e-7));
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2016.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

arguments
    annual double
end

% hard-coded values
MONTHS_PER_YEAR = 12;

% calculate monthly probability
monthly = 1 - exp(log(1-annual) / MONTHS_PER_YEAR);