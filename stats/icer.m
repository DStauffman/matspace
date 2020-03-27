function [inc_cost, inc_qaly, icer_out, order, data] = icer(cost, qaly, names, baseline, make_plot, OPTS)

% ICER  calculates the incremental cost effectiveness ratios with steps to throw out dominated strategies.
%
% Summary:
%     In a loop, the code sorts by cost, throws out strongly dominated strategies (qaly doesn't
%     improve despite higher costs), calculates an incremental cost, qaly and cost effectiveness
%     ratio, then throws out weakly dominated strategies (icer doesn't improve over cheaper options)
%     and finally returns the incremental cost, qaly and ratios for the remaining "frontier" options
%     along with an order variable to map them back to the inputs.
%
%     It optionally recalculates the ICERs based on a given baseline or standard of care case, and
%     also saves all the information to a Matlab table and displays a plot.
%
% Input:
%     cost .... : (Mx1) cost of each strategy [dollars]
%     qaly .... : (Mx1) quality adjusted life years (QALY) gained by each strategy [life years]
%     names ... : {Mx1} names of the different strategies
%     baseline  : (scalar) index of baseline strategy to use for cost comparisons, if not nan [num]
%     make_plot : (scalar) true/false flag for whether to plot the data [bool]
%     OPTS .... : (class) plotting options, see Opts.m for details
%
% Output:
%     inc_cost  : (Nx1) incremental costs [dollars] - see note 1
%     inc_qaly  : (Nx1) incremental QALYs gained [life years]
%     icer_out  : (Nx1) incremental cost effectiveness ratios [ndim]
%     order ... : (Mx1) order mapping to the original inputs, with NaNs for dominated strategies [num]
%     data .... : (Mx7 table) data output as a Matlab table [num]
%
% Prototype:
%     cost = [250e3; 750e3; 2.25e6; 3.75e6];
%     qaly = [20; 30; 40; 80];
%     [inc_cost, inc_qaly, icer_out, order, data] = icer(cost, qaly);
%     % test results
%     assert(isequal(inc_cost, [250e3; 500e3; 3e6]));
%     assert(isequal(inc_qaly, [20; 10; 50]));
%     assert(isequal(icer_out, [12500; 50000; 60000]));
%     assert(isequaln(order,   [1; 2; nan; 3]));
%
% See Also:
%     display_icer_results
%
% Notes
%     1.  N may be smaller than M due to dominated strategies being removed.  The order variable
%         will have (M - N) values set to NaN.
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2016.
%     2.  Updated by David C. Stauffer in May 2016 to allow a specified baseline, and to optionally
%         make a plot.

%% check for optional inputs
switch nargin
    case 2
        names     = [];
        baseline  = nan;
        make_plot = false;
        OPTS      = Opts();
    case 3
        baseline  = nan;
        make_plot = false;
        OPTS      = Opts();
    case 4
        make_plot = false;
        OPTS      = Opts();
    case 5
        OPTS      = Opts();
    case 6
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

%% check inputs
assert(all(cost > 0), 'Costs must be positive (and not NaNs).');
assert(all(qaly > 0), 'Qalys must be positive (and not NaNs).');

% force to be column vectors
cost = cost(:);
qaly = qaly(:);
assert(length(cost) == length(qaly), 'Cost and Qalys must have same size.');
assert(~isempty(cost), 'Costs and Qalys cannot be empty.');

%% Solve ICERs

% check for identical qalys, and drop the higher cost (or keep the first if costs are the same)
unique_qalys = unique(qaly);
if length(unique_qalys) < length(qaly)
    keep = nan(1, length(unique_qalys));
    for i = 1:length(unique_qalys)
        this_qaly = unique_qalys(i);
        this_ix = find(ismember(qaly, this_qaly));
        [~, temp_ix] = min(cost(this_ix));
        keep(i) = this_ix(temp_ix);
    end
else
    % build an index order variable to keep track of strategies
    keep = 1:length(cost);
end

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
            error('matspace:badIcerReduction','Index should never be empty, something unexpected happened.');
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
            error('matspace:badIcerReduction','Index should never be empty, something unexpected happened.');
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

% build an index to pull data out
temp = find(~isnan(order));
ix   = temp(order(~isnan(order)));

%% recalculate based on given baseline
if ~isnan(baseline)
    inc_cost = diff([cost(baseline); cost(ix)]);
    inc_qaly = diff([qaly(baseline); qaly(ix)]);
    icer_out = inc_cost ./ inc_qaly;
end

%% Output as table
if nargout > 4
    % get number of strategies
    num = length(cost);
    % build a name list if not given
    if isempty(names)
        names = string('Strategy ') + string(1:num);
    end
    names = names(:);
    % preallocate some variables
    full_inc_costs     = nan(num, 1);
    full_inc_qalys     = nan(num, 1);
    full_icers         = nan(num, 1);
    % fill the calculations in where applicable
    full_inc_costs(ix) = inc_cost;
    full_inc_qalys(ix) = inc_qaly;
    full_icers(ix)     = icer_out;
    % more explicit column names (than simply using the variable names)
    cols = {'Strategy','Cost', 'QALYs', 'Increment_Costs', 'Incremental_QALYs', 'ICER', 'Order'};
    % make the whole data set into a table
    data = table(names, cost, qaly, full_inc_costs, full_inc_qalys, full_icers, order, ...
        'VariableNames', cols);
end

%% Make a plot
if make_plot
    % create a figure and axis
    fig = figure('name', 'Cost Benefit Frontier');
    ax = axes;
    % plot the data
    plot(ax, qaly, cost, 'ko', 'DisplayName', 'strategies');
    hold on;
    plot(qaly(ix), cost(ix), 'r.', 'MarkerSize', 20, 'DisplayName', 'frontier');
    % get axis limits before (0,0) point is added
    lim = axis;
    % add ICER lines
    if isnan(baseline)
        plot([0; qaly(ix)], [0; cost(ix)], 'r-', 'DisplayName', 'ICERs');
    else
        plot([0; qaly(ix(1))], [0; cost(ix(1))],'r:', 'HandleVisibility','off');
        plot([qaly(baseline); qaly(ix)], [cost(baseline); cost(ix)], 'r-', 'DisplayName', 'ICERs');
    end
    % Label each point
    dy = (lim(4) - lim(3)) / 100;
    for i = 1:length(names)
        text(qaly(i), cost(i)+dy, names{i}, 'Units', 'data', 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', 'FontSize', 12, 'interpreter', 'none');
    end
    % add some labels and such
    title(get(fig, 'name'), 'interpreter', 'none');
    xlabel('Benefits');
    ylabel('Costs');
    legend('show', 'location', 'NorthWest');
    grid on;
    % reset limits with including (0,0) point in case it skews everything too much
    axis(lim);
    % add standard plotting features
    figmenu;
    setup_plots(fig, OPTS, 'dist_no_y_scale');
end