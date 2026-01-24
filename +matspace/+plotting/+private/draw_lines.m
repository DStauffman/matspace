function [line] = draw_lines(datashaders, this_time, this_data, plot_func, this_axes, kwargs)

% Draws the actual plotting lines and markers, with options for datashader.

arguments
    datashaders %#ok<INUSA>
    this_time
    this_data
    plot_func
    this_axes
    kwargs.Symbol (1, :) {mustBeTextScalar}
    kwargs.MarkerSize (1, 1) double
    kwargs.Color (1, 3) double
    kwargs.Label (1, :) {mustBeTextScalar}
    kwargs.ZOrder (1, 1) double
    kwargs.MarkerFaceColor = "none" % : str | tuple[float, float, float, float] = "none",
    kwargs.UseDatashader (1, 1) logical = false
    kwargs.DatashaderPts (1, 1) double = 2000
end

symbol = kwargs.Symbol;
markersize = kwargs.MarkerSize;
color = kwargs.Color;
label = kwargs.Label;
zorder = kwargs.ZOrder; %#ok<NASGU>  % TODO: remove zorder entirely as Matlab doesn't use this concept?
markerfacecolor = kwargs.MarkerFaceColor;
use_datashader = kwargs.UseDatashader;
datashader_pts = kwargs.DatashaderPts;

if use_datashader && numel(this_time) > datashader_pts
    error('Not yet implemented.');
    % ix_spot = np.round(np.linspace(0, this_time.size - 1, datashader_pts)).astype(int)
    % if not np.issubdtype(this_data.dtype, np.number):
    %     (categories, ix_extras) = np.unique(this_data, return_index=True)
    %     temp_data = pd.Categorical(this_data, categories=categories[np.argsort(ix_extras)], ordered=True)
    %     ix_spot = np.union1d(ix_spot, ix_extras)
    %     line = plot_func(
    %         this_axes,
    %         this_time[ix_spot],
    %         this_data[ix_spot],
    %         symbol[0],
    %         markersize=markersize,
    %         markerfacecolor=markerfacecolor,
    %         label=label,
    %         color=color,
    %         zorder=zorder,
    %         linestyle="none",
    %     )
    %     datashaders.append({"time": this_time, "data": temp_data.codes, "ax": this_axes, "color": color})  # type: ignore[typeddict-item]
    % else:
    %     line = plot_func(
    %         this_axes,
    %         this_time[ix_spot],
    %         this_data[ix_spot],
    %         symbol[0],
    %         markersize=markersize,
    %         markerfacecolor=markerfacecolor,
    %         label=label,
    %         color=color,
    %         zorder=zorder,
    %         linestyle="none",
    %     )
    %     datashaders.append({"time": this_time, "data": this_data, "ax": this_axes, "color": color})
else
    line = plot_func(...
        this_axes, ...
        this_time, ...
        this_data, ...
        symbol, ...
        MarkerSize=markersize, ...
        MarkerFaceColor=markerfacecolor, ...
        DisplayName=label, ...
        Color=color ...
        ...ZOrder=zorder ...
    );
end