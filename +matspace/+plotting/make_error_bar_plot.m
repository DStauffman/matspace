function [fig_hand] = make_error_bar_plot(description, time, data, mins, maxs, varargin)

% Generic plotting routine to make error bars.
%
% Input:
% fig : class matplotlib.Figure
%     figure handle
%
% Output:
% fig_hand : figure handle
%
% Change Log:
%     1.  Written by David C. Stauffer in MATLAB in October 2011, updated in 2018.
%     2.  Ported to Python by David C. Stauffer in March 2019.
%     3.  Made fully functional by David C. Stauffer in April 2020.
%     4.  Wrapped to the generic do everything version by David C. Stauffer in March 2021
%     5.  Ported to Matlab by David C. Stauffer in January 2026.
% 
% Prototype:
%     description      = 'Random Data Error Bars';
%     time             = 0:10;
%     data             = [3.0; -2.0; 5.0] + rand(3, 11);
%     mins             = data - 0.5 * rand(3, 11);
%     maxs             = data + 1.5 * rand(3, 11);
%     name             = ''
%     elements         = ["x", "y", "z"];
%     units            = 'rad';
%     time_units       = 'sec';
%     start_date       = [', t0 = ',char(datetime('now'))];
%     rms_xmin         = 1;
%     rms_xmax         = 10;
%     disp_xmin        = -2;
%     disp_xmax        = inf;
%     single_lines     = false;
%     color_map        = matspace.plotting.colors.tab10();
%     use_mean         = false;
%     plot_zero        = false;
%     show_rms         = true;
%     legend_loc       = 'best';
%     second_units     = 'milli';
%     legend_scale     = '';
%     y_label          = '';
%     data_as_rows     = true;
%     extra_plotter    = [];
%     use_zoh          = false;
%     label_vert_lines = true;
%     fig_ax           = [];
%     fig_hand  = matspace.plotting.make_error_bar_plot(description, time, data, mins, maxs, Name=name, ...
%         Elements=elements, Units=units, TimeUnits=time_units, StartDate=start_date, ...
%         RmsXmin=rms_xmin, RmsXmax=rms_xmax, DispXmin=disp_xmin, DispXmax=disp_xmax, ...
%         single_lines=single_lines, colormap=colormap, use_mean=use_mean, plot_zero=plot_zero, ...
%         ShowRms=show_rms, LegendLoc=legend_loc, SecondUnits=second_units, ...
%         LegendScale=legend_scale, YLabel=y_label, DataAsRows=data_as_rows, ...
%         ExtraPlotter=extra_plotter, UseZoh=use_zoh, LabelVertLines=label_vert_lines, ...
%         FigAx=fig_ax);
%
%     % Close plots
%     close(fig_hand);

%% Imports
import matspace.plotting.colors.ColorMap
import matspace.plotting.ignore_plot_data
import matspace.plotting.plot_second_units_wrapper
import matspace.plotting.private.build_indices
import matspace.plotting.private.calc_rms
import matspace.plotting.private.create_figure
import matspace.plotting.private.fun_is_2nd_units
import matspace.plotting.private.fun_is_bool
import matspace.plotting.private.fun_is_bound
import matspace.plotting.private.fun_is_colormap
import matspace.plotting.private.fun_is_data
import matspace.plotting.private.fun_is_extra_plotter
import matspace.plotting.private.fun_is_fig_ax
import matspace.plotting.private.fun_is_text
import matspace.plotting.private.fun_is_time
import matspace.plotting.private.get_units
import matspace.plotting.private.get_ylabels
import matspace.plotting.private.label_x
import matspace.plotting.private.make_time_and_data_lists
import matspace.plotting.plot_vert_lines
import matspace.plotting.show_zero_ylim
import matspace.utils.ifelse

%% Parser
% Argument parser
p = inputParser;
addRequired(p, 'Description', @fun_is_text);
addRequired(p, 'Time', @fun_is_time);
addRequired(p, 'Data', @fun_is_data);
addRequired(p, 'Mins', @fun_is_data);
addRequired(p, 'Maxs', @fun_is_data);
addParameter(p, 'Name', '', @fun_is_text);
addParameter(p, 'Elements', strings(0), @isstring);
addParameter(p, 'Units', '', @fun_is_text);
addParameter(p, 'TimeUnits', 'sec', @fun_is_text);
addParameter(p, 'StartDate', '', @fun_is_text);
addParameter(p, 'RmsXmin', -inf, @fun_is_bound);
addParameter(p, 'RmsXmax', inf, @fun_is_bound);
addParameter(p, 'DispXmin', -inf, @fun_is_bound);
addParameter(p, 'DispXmax', inf, @fun_is_bound);
addParameter(p, 'FigVisible', true, @fun_is_bool);
addParameter(p, 'ColorMap', [], @fun_is_colormap);
addParameter(p, 'UseMean', false, @fun_is_bool);
addParameter(p, 'PlotZero', false, @fun_is_bool);
addParameter(p, 'ShowRms', true, @fun_is_bool);
addParameter(p, 'IgnoreEmpties', false, @fun_is_bool);
addParameter(p, 'LegendLoc', 'Best', @fun_is_text);
addParameter(p, 'SecondUnits', nan, @fun_is_2nd_units);
addParameter(p, 'LegendScale', 'unity', @fun_is_2nd_units);
addParameter(p, 'YLabel', '', @fun_is_text);
addParameter(p, 'YLims', [], @fun_is_lim);
addParameter(p, 'DataAsRows', true, @fun_is_bool);
addParameter(p, 'ExtraPlotter', [], @fun_is_extra_plotter);
addParameter(p, 'LabelVertLines', false, @fun_is_bool);
addParameter(p, 'FigAx', [], @fun_is_fig_ax);
% do parse
parse(p, description, time, data, mins, maxs, varargin{:});
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
fig_ax           = p.Results.FigAx;
fig_visible      = ifelse(p.Results.FigVisible, 'on', 'off');

% hard-coded values
return_err = nargout > 1;  % TODO: remove this restriction

% build lists of time and data
[times, datum] = make_time_and_data_lists(time, data, DataAsRows=data_as_rows);
num_channels = length(times);
time_is_date = ~isempty(times) && isdatetime(times{1});

% optional inputs
if isempty(elements)
    elements = "Channel " + arrayfun(@string, 1:num_channels);
end
if length(elements) ~= num_channels
    error('The given elements need to match the data sizes, got %i and %i.', num_channels, length(elements));
end

% build RMS indices
if show_rms || return_err
    ix = build_indices(times, rms_xmin, rms_xmax);
end

% create a colormap
cm = ColorMap(colormap=color_map);

% calculate the rms (or mean) values
if show_rms || return_err
    [data_func, func_name] = calc_rms(datum, ix.one, UseMean=use_mean);
end

% unit conversion value
[new_units, unit_conv, leg_units, leg_conv] = get_units(units, second_units, legend_scale);

% plotting options
if use_zoh
    plot_func = @plot_zoh;
else
    plot_func = @plot_linear;
end
symbol = '.-';

% extra errorbar calculations
err_neg = cell(size(datum));
if isvector(mins)
    err_neg(:) = cellfun(@(x) x - mins, datum, UniformOutput=false);
elseif data_as_rows
    for i = 1:numel(datum)
        err_neg(i) = datum{i} - mins(i, :);
    end
else
    for i = 1:numel(datum)
        err_neg(i) = datum{i} - mins(:, i);
    end
end
err_pos = cell(size(datum));
if isvector(maxs)
    err_pos(:) = cellfun(@(x) maxs - x, datum, UniformOutput=false);
elseif data_as_rows
    for i = 1:numel(datum)
        err_pos(i) = maxs(i, :) - datum{i};
    end
else
    for i = 1:numel(datum)
        err_pos(i) = maxs(:, i) - datum{i};
    end
end

% build labels
y_labels = get_ylabels(num_channels, y_label, Elements=elements, SingleLines=single_lines, Description=description, Units=units);

if isempty(fig_ax)
    % get the number of figures and axes to make
    num_figs = 1;
    num_rows = ifelse(single_lines, num_channels, 1);
    num_cols = 1;
    fig_ax = create_figure(num_figs, num_rows, num_cols, Description=description, Visible=fig_visible);
    if ~single_lines
        fig_ax = repmat(fig_ax, [1 num_channels]);
    end
end
assert(length(fig_ax) == num_channels, 'Expecting a (figure, axes) pair for each channel in data.');
fig_hand = fig_ax{1}{1};
if single_lines
    ax = cellfun(@(x) x{2}, fig_ax);
else
    ax = fig_ax{1}{2};
end

for i = 1:num_channels
    this_axes = fig_ax{i}{2};
    this_time = times{i};
    this_data = datum{i};
    this_err_neg = err_neg{i};
    this_err_pos = err_pos{i};
    this_ylabel  = y_labels{i};
    if ~isempty(name)
        this_label = [char(name),' ',elements{i}];
    else
        this_label = elements{i};
    end
    if show_rms
        value = num2str(leg_conv * data_func{i}, LEG_FORMAT);
        if ~isempty(leg_units)
            this_label = [this_label, ' (',func_name,': ',value,' ',leg_units,')'];  %#ok<AGROW>
        else
            this_label = [this_label, ' (',func_name,': ',value,')'];  %#ok<AGROW>
        end
    end
    this_color = cm.get_color(i);
    plot_func(...
        this_axes, ...
        this_time, ...
        this_data, ...
        symbol, ...
        markersize=4, ...
        markerfacecolor='none', ...
        label=this_label, ...
        color=this_color);  % zorder=3
    % plot error bars
    this_yerr = [this_err_neg; this_err_pos];
    this_axes.errorbar(...
        this_time, ...
        this_data, ...
        yerr=this_yerr, ...
        color="None", ...
        ecolor=cm.get_color(i), ...
        capsize=2);  % zorder=5
    x_lim = label_x(this_axes, disp_xmin, disp_xmax, time_is_date, time_units, start_date);
    zoom_ylim(this_axes, t_start=x_lim(1), t_final=x_lim(2));
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
    fig.supylabel(description);
end

% plot any extra information through a generic callable
if ~isempty(extra_plotter)
    extra_plotter(fig_hand, ax);
end

% add legend at the very end once everything has been done
if ~strcmpi(legend_loc, 'none')
    for i = 1:length(ax)
        this_axes = ax(i);
        legend(this_axes, 'show', 'Location', legend_loc);
    end
end
