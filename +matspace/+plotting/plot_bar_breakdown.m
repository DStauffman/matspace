function [fig_hand] = plot_bar_breakdown(time, data, label, OPTS, names)

% PLOT_BAR_BREAKDOWN  plots the pie chart like breakdown by percentage in each category over time.
%
% Inputs:
%     time  : (1xN) time history
%     data  : (MxN) data for corresponding time history
%     label : (char) Name to label on the plots
%     OPTS  : (class) plotting options
%     names : |opt| {1xN} of char, names to put on legend
%
% Output:
%     fig_hand : (obj) figure handle
%
% Prototype:
%     time  = (0:1/12:5) + 2000;
%     data  = rand(5, length(time));
%     mag   = sum(data, 1);
%     data  = data ./ mag;
%     label = 'Test';
%     fig   = matspace.plotting.plot_bar_breakdown(time, data, label);
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2017.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

%% Imports
import matspace.plotting.figmenu
import matspace.plotting.Opts
import matspace.plotting.setup_plots

%% check for optional inputs
switch nargin
    case 3
        OPTS   = [];
        names = {};
    case 4
        names = {};
    case 5
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end
if isempty(OPTS)
    OPTS = Opts();
end
if ~isempty(names)
    assert(length(names) == size(data,1), 'Number of data channels does not match the legend.');
else
    names = arrayfun(@(x) ['Series ', num2str(x)], 1:size(data,1), 'UniformOutput', false);
end

%% Process OPTS
time_units = OPTS.time_base;

%% hard-coded values
this_title = [label, ' vs. Time'];
scale      = 100;
units      = '%';
unit_text  = [' [', units, ']'];
drop_zeros = true; % TODO: could make an OPTS option

%% Calculations
data_max = max(sum(data, 1));
if abs(1 - data_max) < 1e-8
    is_normalized = true;
else
    is_normalized = false;
end

%% plot breakdown
fig_hand = figure('name', this_title);
ax = axes(fig_hand);
b = bar(ax, time, scale*data', 1.0, 'stack', 'EdgeColor', 'none');
if drop_zeros
    used = arrayfun(@(x) any(x.YData ~= 0), b);
else
    used = true(size(b)); %#ok<UNRCH>
end
color_order = hsv(nnz(used));
color_ix = cumsum(used);
for i = 1:length(b)
    if used(i)
        set(b(i), 'DisplayName', names{i}, 'FaceColor', color_order(color_ix(i),:));
    else
        set(b(i), 'HandleVisibility', 'off');
    end
end
xlabel(ax, ['Time [',time_units,']']);
ylabel(ax, [label, unit_text]);
% set limits for data that sums to 100%
if is_normalized
    ylim(ax, [0, 100]);
end
grid(ax, 'on');
title(ax, this_title, 'interpreter', 'none');
leg = legend(ax, 'show');
set(leg, 'interpreter', 'none');

%% create figure controls
figmenu;

%% setup plots
setup_plots(fig_hand, OPTS, 'time');