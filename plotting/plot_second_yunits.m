function [] = plot_second_yunits(fig, ax, ylab, multiplier)

% PLOT_SECOND_YUNITS  plots a second y axis on the right in different units.
%
% Summary:
%     This function creates a second axes, but hides everything except the ylabel
%     which is put on the right side of the plot.
%
% Input:
%     fig        : (scalar) figure handle [num]
%     ax         : (scalar) axis handle [num]
%     ylab       : (row) string specifying the ylabel on the new axis [char]
%     multiplier : (scalar) multiplier between the two units
%
% Output:
%     None
%
% Prototype:
%     fig = figure;
%     ax  = axes;
%     plot(ax, 0, 0);
%     ylabel('Units');
%     plot_second_yunits(fig, ax, 'deci-Units', 100);
%     grid on;
%
%     % clean up
%     close(fig);
%
% See Also:
%     setup_plots
%
% Notes:
%     1.  The pan and zoom is currently broken for the Y-axis, and  I don't know how to fix it.
%
% Change Log:
%     1.  Written by David Stauffer Stauffer in Aug 2011.
%     2.  Incorporated by David C. Stauffer into DStauffman library in Nov 2016.

% create second axis
ax2 = axes('HandleVisibility', 'callback');
% make clear and put y axis on right side
set(ax2, 'Position', get(ax, 'Position'), 'YAxisLocation', 'right', 'Color', 'none');
% set the new limits for the right side
set(ax2, 'YLim', multiplier*get(ax, 'YLim'));
% adjust the ticks to match the original axes
set(ax2, 'YTick', get(ax, 'YTick')*multiplier);
% set the ylabel
ylabel(ax2, ylab);
% link the x axes
linkaxes([ax ax2], 'x');
% set the original axes to the current one
set(fig, 'CurrentAxes', ax);

% set pan and zoom callbacks
z1 = zoom;
p1 = pan;
set(z1, 'ActionPreCallback' , {@myprecallback,  [ax ax2]});
set(z1, 'ActionPostCallback', {@mypostcallback, [ax ax2], multiplier});
set(p1, 'ActionPreCallback' , {@myprecallback,  [ax ax2]});
set(p1, 'ActionPostCallback', {@mypostcallback, [ax ax2], multiplier});

function myprecallback(hObject, eventdata, ax) %#ok<INUSL>
% pre-callback to make sure the main axes is always active.
set(hObject, 'CurrentAxes', ax(1))

function mypostcallback(hObject, eventdata, ax, multiplier) %#ok<INUSL>
% post callback to make sure the axes stay sync'd after panning or zooming.
switch get(hObject, 'CurrentAxes')
    case ax(1)
        set(ax(2), 'YLim', multiplier*get(ax(1), 'YLim'));
        set(ax(2), 'YTick', get(ax(1), 'YTick')*multiplier);
    case ax(2)
        set(ax(1), 'YLim', 1/multiplier*get(ax(2), 'YLim'));
        set(ax(1), 'YTick', get(ax(2), 'YTick')/multiplier);
    otherwise
        error('dstauffman:BadAxesHandle', 'Unexpected axis handle.');
end
set(hObject, 'CurrentAxes', ax(1));