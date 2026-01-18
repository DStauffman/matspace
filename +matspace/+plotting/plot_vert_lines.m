function plot_vert_lines(ax, x, kwargs)

% PLOT_RMS_LINES  plots a vertical line at the RMS start and stop times.
%
% Summary:
%     There are two vertical lines created.  The first at x(1) and the second at x(2).
%     The first line is orange, and the second is lavender.  Both have magenta crosses at
%     the top and bottom.  The lines are added to the plot regardless of the figure hold state.
%
% Input:
%     ax : (gobject) Axes handle
%     x  : (1x2) vector of xmin and xmax values at which to draw the lines [num]
%     y  : (1x2) vector of ymin and ymax values at which to extend the lines vertically [num]
%     show_in_legend : (scalar), optional, show the lines when a legend is turned on [bool]
%
% Output:
%     (NONE)
%
% Prototype:
%     f1 = figure;
%     ax = axes(f1);
%     plot(ax, 1:10,1:10);
%     matspace.plotting.plot_rms_lines(ax, [2 5], [1 10]);
%
%     % clean up
%     close(f1);
%
% Change Log:
%     1.  Added to matspace libary from GARSE in Sept 2013.
%     2.  Updated by David C. Stauffer in January 2018 to allow to be excluded from legends.
%     3.  Updated by David C. Stauffer in April 2020 to use explicit axes that is passed in.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

arguments
    ax
    x
    kwargs.ShowInLegend (1, 1) logical = true
    kwargs.ColorMap = []
    kwargs.Labels = []
end

import matspace.utils.modd

show_in_legend = kwargs.ShowInLegend;
color_map = kwargs.ColorMap;
labels = kwargs.Labels;

if isempty(color_map)
    color_map = [1.0 0.75 0.0; 0.75 0.75 1.0];
end
if isempty(labels)
    labels = ["RMS Start Time", "RMS Stop Time"];
end

% initial figure hold state
hold_state = ishold(ax);
hold(ax, 'on');

% plot vertical lines
h = gobjects(1, length(x));
for i = 1:length(x)
    this_x = x(i);
    c = modd(i, size(color_map, 1));  % TODO: modd or max?
    this_color = color_map(c, :);
    if show_in_legend
        this_label = labels{i};
    else
        this_label = '';
    end
    h(i) = xline(ax, this_x, LineStyle='--', Color=this_color, DisplayName=this_label);
    % Marker='+', MarkerEdgeColor='m', MarkerSize=6, not available in xline command
end

% exclude lines from legend
if ~show_in_legend
    for i = 1:length(h)
        set(get(get(h(i), 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
    end
end

% reset hold state if it wasn't previously set
if ~hold_state
    hold(ax, 'off');
end