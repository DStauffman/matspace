function plot_rms_lines(ax, x, y, show_in_legend)

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

% get optional inputs
switch nargin
    case 3
        show_in_legend = true;
    case 4
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% initial figure hold state
hold_state = ishold(ax);
hold(ax, 'on');

% draw lines (Note: might not work right before R2016A (9.0))
h1 = plot(ax, [x(1) x(1)], y, 'LineStyle', '--', 'Color', [   1 0.75 0], 'Marker', '+', ...
    'MarkerEdgeColor', 'm', 'MarkerSize', 10, 'DisplayName', 'RMS Start Time');
h2 = plot(ax, [x(2) x(2)], y, 'LineStyle', '--', 'Color', [0.75 0.75 1], 'Marker', '+', ...
    'MarkerEdgeColor', 'm', 'MarkerSize', 10, 'DisplayName', 'RMS Stop Time');

% exclude lines from legend
if ~show_in_legend
    set(get(get(h1, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
    set(get(get(h2, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
end

% reset hold state if it wasn't previously set
if ~hold_state
    hold(ax, 'off');
end