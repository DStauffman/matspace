function [] = save_zoomed_version(fig, ax, ylims, kwargs)

% Create and save a zoomed version of the plot to disk.
%
% Input:
% fig : class matplotlib.figure.Figure
%     Figure handle
% ax : class matplotlib.axes.Axes
%     Axes handle
% ylims : tuple of 2 floats, optional
%     New y limits
% ax2 : class matplotlib.axes.Axes, optional
%     Secondary axes to also scale
% use_display : bool, optional, default if True
%     Whether there is a display to use when modifying the plot
% title_post : str, optional, default is " (Zoomed)"
%     String to post-pend to the end of the title
% opts : class Opts, optional
%     Additional plotting options, for this giving whether to save, where and what form
%
% Output:
%     (None)
%
% Prototype:
%     time = 0:29;
%     data = rand(1, 30);
%     data(11) = 1e5;
%     opts = matspace.plotting.Opts();
%     fig_hand = matspace.plotting.plot_time_history('Data vs Time', time, data, Opts=opts, SecondUnits={'milli', 1e-3});
%     ax = gca(fig_hand);
%     ylims = [-2.0, 2.0];
%     matspace.plotting.save_zoomed_version(fig_hand, ax, ylims, opts=opts);
%
%     % Close plots
%     close(fig_hand);
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2026.

arguments
    fig
    ax
    ylims (1, 2) double = []
    kwargs.UseDisplay (1, 1) logical = true
    kwargs.TitlePost {mustBeTextScalar} = ' (Zoomed)'
    kwargs.Opts {mustBeOpts} = []
end

import matspace.plotting.storefig

use_display = kwargs.UseDisplay;
title_post = kwargs.TitlePost;
opts = kwargs.Opts;

if isempty(ylims)
    return
end
orig1 = ylim(ax);
has_right_axis = strcmp(ax.YAxis(2).Visible, 'on');
if has_right_axis
    yyaxis(ax, 'right');
    orig2 = ylim(ax);
    yyaxis(ax, 'left');
    if orig1(1) ~= 0 && orig2(1) ~= 0
        fact = orig2(1) / orig1(1);
    elseif orig1(2) ~= 0 && orig2(2) ~= 0
        fact = orig2(2) / orig1(2);
    else
        error('Unable to determine scale factor when limits are both zero.');
    end
end
ylim(ax, ylims);
if has_right_axis
    yyaxis(ax, 'right');
    ylim(ax, fact * ylims);
    yyaxis(ax, 'left');
end

if use_display
    fig.Name = [fig.Name, title_post];
else
    old_title = title(ax);
    title(ax, [old_title, title_post]);
end
% resave zoomed plot
if ~isempty(opts) && ~isempty(opts.save_path) && opts.save_plot
    storefig(fig, opts.save_path, opts.plot_type);
end


%% Subfunctions - mustBeOpts
function mustBeOpts(x)
import matspace.plotting.private.fun_is_opts
if ~fun_is_opts(x)
    throwAsCaller(MException('matspace:plot_cor:BadOpts','Opts must be empty, a struct, or Opts class.'));
end