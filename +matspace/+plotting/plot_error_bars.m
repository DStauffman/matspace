function [fig] = plot_error_bars(description, time, data, mins, maxs, varargin)

% PLOT_ERROR_BARS  is a general plotting routine to make error bars.
%
%
% Input:
%     description : (row) name of the data being plotted [char]
%     time        : (1xN) time history [sec]
%     data        : (MxN) data array [any]
%     mins        : (MxN) data array [any]
%     maxs        : (MxN) data array [any]
%     varargin    : (char, value) pairs for other options, from:
%         'Elements'     : {1xN} of (row) of names of M data elements
%         'Units'        : (row) name of units for plots [char]
%         'TimeUnits'    : (row) type of the time units, nominally 'sec' [char]
%         'LegendScale'  : (row) prefix for get_factors to use to scale RMS in legend [char]
%         'StartDate'    : (row) date of t(0), may be an empty string [char]
%         'RmsXmin'      : (scalar) time for first point of RMS calculation [sec]
%         'RmsXmax'      : (scalar) time for last point of RMS calculation [sec]
%         'DispXmin'     : (scalar) time for first point of display [sec]
%         'DispMax'      : (scalar) time for last point of display [sec]
%         'FigVisible'   : (row) setting value for whether figure is visible, from {'on','off'} [char]
%         'SingleLines'  : (scalar) true/false flag meaning to plot subplots by channel instead of together [bool]
%         'ColorOrder'   : (3xN) color RGB triples for each channel of data [ndim]
%         'UseMean'      : (scalar) true/false flag to use mean instead of rms in calculations [bool]
%         'PlotZero'     : (scalar) true/false flag to always show zero on the vertical axis [bool]
%         'ShowRms'      : (scalar) true/false flag to show the RMS calculation in the legend [bool]
%         'LegendLoc'    : (row) location of the legend, from {'best', 'north', etc.} see legend for more details [char]
%         'SecondYScale' : (scalar or {1x2}) scale factor for second axis, if cell array, then label and scale factor [num]
%
% Output:
%     fig_hand : (scalar) list of figure handles [num]
%
% Prototype:
%     description    = 'Random Data Error Bars';
%     time           = datetime('now') + days(1:10);
%     data           = [3; -2; 5] + rand(3, length(time));
%     mins           = data - 0.5 * rand(size(data));
%     maxs           = data + 1.5 * rand(size(data));
%     elements       = {'x', 'y', 'z'};
%     units          = 'deg';
%     time_units     = 'datetime';
%     leg_scale      = 'milli';
%     start_date     = ['  t(0) = ', datestr(now)];
%     rms_xmin       = time(2);
%     rms_xmax       = time(end-1);
%     disp_xmin      = time(1) - days(2);
%     disp_xmax      = datetime('inf');
%     fig_visible    = true;
%     single_lines   = false;
%     color_lists    = matspace.plotting.get_color_lists();
%     colororder     = cell2mat(color_lists.default(1:3));
%     use_mean       = false;
%     plot_zero      = false;
%     show_rms       = true;
%     legend_loc     = 'Best';
%     second_y_scale = nan;
%     fig_hand       = matspace.plotting.plot_error_bars(description, time, data, mins, maxs, ...
%         'Elements', elements, 'Units', units, 'TimeUnits', time_units, 'LegendScale', leg_scale, ...
%         'StartDate', start_date, 'RmsXmin', rms_xmin, 'RmsXmax', rms_xmax, ...
%         'DispXmin', disp_xmin, 'DispXmax', disp_xmax, 'FigVisible', fig_visible, ...
%         'SingleLines', single_lines, 'ColorOrder', colororder, 'UseMean', use_mean, 'PlotZero', plot_zero, ...
%         'ShowRms', show_rms, 'LegendLoc', legend_loc, 'SecondYScale', second_y_scale);

%% Imports
import matspace.plotting.get_factors
import matspace.plotting.plot_rms_lines
import matspace.plotting.plot_second_yunits
import matspace.plotting.show_zero_ylim
import matspace.utils.nanmean
import matspace.utils.nanrms

%% Hard-coded values
leg_format  = '%1.3f';

%% Parser
% Validation functions
fun_is_num_or_cell = @(x) isnumeric(x) || iscell(x);
fun_is_cellstr     = @(x) isstring(x) || iscell(x);
fun_is_bound       = @(x) (isnumeric(x) || isdatetime(x)) && isscalar(x);
% Argument parser
p = inputParser;
addParameter(p, 'Elements', string(0), fun_is_cellstr);
addParameter(p, 'Units', '', @ischar);
addParameter(p, 'TimeUnits', 'sec', @ischar);
addParameter(p, 'LegendScale', 'unity', @ischar);
addParameter(p, 'StartDate', '', @ischar);
addParameter(p, 'RmsXmin', -inf, fun_is_bound);
addParameter(p, 'RmsXmax', inf, fun_is_bound);
addParameter(p, 'DispXmin', -inf, fun_is_bound);
addParameter(p, 'DispXmax', inf, fun_is_bound);
addParameter(p, 'FigVisible', true, @islogical);
addParameter(p, 'SingleLines', false, @islogical);
addParameter(p, 'ColorOrder', '', @isnumeric);
addParameter(p, 'UseMean', false, @islogical);
addParameter(p, 'PlotZero', false, @islogical);
addParameter(p, 'ShowRms', true, @islogical);
addParameter(p, 'LegendLoc', 'Best', @ischar);
addParameter(p, 'SecondYScale', nan, fun_is_num_or_cell);
parse(p, varargin{:});
elements        = p.Results.Elements;
units           = p.Results.Units;
time_units      = p.Results.TimeUnits;
leg_scale       = p.Results.LegendScale;
start_date      = p.Results.StartDate;
rms_xmin        = p.Results.RmsXmin;
rms_xmax        = p.Results.RmsXmax;
disp_xmin       = p.Results.DispXmin;
disp_xmax       = p.Results.DispXmax;
single_lines    = p.Results.SingleLines;
colororder      = p.Results.ColorOrder;
use_mean        = p.Results.UseMean;
plot_zero       = p.Results.PlotZero;
show_rms        = p.Results.ShowRms;
legend_loc      = p.Results.LegendLoc;
second_y_scale  = p.Results.SecondYScale;
if p.Results.FigVisible
    fig_visible = 'on';
else
    fig_visible = 'off';
end
% determine if using datetimes
use_datetime = isdatetime(time);

%% Calculations
% build RMS indices
rms_ix   = time >= rms_xmin & time <= rms_xmax;
rms_pts1 = max([rms_xmin min(time)]);
rms_pts2 = min([rms_xmax max(time)]);
% calculate the rms (or mean) values
if ~use_mean
    func_name = 'RMS';
    data_func = nanrms(data(:,rms_ix),2);
else
    func_name = 'Mean';
    data_func = nanmean(data(:,rms_ix),2);
end
num_channels = length(elements);
% unit conversion value
[temp, prefix] = get_factors(leg_scale);
leg_conv = 1/temp;
% error calculations
err_neg = mins - data;
err_pos = maxs - data;

%% Plot
% create figure
fig = figure('name', description, 'Visible', fig_visible);
% create axes
if single_lines
    ax = gobjects(1, num_channels);
    for i = 1:num_channels
        ax(i) = axes(fig); %#ok<LAXES>
        subplot(num_channels, 1, i, ax(i));
    end
else
    ax = axes(fig);
end
% loop through channels
for i = 1:length(ax)
    % get the axis, either all one or individual ones
    if single_lines
        this_axes = ax(i);
    else
        this_axes = ax;
    end
    hold(this_axes, 'on');
    if single_lines
        loops = i:i;
    else
        loops = 1:num_channels;
    end
    for j = loops
        % get the name
        if show_rms
            this_name = [elements{j},' (',func_name,': ',num2str(leg_conv*data_func(j),leg_format),' ',prefix,units,')'];
        else
            this_name = elements{j};
        end
        % get the color
        this_color = colororder(j, :);
        % plot data
        plot(this_axes, time, data(j, :), '.-', 'DisplayName', this_name, 'Color', this_color);
        % plot error bars
        if use_datetime
            errbar_group = hggroup('DisplayName', 'Error Bars');
            set(get(get(errbar_group,'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
            for k = 1:length(time)
                h = line(this_axes, [time(k), time(k)], data(j, k) + [err_neg(j, k), err_pos(j, k)], 'Color', this_color, 'Marker', '+');
                set(h, 'Parent', errbar_group);
            end
        else
            h = errorbar(this_axes, time, data(j, :), err_neg(j, :), err_pos(j, :), 'Color', this_color);
            % turn error box off from the legend
            set(get(get(h, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
        end
    end
    % get some values
    if i == 1
        xl = xlim(this_axes);
        if isfinite(disp_xmin)
            xl(1) = max([xl(1) disp_xmin]);
        end
        if isfinite(disp_xmax)
            xl(2) = min([xl(2) disp_xmax]);
        end
        if use_datetime
            xlab = 'Date';
        else
            xlab = ['Time [',time_units,']',start_date];
        end
    end
    % manipulate the plot
    xlim(this_axes, xl);
    if plot_zero
        show_zero_ylim(this_axes);
    end
    legend(this_axes, 'show', 'Location', legend_loc);
    title(this_axes, description, 'interpreter', 'none'); % TODO: always add a title?  What about sgtitle?
    xlabel(this_axes, xlab);
    ylabel(this_axes, ['Value [',units,']']);
    grid(this_axes, 'on');
    % create second Y axis
    if iscell(second_y_scale)
        plot_second_yunits(this_axes, second_y_scale{1}, second_y_scale{2});
    elseif ~isnan(second_y_scale) && second_y_scale ~= 0
        new_y_label = ''; % TODO: keep this option or always make a cell?
        plot_second_yunits(this_axes, new_y_label, second_y_scale);
    end
    % plot RMS lines
    if show_rms
        plot_rms_lines(this_axes, [rms_pts1, rms_pts2], ylim(this_axes));
    end
    hold(this_axes, 'off'); % TODO: don't due in newer Matlab?
end
% link axes to zoom together
if length(ax) > 1
    linkaxes(ax, 'x');
end