function [inc_cost, inc_qaly, icer_out, order] = icer(cost, qaly)

% ICER  calculates the incremental cost effectiveness ratios with steps to throw out dominated strategies.
%
% Summary:
%     In a loop, the code sorts by cost, throws out strongly dominated strategies (qaly doesn't
%     improve despite higher costs), calculates an incremental cost, qaly and cost effectiveness
%     ratio, then throws out weakly dominated strategies (icer doesn't improve over cheaper options)
%     and finally returns the incremental cost, qaly and ratios for the remaining "frontier" options
%     along with an order variable to map them back to the inputs.
%
% Input:
%     cost : (Mx1) cost of each strategy [dollars]
%     qaly : (Mx1) quality adjusted life years (QALY) gained by each strategy [life years]
%
% Output:
%     inc_cost : (Nx1) incremental costs [dollars] - see note 1
%     inc_qaly : (Nx1) incremental QALYs gained [life years]
%     icer_out : (Nx1) incremental cost effectiveness ratios [ndim]
%     order    : (Mx1) order mapping to the original inputs, with NaNs for dominated strategies [num]
%
% Prototype:
%     cost = [250e3; 750e3; 2.25e6; 3.75e6];
%     qaly = [20; 30; 40; 80];
%     [inc_cost, inc_qaly, icer_out, order] = icer(cost, qaly);
%     % test results
%     assert(isequal(inc_cost, [250e3; 500e3; 3e6]));
%     assert(isequal(inc_qaly, [20; 10; 50]));
%     assert(isequal(icer_out, [12500; 50000; 60000]));
%     assert(isequaln(order,   [1; 2; nan; 3]));
%
% Notes
%     1.  N may be smaller than M due to dominated strategies being removed.  The order variable
%         will have (M - N) values set to NaN.
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2016.

% check inputs
assert(all(cost > 0), 'Costs must be positive.');
assert(all(qaly > 0), 'Qalys must be positive.');

% force to be column vectors
cost = cost(:);
qaly = qaly(:);
assert(length(cost) == length(qaly), 'Cost and Qalys must have same size.');
assert(~isempty(cost), 'Costs and Qalys cannot be empty.');

% build an index order variable to keep track of strategies
keep = 1:length(cost);

% enter processing loop
while true
    % pull out current values based on evolving 'keep' mask
    this_cost = cost(keep);
    this_qaly = qaly(keep);

    % sort by cost
    [sorted_cost, ix_sort] = sort(this_cost);
    sorted_qaly = this_qaly(ix_sort);

    % check for strongly dominated strategies
    if ~issorted(sorted_qaly)
        % find the first occurence (increment by one to find the one less effective than the last)
        bad = find(diff(sorted_qaly) < 0, 1, 'first') + 1;
        if isempty(bad)
            error('hesat:badIcerReduction','Index should never be empty, something unexpected happended.');
        end
        % update the mask and continue to next pass of while loop
        keep(ix_sort(bad)) = [];
        continue
    end

    % calculate incremental costs
    inc_cost = [sorted_cost(1); diff(sorted_cost)];
    inc_qaly = [sorted_qaly(1); diff(sorted_qaly)];
    icer_out = inc_cost ./ inc_qaly;

    % check for weakly dominated strategies
    if ~issorted(icer_out)
        % find the first bad occurence
        bad = find(diff(icer_out) < 0, 1, 'first');
        if isempty(bad)
            error('hesat:badIcerReduction','Index should never be empty, something unexpected happended.');
        end
        % update mask and continue to next pass
        keep(ix_sort(bad)) = [];
        continue
    end

    % if no continue statements were reached, then another iteration is not necessary, so break out
    break
end

% save the final ordering
order = nan(size(cost));
order(keep) = ix_sort;