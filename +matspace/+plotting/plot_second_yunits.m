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
%     ax  = axes(fig);
%     plot(ax, 0, 0);
%     ylabel(ax, 'Units');
%     matspace.plotting.plot_second_yunits(ax, 'deci-Units', 100);
%     grid(ax, 'on');
%
%     % test interactive pan and zoom for full functionality
%
%     % clean up
%     close(fig);
%
% See Also:
%     plot_monte_carlo
%
% Change Log:
%     1.  Written by David C. Stauffer in Aug 2011.
%     2.  Incorporated by David C. Stauffer into matspace library in Nov 2016.
%     3.  Re-written by David C. Stauffer in December 2017 to use new yyaxis built-in.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.
%     5.  Updated by David C. Stauffer in February 2026 to handle either axes as active.

% get the original bounds
orig_bounds = ax.YLim;
orig_color  = ax.YColor;

% store the multiplier for use later when panning or zooming
ax.UserData.multiplier = multiplier;

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
switch event.Axes.YAxisLocation
    case 'right'
        % make second axes active
        yyaxis(axes, 'left');
        % update to appropriate limits
        axes.XLim = new_xlim;
        axes.YLim = 1 / axes.UserData.multiplier * new_ylim;
        yyaxis(axes, 'right');
    case 'left'
        % make second axes active
        yyaxis(axes, 'right');
        % update to appropriate limits
        axes.XLim = new_xlim;
        axes.YLim = axes.UserData.multiplier * new_ylim;
        yyaxis(axes, 'left');
end