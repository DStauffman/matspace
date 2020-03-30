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
%         'LegScale'     : (row) prefix for get_factors to use to scale RMS in legend [char]
%         'StartDate'    : (row) date of t(0), may be an empty string [char]
%         'RmsXmin'      : (scalar) time for first point of RMS calculation [sec]
%         'RmsXmax'      : (scalar) time for last point of RMS calculation [sec]
%         'DispXmin'     : (scalar) time for first point of display [sec]
%         'DispMax'      : (scalar) time for last point of display [sec]
%         'FigVisible'   : (row) setting value for whether figure is visible, from {'on','off'} [char]
%         'MakeSubplots' : (scalar) true/false flag to use subplots [bool]
%         'ColorOrder'   : (3xN) color RGB triples for each channel of data [ndim]
%         'UseMean'      : (scalar) true/false flag to use mean instead of rms in calculations [bool]
%         'PlotZero'     : (scalar) true/false flag to always show zero on the vertical axis [bool]
%         'ShowRms'      : (scalar) true/false flag to show the RMS calculation in the legend [bool]
%
% Output:
%     fig_hand      : (scalar or 1x2) list of figure handles [num]
%     err           : (struct) error outputs
%         .one      : (Mx1) RMS/mean of data one [num]
%         .two      : (Mx1) RMS/mean of data two [num]
%         .diff     : (Mx1) RMS/mean of difference between one and two [num]
%
% Prototype:
%     description   = 'example';
%     time_one      = 0:10;
%     time_two      = 2:12;
%     data_one      = rand(2,11)*1e-6;
%     data_two      = data_one(:,[3:11 1 2]) - 1e-6;
%     name_one      = 'test1';
%     name_two      = 'test2';
%     elements      = {'x','y'};
%     units         = 'rad';
%     leg_scale     = 'micro';
%     start_date    = ['t(0) = ', datestr(now)];
%     rms_xmin      = 1;
%     rms_xmax      = 10;
%     disp_xmin     = -2;
%     disp_xmax     = inf;
%     fig_visible   = true;
%     make_subplots = true;
%     color_lists   = get_color_lists();
%     colororder    = [cell2mat(color_lists.dbl_diff); cell2mat(color_lists.two)];
%     use_mean      = false;
%     plot_zero     = false;
%     show_rms      = true;
%     [fig_hand, err] = general_difference_plot(description, time_one, time_two, data_one, data_two, ...
%         'NameOne', name_one, 'NameTwo', name_two, 'Elements', elements, 'Units', units, ...
%         'LegendScale', leg_scale, 'StartDate', start_date, 'RmsXmin', rms_xmin, 'RmsXmax', rms_xmax, ...
%         'FigVisible', fig_visible, 'MakeSubplots', make_subplots, 'ColorOrder', colororder, ...
%         'UseMean', use_mean, 'PlotZero', plot_zero, 'ShowRms', show_rms, 'DispXmin', disp_xmin, ...
%         'DispXmax', disp_xmax);
%
% See Also:
%     plot_time_history
%
% Change Log:
%     1.  Functionalized by David C. Stauffer in October 2011.
%     2.  Incorporated by David C. Stauffer into matspace in February 2019.
%     3.  Updated by David C. Stauffer in February 2019 to allow different time histories.
%     4.  Updated by David C. Stauffer in March 2019 to use name-value pairs, and add options for
%         truth histories, second y scales, and display limits.

%% Hard-coded values
leg_format  = '%1.3f';
truth_color = [0 0 0];

%% Parser
% Validation functions
fun_is_num_or_cell = @(x) isnumeric(x) || iscell(x);
fun_is_cellstr = @(x) isstring(x) || iscell(x);
fun_is_time    = @(x) (isnumeric(x) || isdatetime(x)) && (isempty(x) || isvector(x));
fun_is_bound   = @(x) (isnumeric(x) || isdatetime(x)) && isscalar(x);
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
addParameter(p, 'ColorOrder', '', @isnumeric);
addParameter(p, 'UseMean', false, @islogical);
addParameter(p, 'PlotZero', false, @islogical);
addParameter(p, 'ShowRms', true, @islogical);
addParameter(p, 'SecondYScale', nan, fun_is_num_or_cell);
addParameter(p, 'TruthName', string('Truth'), fun_is_cellstr);
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
colororder      = p.Results.ColorOrder;
use_mean        = p.Results.UseMean;
plot_zero       = p.Results.PlotZero;
show_rms        = p.Results.ShowRms;
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
% build RMS indexes
rms_ix1  = time_one >= rms_xmin & time_one <= rms_xmax;
rms_ix2  = time_two >= rms_xmin & time_two <= rms_xmax;
rms_ix3  = time_overlap >= rms_xmin & time_overlap <= rms_xmax;
rms_pts1 = max([rms_xmin min([min(time_one) min(time_two)])]);
rms_pts2 = min([rms_xmax max([max(time_one) max(time_two)])]);
% find number of elements being differenced
n = length(elements);
assert(size(colororder, 1) >= 3*n, ['The colororder must be at least 3 times the number of channels, ',...
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

%% Overlay plots
f1 = figure('Visible',fig_visible);
set(f1,'name',description);
% create axis
if make_subplots
    if have_data_one && have_data_two
        ax1 = subplot(2,1,1);
    else
        ax1 = axes;
    end
else
    ax1 = axes;
end
% plot data
hold on;
if have_data_one
    if have_data_two
        symbol = '^-';
    else
        symbol = '.-';
    end
    for i = 1:n
        if show_rms
            this_name = [name_one,' ',elements{i},' (',func_name,': ',num2str(leg_conv*data1_func(i),leg_format),' ',prefix,units,')'];
        else
            this_name = [name_one,' ',elements{i}];
        end
        plot(ax1,time_one,data_one(i,:),symbol,'MarkerSize',4,'Color',colororder(i,:),'DisplayName',this_name);
    end
end
if have_data_two
    if have_data_one
        symbol = 'v:';
    else
        symbol = '.-';
    end
    for i = 1:n
        if show_rms
            this_name = [name_two,' ',elements{i},' (',func_name,': ',num2str(leg_conv*data2_func(i),leg_format),' ',prefix,units,')'];
        else
            this_name = [name_two,' ',elements{i}];
        end
        plot(ax1,time_two,data_two(i,:),symbol,'MarkerSize',4,'Color',colororder(i+n,:),'DisplayName',this_name);
    end
end
% set X display limits
xl = xlim;
if isfinite(disp_xmin)
    xl(1) = max([xl(1), disp_xmin]);
end
if isfinite(disp_xmax)
    xl(2) = min([xl(2), disp_xmax]);
end
xlim(xl);
% set Y display limits
if plot_zero
    show_zero_ylim(ax1)
end
% optionally plot truth
if ~isempty(truth_time) && ~isempty(truth_data) && ~all(all(isnan(truth_data)))
    plot(ax1, truth_time, truth_data, '.-', 'Color', truth_color, 'MarkerFaceColor', ...
        truth_color, 'LineWidth', 2, 'DisplayName', truth_name);
end
% format display of plot
legend('show', 'Location', 'North');
title(description, 'interpreter', 'none');
if use_datetime
    xlabel('Date');
else
    xlabel(['Time [',time_units,']',start_date]);
end
ylabel([description,' [',units,']']);
grid on;
% create second Y axis
if iscell(second_y_scale)
    plot_second_yunits(ax1, second_y_scale{1}, second_y_scale{2});
elseif ~isnan(second_y_scale) && second_y_scale ~= 0
    new_y_label = ''; % TODO: keep this option or always make a cell?
    plot_second_yunits(ax1, new_y_label, second_y_scale);
end
% plot RMS lines
if show_rms
    plot_rms_lines([rms_pts1,rms_pts2], ylim);
end
hold off;

%% Difference plot
if have_data_one && have_data_two
    % make axis
    if make_subplots
        f2  = [];
        ax2 = subplot(2,1,2);
    else
        f2  = figure('name',[description,'Difference'],'Visible',fig_visible);
        ax2 = axes;
    end
    % plot data
    hold on;
    for i = 1:n
        if show_rms
            this_name = [elements{i},' (',func_name,': ',num2str(leg_conv*nondeg_func(i),leg_format),' ',prefix,units,')'];
        else
            this_name = elements{i};
        end
        plot(ax2,time_overlap,nondeg_error(i,:),'.-','MarkerSize',4,'Color',colororder(i+2*n,:),...
            'DisplayName',this_name);
    end
    plot(ax2,time_one(d1_miss_ix),zeros(1,length(d1_miss_ix)),'kx','MarkerSize',8,'LineWidth',2,...
        'DisplayName',[name_one,' Extra']);
    plot(ax2,time_two(d2_miss_ix),zeros(1,length(d2_miss_ix)),'go','MarkerSize',6,'LineWidth',2,...
        'DisplayName',[name_two,' Extra']);
    % format display of plot
    if plot_zero
        show_zero_ylim(ax2)
    end
    legend('show','Location','North');
    title([description,' Difference'],'interpreter','none');
    if use_datetime
        xlabel('Date');
    else
        xlabel(['Time [',time_units,']',start_date]);
    end
    ylabel([description,' Difference [',units,']']);
    grid on;
    % create second Y axis
    if iscell(second_y_scale)
        plot_second_yunits(ax2, second_y_scale{1}, second_y_scale{2});
    elseif ~isnan(second_y_scale) && second_y_scale ~= 0
        new_y_label = ''; % TODO: keep this option or always make a cell?
        plot_second_yunits(ax2, new_y_label, second_y_scale);
    end
    if show_rms
        plot_rms_lines([rms_pts1,rms_pts2],ylim);
    end
    hold off;
    % line axes to zoom together (TODO: check that this uses old xmin limits)
    linkaxes([ax1 ax2],'x');
else
    f2 = [];
end
fig_hand = [f1 f2];