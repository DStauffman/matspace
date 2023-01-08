function [out] = apply_prob_to_mask(mask, prob)

% APPLY_PROB_TO_MASK  applies a one-time probability to an logical array while minimizing the random number calls.
%
% Input:
%     mask : (1xN) on (Nx1) vector of logicals (true/false)
%     prob : (scalar) Probability to apply to each true value in the mask [num]
%
% Output:
%     out  : (1xN) Logical array with trues only remaining where the probability held up [bool]
%
% Prototype:
%     mask = rand(10000, 1) < 0.5;
%     prob = 0.3;
%     out  = matspace.stats.apply_prob_to_mask(mask, prob);
%     assert(nnz(mask) < 6000);
%     assert(nnz(out) < 0.4 * nnz(mask));
%
% Change Log:
%     1.  Written by David C. Stauffer in August 2022.

arguments
    mask logical {mustBeVector}
    prob (1, 1) double
end

keep = rand(nnz(mask), 1) < prob;

out = mask;
out(mask) = keep;