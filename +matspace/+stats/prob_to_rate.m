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
%     rate = matspace.stats.prob_to_rate(prob, time);
%     assert(rate(1) == 0);
%     assert(abs(rate(2) - 0.03512017) < 1e-7);
%     assert(isinf(rate(3)));
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2016.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

arguments
    prob double
    time double = 1
end

% calculate rate
rate = -log(1 - prob) / time;