function [fig_ax] = create_figure(num_figs, num_rows, num_cols, kwargs)

% Create or passthrough the given figures.

arguments
    num_figs (1, 1) double
    num_rows (1, 1) double
    num_cols (1, 1) double
    kwargs.Description {mustBeTextScalar} = ''
    kwargs.Visible {mustBeMember(kwargs.Visible, ["on", "off"])} = 'on'
    kwargs.Theme {mustBeMember(kwargs.Theme, ["light", "dark", "auto"])} = 'light'
end
description = kwargs.Description;
fig_visible = kwargs.Visible;
fig_theme   = kwargs.Theme;

import matspace.plotting.fig_ax_factory

% Create plots
if num_cols == 1
    fig_ax = fig_ax_factory(NumFigs=num_figs, NumAxes=num_rows, Layout='rows', ...
        ShareX=true, Visible=fig_visible, Theme=fig_theme);
elseif num_rows == 1
    fig_ax = fig_ax_factory(NumFigs=num_figs, NumAxes=num_cols, Layout='cols', ...
        ShareX=true, Visible=fig_visible, Theme=fig_theme);
else
    layout = 'colwise';  % TODO: colwise or rowwise?
    fig_ax = fig_ax_factory(NumFigs=num_figs, NumAxes=[num_rows, num_cols], ...
        Layout=layout, ShareX=true, Visible=fig_visible, Theme=fig_theme);
end
if ~isempty(description)
    temp = fig_ax{1};
    temp{1}.Name = description;
end