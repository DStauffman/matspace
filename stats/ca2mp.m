function [monthly] = ca2mp(annual)

% CA2MP is a wrapper to CONVERT_ANNUAL_TO_MONTHLY_PROBABILITY, which converts a given annual
%     probability into the equivalent monthly one.
%
% Input:
%     annual : (1xN) annual probability [ndim]
%
% Output:
%     monthly : (1xN) monthly probability [ndim]
%
% Prototype:
%     annual  = [0, 0.1, 1];
%     monthly = ca2mp(annual);
%     assert(all(abs(monthly - [0, 0.00874161, 1]) < 1e-7));
%
% Change Log:
%     Written by David C. Stauffer in April 2016.

% calculate monthly probability
monthly = convert_annual_to_monthly_probability(annual);