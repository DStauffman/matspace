function [] = plot_second_yunits(ax, ylab, multiplier)

% PLOT_SECOND_YUNITS  plots a second y axis on the right in different units.
%
% Summary:
%     This function creates a second axes and adds a ylabel or the right side of the plot, while
%     making sure that zoom and pan functionality updates both axes.
%
% Input:
%     ax         : (object) axis handle
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
%     % test interactive pan and zoom for full functionality
%
%     % clean up
%     close(fig);
%
% See Also:
%     plot_time_history
%
% Change Log:
%     1.  Written by David Stauffer Stauffer in Aug 2011.
%     2.  Incorporated by David C. Stauffer into DStauffman library in Nov 2016.
%     3.  Re-written by David C. Stauffer in December 2017 to use new yyaxis built-in.

% get the original bounds
orig_bounds = ax.YLim;
orig_color  = ax.YColor;

% store the multiplier for use later when panning or zooming
ax.UserData.multiplier = multiplier;

% turn existing plot into two axis version and put original on left axes
yyaxis(ax, 'left');

% create second axis on the right and set it as active
yyaxis(ax, 'right');

% set the new limits for the right side
ax.YLim = multiplier*orig_bounds;

% update the color to match the original
ax.YColor = orig_color;

% set the new ylabel
ylabel(ax, ylab);

% restore the original axes as active
yyaxis(ax, 'left');

% update the pan and zoom callbacks to effect both axes
% set pan and zoom callbacks
z1 = zoom;
p1 = pan;
z1.ActionPostCallback = @mypostcallback;
p1.ActionPostCallback = @mypostcallback;


%% Subfunctions
function mypostcallback(~, event)

% get axes object
axes = event.Axes;
% get new x and y limits and apply to second axes
new_xlim = axes.XLim;
new_ylim = axes.YLim;
% make second axes active
yyaxis(axes, 'right');
% update to appropriate limits
axes.XLim = new_xlim;
axes.YLim = axes.UserData.multiplier * new_ylim;
% restore original axes as active
yyaxis(axes, 'left');