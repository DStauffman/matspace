function [fig_ax] = create_figure(num_figs, num_rows, num_cols, kwargs)

% Create or passthrough the given figures.

arguments
    num_figs (1, 1) double
    num_rows (1, 1) double
    num_cols (1, 1) double
    kwargs.Description {mustBeTextScalar} = ""
end

import matspace.plotting.fig_ax_factory

description = kwargs.Description;

% Create plots
if num_cols == 1
    fig_ax = fig_ax_factory(num_figs=num_figs, num_axes=num_rows, layout="rows", sharex=true);
elseif num_rows == 1
    fig_ax = fig_ax_factory(num_figs=num_figs, num_axes=num_cols, layout="cols", sharex=true);
else
    layout = "colwise";  % TODO: colwise or rowwise?
    fig_ax = fig_ax_factory(num_figs=num_figs, num_axes=[num_rows, num_cols], layout=layout, sharex=true);
end
if ~isempty(description)
    temp = fig_ax{1};
    temp{1}.Name = description;
end