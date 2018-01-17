function plot_rms_lines(x,y,show_in_legend)

% PLOT_RMS_LINES  plots a vertical line at the RMS start and stop times.
%
% Summary:
%     There are two vertical lines created.  The first at x(1) and the second at x(2).
%     The first line is orange, and the second is lavender.  Both have magenta crosses at
%     the top and bottom.  The lines are added to the plot regardless of the figure hold state.
%
% Input:
%     x : (1x2) vector of xmin and xmax values at which to draw the lines [num]
%     y : (1x2) vector of ymin and ymax values at which to extend the lines vertically [num]
%     show_in_legend : (scalar), optional, show the lines when a legend is turned on [bool]
%
% Output:
%     (NONE)
%
% Prototype:
%     f1 = figure;
%     plot(1:10,1:10);
%     plot_rms_lines([2 5],[1 10]);
%
%     % clean up
%     close(f1);
%
% Change Log:
%     1.  Added to DStauffman's MATLAB libary from GARSE in Sept 2013.
%     2.  Updated by David C. Stauffer in January 2018 to allow to be excluded from legends.

% get optional inputs
switch nargin
    case 2
        show_in_legend = true;
    case 3
        % nop
    otherwise
        error('dstauffman:UnexpectedNargin','Unexpected number of inputs: "%i"',nargin);
end

% initial figure hold state
hold_state = ishold;
hold on;

% Bug in Matlab when using MarkerEdgeColor and the plotbrowser (for R2014A (8.3) to R2015B (8.6), fixed in R2016A (9.0)):
if ~verLessThan('matlab', '9.0') || verLessThan('matlab','8.3')
    h1 = plot([x(1) x(1)],y,'LineStyle','--','Color',[   1 0.75 0],'Marker','+','MarkerEdgeColor','m','MarkerSize',10,'DisplayName','RMS Start Time');
    h2 = plot([x(2) x(2)],y,'LineStyle','--','Color',[0.75 0.75 1],'Marker','+','MarkerEdgeColor','m','MarkerSize',10,'DisplayName','RMS Stop Time');
else
    h1 = plot([x(1) x(1)],y,'LineStyle','--','Color',[   1 0.75 0],'Marker','+','MarkerSize',10,'DisplayName','RMS Start Time');
    h2 = plot([x(2) x(2)],y,'LineStyle','--','Color',[0.75 0.75 1],'Marker','+','MarkerSize',10,'DisplayName','RMS Stop Time');
end

% exclude lines from legend
if ~show_in_legend
    set(get(get(h1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end

% reset hold state if it wasn't previously set
if ~hold_state
    hold off;
end