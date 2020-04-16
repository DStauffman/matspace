function [fig_hand,err] = general_difference_plot(description, time_one, time_two, data_one, data_two, varargin)

% GENERAL_DIFFERENCE_PLOT  is a general difference comparsion plot for use in plot_los.
%
% Summary:
%     This function plots two histories over time, along with a difference from one another.
%
% Input:
%     description   : (row) name of the data being plotted [char]
%     time_one      : (1xN) time history for channel 1 [sec]
%     time_two      : (1xN) time history for channel 2 [sec]
%     data_one      : (MxN) data array [any]
%     data_two      : (MxN) data array [any]
%     varargin .... : (char, value) pairs for other options, from:
%         'NameOne'      : (row) name of data source 1 [char]
%         'NameTwo'      : (row) name of data source 2 [char]
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
%         'MakeSubplots' : (scalar) true/false flag to use subplots [bool]
%         'SingleLines'  : (scalar) true/false flag meaning to plot subplots by channel instead of together [bool]
%         'ColorOrder'   : (3xN) color RGB triples for each channel of data [ndim]
%         'UseMean'      : (scalar) true/false flag to use mean instead of rms in calculations [bool]
%         'PlotZero'     : (scalar) true/false flag to always show zero on the vertical axis [bool]
%         'ShowRms'      : (scalar) true/false flag to show the RMS calculation in the legend [bool]
%         'LegendLoc'    : (row) location of the legend, from {'best', 'north', etc.} see legend for more details [char]
%         'ShowExtra'    : (scalar) true/false flag on whether to show missing data on diff plot [bool]
%         'SecondYScale' :
%         'TruthName'    : (1xN string) names of the truth structures [char]
%         'TruthTime'    : (1xN) time history for the truth data [sec]
%         'TruthData'    : (1xN) truth data array [num]
%
% Output:
%     fig_hand      : (scalar or 1x2) list of figure handles [num]
%     err           : (struct) error outputs
%         .one      : (Mx1) RMS/mean of data one [num]
%         .two      : (Mx1) RMS/mean of data two [num]
%         .diff     : (Mx1) RMS/mean of difference between one and two [num]
%
% Prototype:
%     description    = 'example';
%     time_one       = 0:10;
%     time_two       = 2:12;
%     data_one       = rand(2,11)*1e-6;
%     data_two       = data_one(:,[3:11 1 2]) - 0.5e-7*rand(2,11);
%     name_one       = 'test1';
%     name_two       = 'test2';
%     elements       = {'x','y'};
%     units          = 'rad';
%     time_units     = 'sec';
%     leg_scale      = 'micro';
%     start_date     = ['  t(0) = ', datestr(now)];
%     rms_xmin       = 1;
%     rms_xmax       = 10;
%     disp_xmin      = -2;
%     disp_xmax      = inf;
%     fig_visible    = true;
%     make_subplots  = true;
%     single_lines   = false;
%     color_lists    = matspace.plotting.get_color_lists();
%     colororder     = [cell2mat(color_lists.dbl_diff); cell2mat(color_lists.two)];
%     use_mean       = false;
%     plot_zero      = false;
%     show_rms       = true;
%     legend_loc     = 'Best';
%     show_extra     = true;
%     second_y_scale = nan;
%     truth_name     = "Truth";
%     truth_time     = [];
%     truth_data     = [];
%     [fig_hand, err] = matspace.plotting.general_difference_plot(description, time_one, time_two, data_one, data_two, ...
%         'NameOne', name_one, 'NameTwo', name_two, 'Elements', elements, 'Units', units, 'TimeUnits', time_units, ...
%         'LegendScale', leg_scale, 'StartDate', start_date, 'RmsXmin', rms_xmin, 'RmsXmax', rms_xmax, ...
%         'DispXmin', disp_xmin, 'DispXmax', disp_xmax, 'FigVisible', fig_visible, 'MakeSubplots', make_subplots, ...
%         'SingleLines', single_lines, 'ColorOrder', colororder, 'UseMean', use_mean, 'PlotZero', plot_zero, ...
%         'ShowRms', show_rms, 'LegendLoc', legend_loc, 'ShowExtra', show_extra, 'SecondYScale', second_y_scale, ...
%         'TruthName', truth_name, 'TruthTime', truth_time, 'TruthData', truth_data);
%
% See Also:
%     matspace.plotting.plot_time_history
%
% Change Log:
%     1.  Functionalized by David C. Stauffer in October 2011.
%     2.  Incorporated by David C. Stauffer into matspace in February 2019.
%     3.  Updated by David C. Stauffer in February 2019 to allow different time histories.
%     4.  Updated by David C. Stauffer in March 2019 to use name-value pairs, and add options for
%         truth histories, second y scales, and display limits.
%     5.  Updated by David C. Stauffer in April 2020 to put into a package.

%% Imports
import matspace.plotting.get_factors
import matspace.plotting.plot_rms_lines
import matspace.utils.nanmean
import matspace.utils.nanrms

%% Hard-coded values
leg_format  = '%1.3f';
truth_color = [0 0 0];

%% Parser
% Validation functions
fun_is_num_or_cell = @(x) isnumeric(x) || iscell(x);
fun_is_cellstr     = @(x) isstring(x) || iscell(x);
fun_is_time        = @(x) (isnumeric(x) || isdatetime(x)) && (isempty(x) || isvector(x));
fun_is_bound       = @(x) (isnumeric(x) || isdatetime(x)) && isscalar(x);
% Argument parser
p = inputParser;
addParameter(p, 'NameOne', '', @ischar);
addParameter(p, 'NameTwo', '', @ischar);
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
addParameter(p, 'MakeSubplots', true, @islogical);
addParameter(p, 'SingleLines', false, @islogical);
addParameter(p, 'ColorOrder', '', @isnumeric);
addParameter(p, 'UseMean', false, @islogical);
addParameter(p, 'PlotZero', false, @islogical);
addParameter(p, 'ShowRms', true, @islogical);
addParameter(p, 'LegendLoc', 'Best', @ischar);
addParameter(p, 'ShowExtra', true, @islogical);
addParameter(p, 'SecondYScale', nan, fun_is_num_or_cell);
addParameter(p, 'TruthName', "Truth", fun_is_cellstr);
addParameter(p, 'TruthTime', [], fun_is_time);
addParameter(p, 'TruthData', [], @isnumeric);
parse(p, varargin{:});
name_one        = p.Results.NameOne;
name_two        = p.Results.NameTwo;
elements        = p.Results.Elements;
units           = p.Results.Units;
time_units      = p.Results.TimeUnits;
leg_scale       = p.Results.LegendScale;
start_date      = p.Results.StartDate;
rms_xmin        = p.Results.RmsXmin;
rms_xmax        = p.Results.RmsXmax;
disp_xmin       = p.Results.DispXmin;
disp_xmax       = p.Results.DispXmax;
make_subplots   = p.Results.MakeSubplots;
single_lines    = p.Results.SingleLines;
colororder      = p.Results.ColorOrder;
use_mean        = p.Results.UseMean;
plot_zero       = p.Results.PlotZero;
show_rms        = p.Results.ShowRms;
legend_loc      = p.Results.LegendLoc;
show_extra      = p.Results.ShowExtra;
second_y_scale  = p.Results.SecondYScale;
truth_name      = p.Results.TruthName;
truth_time      = p.Results.TruthTime;
truth_data      = p.Results.TruthData;
if p.Results.FigVisible
    fig_visible = 'on';
else
    fig_visible = 'off';
end
% determine if using datetimes
use_datetime = isdatetime(time_one) || isdatetime(time_two) || isdatetime(truth_time);

%% Calculations
% find overlapping times
[time_overlap, d1_diff_ix, d2_diff_ix] = intersect(time_one, time_two); % TODO: add a tolerance?
% find differences
d1_miss_ix = setxor(1:length(time_one), d1_diff_ix);
d2_miss_ix = setxor(1:length(time_two), d2_diff_ix);
% build RMS indices
rms_ix1  = time_one >= rms_xmin & time_one <= rms_xmax;
rms_ix2  = time_two >= rms_xmin & time_two <= rms_xmax;
rms_ix3  = time_overlap >= rms_xmin & time_overlap <= rms_xmax;
rms_pts1 = max([rms_xmin min([min(time_one) min(time_two)])]);
rms_pts2 = min([rms_xmax max([max(time_one) max(time_two)])]);
% find number of elements being differenced
num_channels = length(elements);
assert(size(colororder, 1) >= 3*num_channels, ['The colororder must be at least 3 times the number of channels, ',...
    'so that you can do data_one, data_two, and their diffs.']);
% calculate the differences
nondeg_error = data_two(:,d2_diff_ix) - data_one(:,d1_diff_ix);
% calculate the rms (or mean) values
if ~use_mean
    func_name   = 'RMS';
    data1_func  = nanrms(data_one(:,rms_ix1),2);
    data2_func  = nanrms(data_two(:,rms_ix2),2);
    nondeg_func = nanrms(nondeg_error(:,rms_ix3),2);
else
    func_name   = 'Mean';
    data1_func  = nanmean(data_one(:,rms_ix1),2);
    data2_func  = nanmean(data_two(:,rms_ix2),2);
    nondeg_func = nanmean(nondeg_error(:,rms_ix3),2);
end
% output errors
err = struct('one', data1_func, 'two', data2_func, 'diff', nondeg_func);
% unit conversion value
[temp, prefix] = get_factors(leg_scale);
leg_conv = 1/temp;
% determine if you have the histories
have_data_one = any(any(~isnan(data_one)));
have_data_two = any(any(~isnan(data_two)));
% determine which symbols to plot with
if have_data_one
    if have_data_two
        symbol_one = '^-';
        symbol_two = 'v:';
    else
        symbol_one = '.-';
        symbol_two = ''; % not-used
    end
else
    if have_data_two
        symbol_one = ''; % not-used
        symbol_two = '.-';
    else
        symbol_one = ''; % invalid case
        symbol_two = ''; % invalid case
    end
end
% pre-plan plot layout
if have_data_one && have_data_two
    if make_subplots
        num_figs = 1;
        if single_lines
            num_rows = num_channels;
            num_cols = 2;
        else
            num_rows = 2;
            num_cols = 1;
        end
    else
        num_figs = 2;
        num_cols = 1;
        if single_lines
            num_rows = num_channels;
        else
            num_rows = 1;
        end
    end
else
    num_figs = 1;
    if single_lines
        num_rows = num_channels;
        num_cols = 1;
    else
        num_rows = 1;
        num_cols = 1;
    end
end
num_axes = num_figs*num_rows*num_cols;

%% Create plots
% create figures
f1 = figure('name', description, 'Visible', fig_visible);
if have_data_one && have_data_two && ~make_subplots
    f2 = figure('name', [description,' Difference'], 'Visible', fig_visible);
    fig_hand = [f1 f2];
else
    fig_hand = f1;
end
% create axes
ax = gobjects(1, num_axes);
% Note: indices is used to columnwise, as subplot is stupid and does row wise numbering
indices = reshape(1:num_rows*num_cols, num_cols, num_rows)';
for i = 1:num_figs
    for j = 1:num_cols
        for k = 1:num_rows
            temp_axes = axes(fig_hand(i)); %#ok<LAXES>
            hold(temp_axes, 'on'); % not necessary in newer Matlab
            this_pos = indices(k, j);
            subplot(num_rows, num_cols, this_pos, temp_axes);
            ax((i-1)*num_rows*num_cols + (j-1)*num_rows + k) = temp_axes;
        end
    end
end
% plot data
for i = 1:num_axes
    this_axes = ax(i);
    is_diff_plot = i > num_rows || (~single_lines && make_subplots && i == 2);
    if single_lines
        if is_diff_plot
            loop_counter = i - num_rows;
        else
            loop_counter = i;
        end
    else
        loop_counter = 1:num_channels;
    end
    if ~is_diff_plot
        % standard data plot
        if have_data_one
            for j = loop_counter
                if show_rms
                    this_name = [name_one,' ',elements{j},' (',func_name,': ',num2str(leg_conv*data1_func(j),leg_format),' ',prefix,units,')'];
                else
                    this_name = [name_one,' ',elements{j}];
                end
                plot(this_axes, time_one, data_one(j,:), symbol_one, 'MarkerSize', 4, 'Color', colororder(j,:), 'DisplayName', this_name);
            end
        end
        if have_data_two
            for j = loop_counter
                if show_rms
                    this_name = [name_two,' ',elements{j},' (',func_name,': ',num2str(leg_conv*data2_func(j),leg_format),' ',prefix,units,')'];
                else
                    this_name = [name_two,' ',elements{j}];
                end
                plot(this_axes, time_two, data_two(j,:), symbol_two, 'MarkerSize', 4, 'Color', colororder(j+num_channels,:), 'DisplayName', this_name);
            end
        end
    else
        % difference plot
        for j = loop_counter
            if show_rms
                this_name = [elements{j},' (',func_name,': ',num2str(leg_conv*nondeg_func(j),leg_format),' ',prefix,units,')'];
            else
                this_name = elements{j};
            end
            plot(this_axes, time_overlap, nondeg_error(j,:), '.-', 'MarkerSize', 4, 'Color', colororder(j+2*num_channels,:), ...
                'DisplayName', this_name);
        end
        if show_extra
            plot(this_axes, time_one(d1_miss_ix), zeros(1,length(d1_miss_ix)), 'kx', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', [name_one,' Extra']);
            plot(this_axes, time_two(d2_miss_ix), zeros(1,length(d2_miss_ix)), 'go', 'MarkerSize', 6, 'LineWidth', 2, 'DisplayName', [name_two,' Extra']);
        end
    end
    % set X display limits
    if i == 1
        xl = xlim(this_axes);
        if isfinite(disp_xmin)
            xl(1) = max([xl(1), disp_xmin]);
        end
        if isfinite(disp_xmax)
            xl(2) = min([xl(2), disp_xmax]);
        end
    end
    xlim(this_axes, xl);
    % set Y display limits
    if plot_zero
        show_zero_ylim(this_axes)
    end
    % optionally plot truth (after having set axes limits)
    if i <= num_rows && ~isempty(truth_time) && ~isempty(truth_data) && ~all(all(isnan(truth_data)))
        if single_lines
            plot(this_axes, truth_time, truth_data(i,:), '.-', 'Color', truth_color, 'MarkerFaceColor', ...
                truth_color, 'LineWidth', 2, 'DisplayName', truth_name);
        else
            if i == 1
                plot(this_axes, truth_time, truth_data, '.-', 'Color', truth_color, 'MarkerFaceColor', ...
                    truth_color, 'LineWidth', 2, 'DisplayName', truth_name);
            end
        end
    end
    % format display of plot
    legend(this_axes, 'show', 'Location', legend_loc);
    if i == 1
        title(this_axes, description, 'interpreter', 'none');
    elseif (single_lines && i == num_rows + 1) || (~single_lines && i == 2)
        title(this_axes, [description,' Difference'], 'interpreter', 'none');
    end
    if use_datetime
        xlabel(this_axes, 'Date');
    else
        xlabel(this_axes, ['Time [',time_units,']',start_date]);
    end
    ylabel(this_axes, [description,' [',units,']']);
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
        plot_rms_lines(this_axes, [rms_pts1,rms_pts2], ylim(this_axes));
    end
    hold(this_axes, 'off'); % TODO: don't due in newer Matlab?
end
% line axes to zoom together
if length(ax) > 1
    linkaxes(ax, 'x');
end