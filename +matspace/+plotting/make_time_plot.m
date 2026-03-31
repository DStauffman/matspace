function [fig] = make_time_plot(description, time, data, varargin)

% MAKE_TIME_PLOT  plots data versus time.
%
% Input:
%     (TBD)
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
%     color_map        = validatecolor('b');
%     use_mean         = false;
%     plot_zero        = false;
%     show_rms         = true;
%     legend_loc       = 'best';
%     second_units     = '';
%     legend_scale     = '';
%     y_label          = '';
%     data_as_rows     = true;
%     extra_plotter    = [];
%     use_zoh          = false;
%     label_vert_lines = true;
%     use_datashader   = false;
%     fig_ax           = [];
%     fig_hand = matspace.plotting.make_time_plot(description, time, data, Name=name, Elements=elements, ...
%         Units=units, TimeUnits=time_units, StartDate=start_date, RmsXmin=rms_xmin, RmsXmax=rms_xmax, ...
%         DispXmin=disp_xmin, DispXmax=disp_xmax, SingleLines=single_lines, ColorMap=color_map, ...
%         UseMean=use_mean, PlotZero=plot_zero, ShowRms=show_rms, LegendLoc=legend_loc, ...
%         SecondUnits=second_units, LegendScale=legend_scale, YLabel=y_label, DataAsRows=data_as_rows, ...
%         ExtraPlotter=extra_plotter, UseZoh=use_zoh, LabelVertLines=label_vert_lines, ...
%         UseDatashader=use_datashader, FigAx=fig_ax);
%
%     % Close plots
%     close(fig_hand);
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2026.

%% Imports
import matspace.plotting.colors.ColorMap
import matspace.plotting.plot_second_units_wrapper
import matspace.plotting.private.build_indices
import matspace.plotting.private.calc_rms
import matspace.plotting.private.create_figure
import matspace.plotting.private.draw_lines
import matspace.plotting.private.fun_is_2nd_units
import matspace.plotting.private.fun_is_bool
import matspace.plotting.private.fun_is_bound
import matspace.plotting.private.fun_is_colormap
import matspace.plotting.private.fun_is_data
import matspace.plotting.private.fun_is_extra_plotter
import matspace.plotting.private.fun_is_fig_ax
import matspace.plotting.private.fun_is_lim
import matspace.plotting.private.fun_is_text
import matspace.plotting.private.fun_is_time
import matspace.plotting.private.get_units
import matspace.plotting.private.get_ylabels
import matspace.plotting.private.label_x
import matspace.plotting.private.make_time_and_data_lists
import matspace.plotting.private.plot_linear
import matspace.plotting.private.plot_zoh
import matspace.plotting.plot_vert_lines
import matspace.plotting.show_zero_ylim
import matspace.plotting.zoom_ylim
import matspace.utils.ifelse

%% Hard-coded values
leg_format  = '%1.3f';

%% Parser
% Argument parser
p = inputParser;
addRequired(p, 'Description', @fun_is_text);
addRequired(p, 'Time', @fun_is_time);
addRequired(p, 'Data', @fun_is_data);
addParameter(p, 'Name', '', @fun_is_text);
addParameter(p, 'Elements', strings(0), @isstring);
addParameter(p, 'Units', '', @fun_is_text);
addParameter(p, 'TimeUnits', 'sec', @fun_is_text);
addParameter(p, 'StartDate', '', @fun_is_text);
addParameter(p, 'RmsXmin', -inf, @fun_is_bound);
addParameter(p, 'RmsXmax', inf, @fun_is_bound);
addParameter(p, 'DispXmin', -inf, @fun_is_bound);
addParameter(p, 'DispXmax', inf, @fun_is_bound);
addParameter(p, 'SingleLines', false, @fun_is_bool);
addParameter(p, 'FigVisible', true, @fun_is_bool);
addParameter(p, 'ColorMap', parula(8), @fun_is_colormap);
addParameter(p, 'UseMean', false, @fun_is_bool);
addParameter(p, 'PlotZero', false, @fun_is_bool);
addParameter(p, 'ShowRms', true, @fun_is_bool);
addParameter(p, 'LegendLoc', 'Best', @fun_is_text);
addParameter(p, 'SecondUnits', nan, @fun_is_2nd_units);
addParameter(p, 'LegendScale', 'unity', @fun_is_2nd_units);
addParameter(p, 'YLabel', '', @fun_is_text);
addParameter(p, 'YLims', [], @fun_is_lim);
addParameter(p, 'DataAsRows', true, @fun_is_bool);
addParameter(p, 'ExtraPlotter', [], @fun_is_extra_plotter);
addParameter(p, 'UseZoh', false, @fun_is_bool);
addParameter(p, 'LabelVertLines', false, @fun_is_bool);
addParameter(p, 'UseDatashader', false, @fun_is_bool);
addParameter(p, 'FigAx', [], @fun_is_fig_ax);
addParameter(p, 'PlotType', 'time', @(x) isscalar(x) && any(x == ["plot", "scatter"]));
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
legend_scale     = p.Results.LegendScale;
y_label          = p.Results.YLabel;
ylims            = p.Results.YLims;
data_as_rows     = p.Results.DataAsRows;
extra_plotter    = p.Results.ExtraPlotter;
use_zoh          = p.Results.UseZoh;
label_vert_lines = p.Results.LabelVertLines;
use_datashader   = p.Results.UseDatashader;
fig_ax           = p.Results.FigAx;
plot_type        = p.Results.PlotType;
fig_visible      = ifelse(p.Results.FigVisible, 'on', 'off');

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
    [data_func, func_name] = calc_rms(datum, ix.one, UseMean=use_mean);
end

% create a colormap
cm = ColorMap(color_map);

% unit conversion value
[new_units, unit_conv, leg_units, leg_conv] = get_units(units, second_units, legend_scale);

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
y_labels = get_ylabels(num_channels, y_label, Elements=elements, SingleLines=single_lines, Description=description, Units=units);

if isempty(fig_ax) || isempty(fig_ax{1})
    % get the number of figures and axes to make
    num_figs = 1;
    if single_lines
        num_rows = num_channels;
    else
        num_rows = 1;
    end
    num_cols = 1;
    fig_ax = create_figure(num_figs, num_rows, num_cols, Description=description, Visible=fig_visible);
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
    this_ylabel = y_labels{i};
    if ~isempty(name)
        this_label = [name,' ',elements{i}];
    else
        this_label = elements{i};
    end
    if show_rms
        value = num2str(leg_conv * data_func{i}, leg_format);
        if ~isempty(leg_units)
            this_label = [this_label,' (',func_name,': ',num2str(value),' ',leg_units,')']; %#ok<AGROW>
        else
            this_label = [this_label,' (',func_name,': ',num2str(value),')']; %#ok<AGROW>
        end
    end
    draw_lines(datashaders, this_time, this_data, plot_func, this_axes, Symbol=symbol, MarkerSize=4, ...
        Color=cm.get_color(i), Label=this_label, ZOrder=9, UseDatashader=use_datashader);
    xlims = label_x(this_axes, disp_xmin, disp_xmax, time_is_date, time_units, start_date);
    zoom_ylim(this_axes, [], [], TStart=xlims(1), TFinal=xlims(2));
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
        ylabel(this_axes, this_ylabel);
        grid(this_axes, 'on');
        % optionally add second Y axis
        plot_second_units_wrapper(this_axes, {new_units, unit_conv});
        % plot RMS lines
        if show_rms
            vert_labels = ifelse(~use_mean, strings(1, 0), ["Mean Start Time", "Mean Stop Time"]);
            plot_vert_lines(this_axes, ix.pts, ShowInLegend=label_vert_lines, Labels=vert_labels);
        end
    end
end

if single_lines
    fig.supylabel(description)
end

% plot any extra information through a generic callable
if ~isempty(extra_plotter)  % test if callable instead?
    extra_plotter(fig, ax);
end

% overlay the datashaders (with appropriate time units information)
if ~isempty(datashaders)
    error('Datashader not yet implemented in Matlab');
%     for i = 1:length(datashaders)
%         this_ds = datashaders(i);
%         this_ds.time_units = time_units;
%     end
%     add_datashaders(datashaders)
end

% add legend at the very end once everything has been done
if ~strcmpi(legend_loc, 'none')
    for i = 1:length(ax)
        this_axes = ax(1);
        legend(this_axes, 'show', Location=legend_loc);
    end
end
