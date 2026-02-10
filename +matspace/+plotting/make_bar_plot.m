function [fig_hand] = make_bar_plot(description, time, data, varargin)

% Plots a filled bar chart, using methods optimized for larger data sets.
%
% Input:
% fig : class matplotlib.Figure
%     figure handle
%
% Output:
% fig_hand : figure handle
%
% Prototype:
%     description      = 'Test vs Time';
%     time             = 2000:1/12:2005;
%     data             = rand(5, length(time));
%     mag              = sum(data, 1);
%     data             = 100 * data / mag;
%     name             = '';
%     elements         = strings(1, 0);
%     units            = '%';
%     time_units       = 'sec';
%     start_date       = '';
%     rms_xmin         = -inf;
%     rms_xmax         = inf;
%     disp_xmin        = -inf;
%     disp_xmax        = inf;
%     color_map        = matspace.plotting.colors.paired();
%     use_mean         = true;
%     plot_zero        = false;
%     show_rms         = true;
%     ignore_empties   = false;
%     legend_loc       = 'best';
%     second_units     = '';
%     y_label          = '';
%     data_as_rows     = true;
%     extra_plotter    = [];
%     label_vert_lines = true;
%     fig_ax           = [];
%     fig_hand = matspace.plotting.make_bar_plot(description, time, data, Name=name, Elements=elements, ...
%         Units=units, TimeUnits=time_units, StartDate=start_date, RmsXmin=rms_xmin, RmsXmax=rms_xmax, ...
%         DispXmin=disp_xmin, DispXmax=disp_xmax, ColorMap=color_map, UseMean=use_mean, ...
%         PlotZero=plot_zero, ShowRms=show_rms, IgnoreEmpties=ignore_empties, ...
%         LegendLoc=legend_loc, SecondUnits=second_units, YLabel=y_label, DataAsRows=data_as_rows, ...
%         ExtraPlotter=extra_plotter, LabelVertLines=label_vert_lines, FigAx=fig_ax);
%
%     % Close plots
%     close(fig_hand);
%
% Change Log:
%     1.  Written by David C. Stauffer in March 2021.
%     2.  Translated in Matlab by David C. Stauffer in January 2026.

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
color_map        = p.Results.ColorMap;
use_mean         = p.Results.UseMean;
plot_zero        = p.Results.PlotZero;
show_rms         = p.Results.ShowRms;
ignore_empties   = p.Results.IgnoreEmpties;
legend_loc       = p.Results.LegendLoc;
second_units     = p.Results.SecondUnits;
% legend_scale     = p.Results.LegendScale;
y_label          = p.Results.YLabel;
ylims            = p.Results.YLims;
data_as_rows     = p.Results.DataAsRows;
extra_plotter    = p.Results.ExtraPlotter;
label_vert_lines = p.Results.LabelVertLines;
fig_ax           = p.Results.FigAx;
fig_visible      = ifelse(p.Results.FigVisible, 'on', 'off');

% hard-coded values
return_err   = nargout > 1;  % TODO: remove this restriction
legend_scale = {'%', 1.0};
LEG_FORMAT   = '%1.3f';

% check for valid data
if ignore_plot_data(data, ignore_empties)
    error('You must have some data to plot.');
end

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
cm = ColorMap(color_map);

% calculate the rms (or mean) values
if show_rms || return_err
    [data_func, func_name] = calc_rms(datum, ix.one, UseMean=use_mean);
end

% unit conversion value
[new_units, unit_conv, leg_units, leg_conv] = get_units(units, second_units, legend_scale);

% extra bar calculations
last = zeros(size(datum{1}));
bottoms = cell(1, length(datum) + 1);
bottoms{1} = last;
for i = 1:length(datum)
    this_data = datum{i};
    bottoms{i + 1} = last(~isnan(this_data));
end

% build labels
y_labels_r = get_ylabels(num_channels, y_label, Elements=elements, SingleLines=false, Description=description, Units=units);
y_labels = y_labels_r(end:-1:1);

if isempty(fig_ax)
    temp = create_figure(1, 1, 1, Description=description, Visible=fig_visible);
    fig_ax = temp{1};
end
fig_hand = fig_ax{1};
ax = fig_ax{2};

for i = num_channels:-1:1
    this_ylabel = y_labels{i};
    this_label = elements{i};
    if ~isempty(this_label)
        this_label = [char(name),' ',this_label];  %#ok<AGROW>
    end
    if show_rms
        value = num2str(leg_conv * data_func{i}, LEG_FORMAT);
        if ~isempty(leg_units)
            this_label = [this_label, ' (',func_name,': ',value,' ',leg_units,')'];  %#ok<AGROW>
        else
            this_label = [this_label, ' (',func_name,': ',value,')'];  %#ok<AGROW>
        end
    end
    if ~ignore_plot_data(datum{i}, ignore_empties)
        % Note: The performance of ax.bar is really slow with large numbers of bars (>20), so
        % fill_between is a better alternative
        ax.fill_between(...
            times{i}, ...
            bottoms{i}, ...
            bottoms{i + 1}, ...
            step='mid', ...
            label=this_label, ...
            color=cm.get_color(i), ...
            edgecolor='none');
    end
    if i == 1
        label_x(ax, disp_xmin, disp_xmax, time_is_date, time_units, start_date);
        ylim(ax, [0, 100]);
        if plot_zero
            show_zero_ylim(ax);
        end
        if ~isempty(ylims)
            ylim(ax, ylims);
        end
        title(ax, description);
        if ~isempty(this_ylabel)
            ylabel(ax, this_ylabel);
            grid(ax, 'on');
            % optionally add second Y axis
            plot_second_units_wrapper(ax, {new_units, unit_conv});
            % plot RMS lines
            if show_rms
                vert_labels = ifelse(~use_mean, [], ["Mean Start Time", "Mean Stop Time"]);
                plot_vert_lines(ax, ix.pts, ShowInLegend=label_vert_lines, Labels=vert_labels);
            end
        end
    end
end

% plot any extra information through a generic callable
if ~isempty(extra_plotter)
    extra_plotter(fig_hand, ax);
end

% add legend at the very end once everything has been done
if ~strcmpi(legend_loc, 'none')
    legend(ax, 'show', 'Location', legend_loc);
end