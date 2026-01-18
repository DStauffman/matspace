function [fig] = make_time_plot(description, time, data, varargin)

% MAKE_TIME_PLOT  plots data versus time.
%
% Output:
%     fig_hand .. : (scalar) figure handles [num]
%
% Prototype:
%     description      = 'Values vs Time';
%     time             = -10:0.1:10;
%     data             = time + cos(time);
%     name             = '';
%     elements         = strings(1, 0);
%     units            = '';
%     time_units       = 'sec';
%     start_date       = '';
%     rms_xmin         = -inf;
%     rms_xmax         = inf;
%     disp_xmin        = -inf;
%     disp_xmax        = inf;
%     single_lines     = false;
%     colormap         = validatecolor('b');
%     use_mean         = false;
%     plot_zero        = false;
%     show_rms         = true;
%     legend_loc       = 'best';
%     second_units     = '';
%     leg_scale        = '';
%     ylabel           = '';
%     data_as_rows     = true;
%     extra_plotter    = [];
%     use_zoh          = false;
%     label_vert_lines = true;
%     use_datashader   = false;
%     fig_ax           = [];
%     fig_hand = matspace.plotting.make_time_plot(description, time, data, Name=name, Elements=elements, ...
%         Units=units, TimeUnits=time_units, StartDate=start_date, RmsXmin=rms_xmin, RmsXmax=rms_xmax, ...
%         DispXmin=disp_xmin, DispXmax=disp_xmax, SingleLines=single_lines, ColorMap=colormap, ...
%         UseMean=use_mean, PlotZero=plot_zero, ShowRms=show_rms, LegendLoc=legend_loc, ...
%         SecondUnits=second_units, LegendScale=leg_scale, YLabel=ylabel, DataAsRows=data_as_rows, ...
%         ExtraPlotter=extra_plotter, UseZoh=use_zoh, LabelVertLines=label_vert_lines, ...
%         UseDatashader=use_datashader, FigAx=fig_ax);
%
%     % clean up
%     close(fig_hand);

%% Imports
% import matspace.plotting.get_factors
import matspace.plotting.plot_second_units_wrapper
import matspace.plotting.plot_vert_lines
import matspace.plotting.show_zero_ylim
% import matspace.plotting.whitten
import matspace.plotting.zoom_ylim
% import matspace.stats.intersect2
import matspace.utils.nanmean
% import matspace.utils.nanrms

%% Hard-coded values
LEG_FORMAT  = '%1.3f';

%% Parser
% Validation functions
fun_is_text          = @(x) ischar(x) || (isscalar(x) && isstring(x));
fun_is_bool          = @(x) islogical(x) && isscalar(x);
fun_is_time          = @(x) (isnumeric(x) || isdatetime(x)) && (isempty(x) || isvector(x) || iscell(x));
fun_is_time_cell     = @(x) fun_is_time(x) || (iscell(x) && all(cellfun(fun_is_time, x)));
fun_is_data          = @(x) isnumeric(x) || iscell(x) || iscategorical(x);
fun_is_cellstr       = @(x) isstring(x) || iscell(x);
fun_is_bound         = @(x) (isnumeric(x) || isdatetime(x)) && isscalar(x);
fun_is_plot_type     = @(x) strcmp(x, 'plot') || strcmp(x, 'scatter');
fun_is_extra_plotter = @(x) isempty(x) || isa(x, 'function_handle');
fun_is_empty_or_len2 = @(x) (isempty(x) || length(x) == 2);
fun_is_colormap      = @(x) fun_is_text(x) || isempty(x) || isnumeric(x);  % or is Colormap?
fun_is_2nd_units     = @(x) isnumeric(x) || isempty(x) || iscell(x);
fun_is_fig_ax        = @(x) isempty(x) || (iscell(x) && all(cellfun(@length, x) == 2));
% Argument parser
p = inputParser;
addRequired(p, 'Description', fun_is_text);
addRequired(p, 'Time', fun_is_time_cell);
addRequired(p, 'Data', fun_is_data);
addParameter(p, 'Name', '', fun_is_text);
addParameter(p, 'Elements', strings(0), fun_is_cellstr);
addParameter(p, 'Units', '', fun_is_text);
addParameter(p, 'TimeUnits', 'sec', fun_is_text);
addParameter(p, 'StartDate', '', fun_is_text);
addParameter(p, 'RmsXmin', -inf, fun_is_bound);
addParameter(p, 'RmsXmax', inf, fun_is_bound);
addParameter(p, 'DispXmin', -inf, fun_is_bound);
addParameter(p, 'DispXmax', inf, fun_is_bound);
addParameter(p, 'SingleLines', false, fun_is_bool);
% addParameter(p, 'FigVisible', true, fun_is_bool);
addParameter(p, 'ColorMap', 'parula', fun_is_colormap);
addParameter(p, 'UseMean', false, fun_is_bool);
addParameter(p, 'PlotZero', false, fun_is_bool);
addParameter(p, 'ShowRms', true, fun_is_bool);
addParameter(p, 'LegendLoc', 'Best', fun_is_text);
addParameter(p, 'SecondUnits', nan, fun_is_2nd_units);
addParameter(p, 'LegendScale', 'unity', fun_is_2nd_units);
addParameter(p, 'YLabel', '', fun_is_text);
addParameter(p, 'YLims', [], fun_is_empty_or_len2);
addParameter(p, 'DataAsRows', true, fun_is_bool);
addParameter(p, 'ExtraPlotter', [], fun_is_extra_plotter);
addParameter(p, 'UseZoh', false, fun_is_bool);
addParameter(p, 'LabelVertLines', false, fun_is_bool);
addParameter(p, 'UseDatashader', false, fun_is_bool);
addParameter(p, 'FigAx', [], fun_is_fig_ax);
addParameter(p, 'PlotType', 'time', fun_is_plot_type);
% do parse
parse(p, description, time, data, varargin{:});
% create some convenient aliases
name             = p.Results.Name;
elements         = p.Results.Elements;
units            = p.Results.Units;
time_units       = p.Results.TimeUnits;
start_date       = p.Results.StartDate;
rms_xmin         = p.Results.RmsXmin;
rms_xmax         = p.Results.RmsXmax;
disp_xmin        = p.Results.DispXmin;
disp_xmax        = p.Results.DispXmax;
single_lines     = p.Results.SingleLines;
color_map        = p.Results.ColorMap;
use_mean         = p.Results.UseMean;
plot_zero        = p.Results.PlotZero;
show_rms         = p.Results.ShowRms;
legend_loc       = p.Results.LegendLoc;
second_units     = p.Results.SecondUnits;
leg_scale        = p.Results.LegendScale;
y_label          = p.Results.YLabel;
ylims            = p.Results.YLims;
data_as_rows     = p.Results.DataAsRows;
extra_plotter    = p.Results.ExtraPlotter;
use_zoh          = p.Results.UseZoh;
label_vert_lines = p.Results.LabelVertLines;
use_datashader   = p.Results.UseDatashader;
fig_ax           = p.Results.FigAx;
plot_type        = p.Results.PlotType;
% if p.Results.FigVisible
%     fig_visible = 'on';
% else
%     fig_visible = 'off';
% end

%% Processing
[times, datum] = make_time_and_data_lists(time, data, DataAsRows=data_as_rows);
num_channels = length(times);
time_is_date = ~isempty(times) && isdatetime(times{1});

% optional inputs
if isempty(elements)
    elements = arrayfun(@(x) ['Channel ', int2str(x)], 1:num_channels, UniformOutput=false);
end
if length(elements) ~= num_channels
    error('The given elements need to match the data sizes, got %i and %i.', num_channels, length(elements));
end

% build RMS (or mean) indices and calculate the values
if show_rms
    ix = build_indices(times, rms_xmin, rms_xmax);
    [data_func, func_name] = calc_rms(datum, ix{"one"}, UseMean=use_mean);
end

% create a colormap
cm = colormap(color_map);  % num_colors=num_channels

% unit conversion value
[new_units, unit_conv, leg_units, leg_conv] = get_units(units, second_units, leg_scale);

% plotting options
if use_zoh
    plot_func = @plot_zoh;
else 
    plot_func = @plot_linear;
end
switch plot_type
    case 'time'
        symbol = '.-';
    case 'scatter'
        symbol = '.';
    otherwise
        error('Unexpected plot_type of %s.', plot_type);
end

% get labels
ylabels = get_ylabels(num_channels, y_label, Elements=elements, SingleLines=single_lines, Description=description, Units=units);

if isempty(fig_ax)
    % get the number of figures and axes to make
    num_figs = 1;
    if single_lines
        num_rows = num_channels;
    else
        num_rows = 1;
    end
    num_cols = 1;
    fig_ax = create_figure(num_figs, num_rows, num_cols, Description=description);
    if ~single_lines
        fig_ax(1:num_channels) = fig_ax;
    end
end
assert(~isempty(fig_ax));
assert(num_channels == 0 || length(fig_ax) == num_channels, 'Expecting a (figure, axes) pair for each channel in data.');
fig = fig_ax{1}{1};
if single_lines
    ax = nans(1, length(fig_ax));
    for i = 1:length(fig_ax)
        ax(i) = fig_ax{i}{2};
    end
else
    ax = fig_ax{1}{2};
end

datashaders = [];
for i = 1:min([length(times), length(datum)])
    temp_fig_ax = fig_ax{i};
    this_axes = temp_fig_ax{2};
    this_time = times{i};
    this_data = datum{i};
    this_ylabel = ylabels{i};
    if ~isempty(name)
        this_label = [name,' ',elements{i}];
    else
        this_label = elements{i};
    end
    if show_rms
        value = num2str(leg_conv * data_func{i}, LEG_FORMAT);
        if ~isempty(leg_units)
            this_label = [this_label,' (',func_name,': ',num2str(value),' ',leg_units,')']; %#ok<AGROW>
        else
            this_label = [this_label,' (',func_name,': ',num2str(value),')']; %#ok<AGROW>
        end
    end
    draw_lines(datashaders, this_time, this_data, plot_func, this_axes, Symbol=symbol, ...
        MarkerSize=4, Color=cm(i, :), Label=this_label, ZOrder=9, UseDatashader=use_datashader);
    xlims = label_x(this_axes, disp_xmin, disp_xmax, time_is_date, time_units, start_date);
    zoom_ylim(this_axes, [], [], t_start=xlims(1), t_final=xlims(2));
    if plot_zero
        show_zero_ylim(this_axes)
    end
    if ~isempty(ylims)
        ylim(this_axes, ylims);
    end
    if i == 1
        title(this_axes, description);
    end
    if ~isempty(this_ylabel)
        ylabel(this_axes, this_ylabel)
        grid(this_axes, 'on');
        % optionally add second Y axis
        plot_second_units_wrapper(this_axes, {new_units, unit_conv});
        % plot RMS lines
        if show_rms
            if ~use_mean
                vert_labels = strings(0);
            else
                vert_labels = ["Mean Start Time", "Mean Stop Time"];
            end
            plot_vert_lines(this_axes, ix{'pts'}, ShowInLegend=label_vert_lines, Labels=vert_labels);
        end
    end
end

if single_lines
    fig.supylabel(description)
end

% plot any extra information through a generic callable
if ~isempty(extra_plotter)  % test if callable instead?
    extra_plotter(fig=fig, ax=ax)
end

% overlay the datashaders (with appropriate time units information)
if ~isempty(datashaders)
    error('Datashader not yet implemented in Matlab');
    % for i = 1:length(datashaders)
    %     this_ds = datashaders(1);
    %     this_ds["time_units"] = time_units;
    % end
    % add_datashaders(datashaders)
end

% add legend at the very end once everything has been done
if ~strcmpi(legend_loc, 'none')
    for i = 1:length(ax)
        this_axes = ax(1);
        legend(this_axes, 'show', 'Location', legend_loc);
    end
end


%% Subfunctions - make_time_and_data_lists
function [times, datum]  = make_time_and_data_lists(time, data, kwargs)
% Turns the different types of inputs into lists of 1-D data.

arguments
    time
    data
    kwargs.DataAsRows (1,1) logical
    kwargs.IsQuat (1,1) logical = false
end

data_as_rows = kwargs.DataAsRows;
is_quat = kwargs.IsQuat;

if isempty(data)
    % assert isempty(time, 'Time must be empty if data is empty.'  % TODO: include this?
    times = cell(1, 0);
    datum = cell(1, 0);
    return
end
if iscell(data)
    datum = data;
else
    this_data = data;
    if ~ismatrix(this_data)
        error('data_one must be 0d, 1d or 2d.');
    end
    if data_as_rows
        datum = cell(1, size(this_data, 1));
        for i = 1:size(this_data, 1)
            datum{i} = this_data(i, :);
        end
    else
        datum = cell(1, size(this_data, 2));
        for i = 1:size(this_data, 2)
            datum{i} = this_data(:, i);
        end
    end
end
num_chan = length(datum);
if is_quat && num_chan ~= 4
    error('Must be a 4-element quaternion');
end
if iscell(time)
    assert(length(time) == num_chan, 'The number of time channels must match the number of data channels, not %i and %i.', length(time), num_chan);
    times = time;
else
    [times(1:num_chan)] = {time};
end
return


%% Subfunctions - build_indices
function [ix] = build_indices(times, rms_xmin, rms_xmax, label)

% Builds a dictionary of indices for the given RMS (or mean) start and stop times.

arguments
    times
    rms_xmin
    rms_xmax
    label {mustBeMember(label, ["one", "two"])} = 'one'
end

import matspace.plotting.get_rms_indices

ix = dictionary;
ix{'pts'} = zeros(1, 0);
ix{label} = cell(1, 0);
if isempty(times)
    % no times given, so nothing to calculate
    return
end
if isscalar(unique(cellfun(@length, times))) && max(cellfun(@(x) max(abs(x - times{1})), times)) < 1e-12
    % case where all the time vectors are exactly the same
    temp_ix = get_rms_indices(times{1}, xmin=rms_xmin, xmax=rms_xmax);
    ix{'pts'} = temp_ix{'pts'};
    ix{label} = {temp_ix{'one'}}; %#ok<CCAT1>
end
for i = 1:length(times)
    this_time = times{i};
    % general case
    temp_ix = get_rms_indices(this_time, xmin=rms_xmin, xmax=rms_xmax);
    if i == 1
        ix{'pts'} = temp_ix{'pts'};
    else
        ix_pts = ix{'pts'};
        tp_pts = temp_ix{'pts'};
        ix{'pts'} = [min([ix_pts(1), tp_pts(1)]), max([ix_pts(2), tp_pts(2)])];
    end
    ix{label} = [ix{label}, temp_ix{'one'}];
end


% %% Subfunctions - build_diff_indices
% def build_diff_indices(
% times1: list[_N] | list[_D] | None,
% times2: list[_N] | list[_D] | None,
% time_overlap: list[_N] | list[_D] | None,
% *,
% rms_xmin: _Time,
% rms_xmax: _Time,
% ) -> _RmsIndices:
% """Builds a dictionary of indices for the given RMS (or mean) start and stop times for multiple time vectors."""
% ix: _RmsIndices = {"pts": [], "one": [], "two": [], "overlap": []}
% if not times1 and not times2:
%     # have nothing
%     return ix
% if times1 and not times2:
%     # only have times1
%     return _build_indices(times1, rms_xmin, rms_xmax, label="one")
% if not times1 and times2:
%     # only have times2
%     return _build_indices(times2, rms_xmin, rms_xmax, label="two")
% # have both times and times2
% assert times1 is not None
% assert times2 is not None
% assert time_overlap is not None, "Must have overlap time when you have both times1 and times2."
% same_time = len({id(time) for time in times1}) == 1 and len({id(time) for time in times2}) == 1
% for i, (this_time1, this_time2, this_overlap) in enumerate(zip(times1, times2, time_overlap)):
%     if i == 0 or not same_time:
%         temp_ix = get_rms_indices(this_time1, this_time2, this_overlap, xmin=rms_xmin, xmax=rms_xmax)  # type: ignore[arg-type]
%     if i == 0:
%         ix["pts"] = temp_ix["pts"]
%     else:
%         ix["pts"] = [min((ix["pts"][0], temp_ix["pts"][0])), max((ix["pts"][1], temp_ix["pts"][1]))]
%     ix["one"].append(temp_ix["one"])
%     ix["two"].append(temp_ix["two"])
%     ix["overlap"].append(temp_ix["overlap"])
% return ix


%% Subfunctions - calc_rms
function [data_func, func_name] = calc_rms(datum, ix, kwargs)
% Calculates the RMS/mean.

arguments
    datum (1, :) cell
    ix (1, :) cell
    kwargs.UseMean (1, 1) logical
end

import matspace.utils.nanmean
import matspace.utils.nanrms

use_mean = kwargs.UseMean;

if ~use_mean
    func_name = 'RMS';
    func_lamb = @nanrms;
else
    func_name = 'Mean';
    func_lamb = @nanmean; %#ok<NANMEAN>
end
data_func = cell(1, length(datum));
for j = 1:length(datum)
    data = datum{j};
    data_func{j} = func_lamb(data(ix{j}));
end


%% Subfunctions - get_units
function [new_units, unit_conv, leg_units, leg_conv] = get_units(units, second_units, leg_scale)

% Get all the unit conversions.

import matspace.plotting.get_unit_conversion

[new_units, unit_conv] = get_unit_conversion(second_units, units);
if ~isempty(leg_scale)
    [leg_units, leg_conv] = get_unit_conversion(leg_scale, units);
else
    leg_units = new_units;
    leg_conv = unit_conv;
end


%% Subfunctions - get_ylabels
function [ylabels] = get_ylabels(num_channels, y_label, kwargs)

% Build the list of y-labels.

arguments
    num_channels (1, 1) double
    y_label  % cellstr or char or string
    kwargs.Elements  (1, :) string  % or cellstr?
    kwargs.SingleLines (1, 1) logical
    kwargs.Description (1, :) char  % or string scalar?
    kwargs.Units (1, :) char  % or string scalar?
end

elements = kwargs.Elements;
single_lines = kwargs.SingleLines;
description = kwargs.Description;
units = kwargs.Units;

if isempty(y_label)
    ylabels = cell(1, num_channels);
    if single_lines
        for i = 1:num_channels
            ylabels{i} = [elements{i},' [',units,']'];
        end
    else
        ylabels(1:end-1) = {''};
        if num_channels > 0
            ylabels{end} = [description,' [',units,']'];
        end
    end
elseif iscell(y_label)
    ylabels = y_label;
else
    ylabels = cell(1, num_channels);
    if single_lines
        ylabels(:) = {y_label};
    else
        ylabels(1:end-1) = {''};
        ylabels{end} = y_label;
    end
end
 

%% Subfunctions - create_figure
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


%% Subfunctions - plot_linear
function [line] = plot_linear(ax, time, data, symbol, varargin)
% Plots a normal linear plot with passthrough options.
try
    if all(isnan(data))
        line = [];
        return
    end
catch % TypeError
    % no-op  % likely categorical data that cannot be safely coerced to NaNs
end
line = plot(ax, time, data, symbol, varargin{:});
return


%% Subfunctions - plot_zoh
function [line] = plot_zoh(ax, time, data ,symbol, varargin)
%Plots a zero-order hold step plot with passthrough options.
try
    if all(isnan(data))
        line = [];
        return
    end
catch % TypeError
    % no-op  % likely categorical data that cannot be safely coerced to NaNs
end
line = stairs(ax, time, data, symbol, varargin{:});
return


%% Subfunctions - label_x
function [xlims] = label_x(this_axes, disp_xmin, disp_xmax, time_is_date, time_units, start_date)

% Build the list of x-labels.

arguments
    this_axes
    disp_xmin
    disp_xmax
    time_is_date (1, 1) logical
    time_units {mustBeTextScalar}
    start_date {mustBeTextScalar}
end

import matspace.plotting.disp_xlimits

if time_is_date
    xlabel(this_axes, 'Date');
    assert(time_units == "datetime", 'Expected time units of "datetime", not "%s".', time_units);
else
    xlabel(this_axes, ['Time [',time_units,']',start_date]);
    assert(time_units ~= "datetime", 'Expected time units of "seconds" or such, not "%s".', time_units);
end
disp_xlimits(this_axes, xmin=disp_xmin, xmax=disp_xmax);
xlims = xlim(this_axes);
return


%% Subfunctions - draw_lines
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