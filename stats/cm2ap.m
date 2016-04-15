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
%     monthly = ca2mp(annual);
%     assert(all(abs(monthly - [0, 0.00874161, 1]) < 1e-7));
%
% Change Log:
%     Written by David C. Stauffer in April 2016.

% calculate annual probability
annual = convert_monthly_to_annual_probability(monthly);