function [prob] = rate_to_prob(rate, time)

% RATE_TO_PROB converts a given rate and time to a probability.
%
% Input:
%     rate : (1xN) Annual rate for the given probability and time [ndim]
%     time : (scalar) Time for the given probability [years]
%
% Output:
%     prob : (1xN) Equivalent probability of event happening over the given time [ndim]
%
% Prototype:
%     rate = [0, 0.1, 1, 100, inf];
%     time = 1/12;
%     prob = rate_to_prob(rate, time);
%     assert(all(abs(prob - [0, 0.00829871, 0.07995559, 0.99975963, 1]) < 1e-7));
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2016.

% optional inputs
switch nargin
    case 1
        time = 1;
    case 2
        % nop
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% calculate probability
prob = 1 - exp(-rate * time);