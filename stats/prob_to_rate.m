function [rate] = prob_to_rate(prob, time)

% PROB_TO_RATE  converts a given probability and time to a rate.
%
% Input:
%     prob : (1xN) Probability of event happening over the given time [ndim]
%     time : (scalar) Time for the given probability [years]
%
% Output:
%     rate : (1xN) Equivalent annual rate for the given probability and time [ndim]
%
% Prototype:
%     prob = [0, 0.1, 1];
%     time = 3;
%     rate = prob_to_rate(prob, time);
%     assert(rate(1) == 0);
%     assert(abs(rate(2) - 0.03512017) < 1e-7);
%     assert(isinf(rate(3)));
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2016.

% optional inputs
switch nargin
    case 1
        time = 1;
    case 2
        %nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% calculate rate
rate = -log(1 - prob) / time;