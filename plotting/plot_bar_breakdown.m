function [fig_hand] = plot_bar_breakdown(time, data, label, OPTS, legend)

% PLOT_BAR_BREAKDOWN  plots the pie chart like breakdown by percentage in each category over time.
%
% Inputs:
%     time  : (1xN) time history
%     data  : (MxN) data for corresponding time history
%     label : (char) Name to label on the plots
%     opts  : (class) plotting options
%
% Output:
%     fig_hand : (obj) figure handle
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2017.
%
% Prototype:
%     time  = (0:1/12:5) + 2000;
%     data  = rand(5, length(time));
%     mag   = sum(data, 1);
%     data  = data ./ mag;
%     label = 'Test';
%     fig   = plot_bar_breakdown(time, data, label);

%% check for optional inputs
switch nargin
    case 3
        OPTS   = [];
        legend = {};
    case 4
        legend = {};
    case 5
        % nop
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%s"', nargin);
end
if isempty(OPTS)
    OPTS = Opts();
end
if ~isempty(legend)
    assert(length(legend) == size(data,1), 'Number of data channels does not match the legend.');
else
    legend = arrayfun(@(x) ['Series ', num2str(x)], 1:size(data,1), 'UniformOutput', false);
end

%% hard-coded values
this_title = [label, ' vs. Time'];
scale      = 100;
units      = '%';
unit_text  = [' [', units, ']'];

%% plot breakdown
fig_hand = figure('name', this_title);
ax = axes;
b = bar(ax, time, scale*data', 1.0, 'stack', 'EdgeColor', 'none');
color_order = hsv(length(b));
for i = 1:length(b)
    set(b(i), 'DisplayName', legend{i}, 'FaceColor', color_order(i,:));
end
xlabel('Time [year]');
ylabel([label, unit_text]);
%ylim([0, 100]); % TODO: put this in once the data is cleaned up
grid('on');
title(this_title);

%% create figure controls
figmenu;

%% setup plots
setup_plots(fig_hand,OPTS,'time');