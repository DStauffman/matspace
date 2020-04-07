function [fig_hand, err] = general_quaternion_plot(description, time_one, time_two, quat_one, quat_two, varargin)

% GENERAL_QUATERNION_PLOT  is a general quaternion comparison plot for use in other wrapper functions.
%
% Summary:
%     This function plots two quaternion histories over time, along with a difference from one another.
%
% Input:
%     description     : (row) name of the data being plotted, used as title [char]
%     time_one        : (1xN) time history for channel 1 [sec]
%     time_two        : (1xN) time history for channel 2 [sec]
%     quat_one        : (4xN) data array [num]
%     quat_two        : (4xN) data array [num]
%     varargin .... : (char, value) pairs for other options, from:
%         'NameOne'      : (row) name of data source 1 [char]
%         'NameTwo'      : (row) name of data source 2 [char]
%         'TimeUnits'    : 
%         'StartDate'    : (row) date of t(0), may be an empty string [char]
%         'PlotComp'     : (scalar) true/false flag to plot components as opposed to angular difference [bool]
%         'RmsXmin'      : (scalar) time for first point of RMS calculation [sec]
%         'RmsXmax'      : (scalar) time for last point of RMS calculation [sec]
%         'DispXmin'     : (scalar) time for first point of display [sec]
%         'DispMax'      : (scalar) time for last point of display [sec]
%         'FigVisible'   : (row) setting value for whether figure is visible, from {'on','off'} [char]
%         'MakeSubplots' : (scalar) true/false flag to use subplots [bool]
%         'SingleLines'  : (scalar) true/false flag meaning to plot subplots by channel instead of together [bool]
%         'UseMean'      : (scalar) true/false flag to use mean instead of rms in calculations [bool]
%         'PlotZero'     : (scalar) true/false flag to always show zero on the vertical axis [bool]
%         'ShowRms'      : (scalar) true/false flag to show the RMS calculation in the legend [bool]
%         'LegendLoc'    : 
%         'TruthName'    :
%         'TruthTime'    :
%         'TruthData'    : 
%
% Output:
%     fig_hand        : (1xN) list of figure handles [num]
%     err             : (struct) error outputs
%         .one        : (4x1) RMS/mean of quat one [num]
%         .two        : (4x1) RMS/mean of quat two [num]
%         .diff       : (3x1) RMS/mean of X,Y,Z difference between one and two, expressed in Q1 frame [num]
%         .mag        : (scalar) RMS/mean of magnitude difference between one and two [num]
%
% Prototype:
%     description     = 'example';
%     time_one        = 0:10;
%     time_two        = 2:12;
%     quat_one        = quat_norm(rand(4,11));
%     quat_two        = quat_norm(quat_one(:, [3:11 1 2]) + 1e-5*rand(4,11));
%     name_one        = 'test1';
%     name_two        = 'test2';
%     time_units      = 'sec';
%     start_date      = ['  t(0) = ', datestr(now)];
%     rms_xmin        = 1;
%     rms_xmax        = 10;
%     disp_xmin       = -2;
%     disp_xmax       = inf;
%     fig_visible     = true;
%     make_subplots   = true;
%     single_lines    = false;
%     plot_components = true;
%     use_mean        = false;
%     plot_zero       = false;
%     show_rms        = true;
%     truth_name      = string({'Truth'});
%     truth_time      = [];
%     truth_data      = [];
%     [fig_hand, err] = general_quaternion_plot(description, time_one, time_two, quat_one, quat_two, ...
%         'NameOne', name_one, 'NameTwo', name_two, 'TimeUnits', time_units, 'StartDate', start_date, ...
%         'RmsXmin', rms_xmin, 'RmsXmax', rms_xmax, 'DispXmin', disp_xmin, 'DispXmax', disp_xmax, ...
%         'FigVisible', fig_visible, 'MakeSubplots', make_subplots, 'SingleLines', single_lines, ...
%         'PlotComp', plot_components, 'UseMean', use_mean, 'PlotZero', plot_zero, 'ShowRms', show_rms, ...
%         'TruthName', truth_name, 'TruthTime', truth_time, 'TruthData', truth_data);
%
% See Also:
%     TBD_wrapper
%
% Change Log:
%     1.  Functionalized by David C. Stauffer in October 2011.
%     2.  Incorporated by David C. Stauffer into matspace in December 2018.
%     3.  Updated by David C. Stauffer in February 2019 to allow different time histories.
%     4.  Updated by David C. Stauffer in March 2019 to use name-value pairs, and add options for
%         truth histories, second y scales, and display limits.

%% Hard-coded values
leg_format  = '%1.3f';
truth_color = [0 0 0];

%% Parser
% Validation functions
fun_is_cellstr = @(x) isstring(x) || iscell(x);
fun_is_time    = @(x) (isnumeric(x) || isdatetime(x)) && (isempty(x) || isvector(x));
fun_is_bound   = @(x) (isnumeric(x) || isdatetime(x)) && isscalar(x);
% Argument parser
p = inputParser;
addParameter(p, 'NameOne', '', @ischar);
addParameter(p, 'NameTwo', '', @ischar);
addParameter(p, 'TimeUnits', 'sec', @ischar);
addParameter(p, 'StartDate', '', @ischar);
addParameter(p, 'PlotComp', true, @islogical);
addParameter(p, 'RmsXmin', -inf, fun_is_bound);
addParameter(p, 'RmsXmax', inf, fun_is_bound);
addParameter(p, 'DispXmin', -inf, fun_is_bound);
addParameter(p, 'DispXmax', inf, fun_is_bound);
addParameter(p, 'FigVisible', true, @islogical);
addParameter(p, 'MakeSubplots', true, @islogical);
addParameter(p, 'SingleLines', false, @islogical);
addParameter(p, 'UseMean', false, @islogical);
addParameter(p, 'PlotZero', false, @islogical);
addParameter(p, 'ShowRms', true, @islogical);
addParameter(p, 'LegendLoc', 'North', @ischar);
addParameter(p, 'TruthName', string('Truth'), fun_is_cellstr);
addParameter(p, 'TruthTime', [], fun_is_time);
addParameter(p, 'TruthData', [], @isnumeric);
parse(p, varargin{:});
name_one        = p.Results.NameOne;
name_two        = p.Results.NameTwo;
time_units      = p.Results.TimeUnits;
start_date      = p.Results.StartDate;
plot_components = p.Results.PlotComp;
rms_xmin        = p.Results.RmsXmin;
rms_xmax        = p.Results.RmsXmax;
disp_xmin       = p.Results.DispXmin;
disp_xmax       = p.Results.DispXmax;
make_subplots   = p.Results.MakeSubplots;
single_lines    = p.Results.SingleLines;
use_mean        = p.Results.UseMean;
plot_zero       = p.Results.PlotZero;
show_rms        = p.Results.ShowRms;
legend_loc      = p.Results.LegendLoc;
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

%% calculations
% find overlapping times
[time_overlap, q1_diff_ix, q2_diff_ix] = intersect(time_one, time_two); % TODO: add a tolerance?
% find differences
q1_miss_ix = setxor(1:length(time_one), q1_diff_ix);
q2_miss_ix = setxor(1:length(time_two), q2_diff_ix);
% build RMS indices
rms_ix1  = time_one >= rms_xmin & time_one <= rms_xmax;
rms_ix2  = time_two >= rms_xmin & time_two <= rms_xmax;
rms_ix3  = time_overlap >= rms_xmin & time_overlap <= rms_xmax;
rms_pts1 = max([rms_xmin min([min(time_one) min(time_two)])]);
rms_pts2 = min([rms_xmax max([max(time_one) max(time_two)])]);
% calculate the differences
[nondeg_angle, nondeg_error] = quat_angle_diff(quat_one(:, q1_diff_ix), quat_two(:, q2_diff_ix));
% calculate the rms (or mean) values
if ~use_mean
    func_name   = 'RMS';
    q1_func     = nanrms(quat_one(:,rms_ix1),2);
    q2_func     = nanrms(quat_two(:,rms_ix2),2);
    nondeg_func = nanrms(nondeg_error(:, rms_ix3), 2);
    mag_func    = nanrms(nondeg_angle(:, rms_ix3), 2);
else
    func_name   = 'Mean';
    q1_func     = nanmean(quat_one(:,rms_ix1),2);
    q2_func     = nanmean(quat_two(:,rms_ix2),2);
    nondeg_func = nanmean(nondeg_error(:, rms_ix3), 2);
    mag_func    = nanmean(nondeg_angle(:, rms_ix3), 2);
end
% output errors
err = struct('one', q1_func, 'two', q2_func, 'diff', nondeg_func, 'mag', mag_func);
% get default plotting colors
color_lists = get_color_lists();
colororder3 = cell2mat(color_lists.vec_diff);
colororder8 = cell2mat(color_lists.quat_diff);
% quaternion component names
elements = {'X','Y','Z','S'};
num_channels = length(elements);
% unit conversion value
[temp, prefix] = get_factors('micro');
leg_conv = 1/temp;
% determine if you have the quaternions
have_quat_one = any(any(~isnan(quat_one)));
have_quat_two = any(any(~isnan(quat_two)));
% determine which symbols to plot with
if have_quat_one
    if have_quat_two
        symbol_one = '^-';
        symbol_two = 'v:';
    else
        symbol_one = '.-';
        symbol_two = ''; % not-used
    end
else
    if have_quat_two
        symbol_one = ''; % not-used
        symbol_two = '.-';
    else
        symbol_one = ''; % invalid case
        symbol_two = ''; % invalid case
    end
end
% pre-plan plot layout
if have_quat_one && have_quat_two
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
if make_subplots
    f1 = figure('name', description, 'Visible', fig_visible);
else
    f1 = figure('name', [description,' Quaternion Components'], 'Visible', fig_visible);
end
if have_quat_one && have_quat_two && ~make_subplots
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
        if have_quat_one
            for j = loop_counter
                if show_rms
                    this_name = [name_one,' ',elements{j},' (',func_name,': ',num2str(q1_func(j),leg_format),')'];
                else
                    this_name = [name_one,' ',elements{j}];
                end
                plot(this_axes, time_one, quat_one(j,:), symbol_one, 'MarkerSize', 4, 'Color', colororder8(j+num_channels-num_channels*have_quat_two,:), 'DisplayName', this_name);
            end
        end
        if have_quat_two
            for j = loop_counter
                if show_rms
                    this_name = [name_two,' ',elements{j},' (',func_name,': ',num2str(q2_func(j),leg_format),')'];
                else
                    this_name = [name_two,' ',elements{j}];
                end
                plot(this_axes, time_two, quat_two(j,:), symbol_two, 'MarkerSize', 4, 'Color', colororder8(j+num_channels,:), 'DisplayName', this_name);
            end
        end
    else
        % difference plot
        if plot_components
            for j = [3 1 2] % TODO: want to only do these loops, and reorder afterwards
                if show_rms
                    this_name = [elements{j},' (',func_name,': ',num2str(leg_conv*nondeg_func(j),leg_format),' ',prefix,'rad)'];
                else
                    this_name = elements{j};
                end
                plot(this_axes, time_overlap, nondeg_error(j,:), '.-', 'MarkerSize', 4, 'Color', colororder3(j,:), 'DisplayName', this_name);
            end
        else
            % TODO: make this the fourth plot when plotting single lines
            if show_rms
                this_name = ['Angle (',func_name,': ',num2str(leg_conv*mag_func,leg_format),' ',prefix,'rad)'];
            else
                this_name = 'Angle';
            end
            plot(this_axes, time_overlap, nondeg_angle, '.-', 'MarkerSize', 4, 'Color', colororder3(1,:), 'DisplayName', this_name);
        end
        plot(this_axes, time_one(q1_miss_ix), zeros(1,length(q1_miss_ix)), 'kx', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', [name_one,' Extra']);
        plot(this_axes, time_two(q2_miss_ix), zeros(1,length(q2_miss_ix)), 'go', 'MarkerSize', 6, 'LineWidth', 2, 'DisplayName', [name_two,' Extra']);     
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
                truth_color, 'LineWidth', 2, 'DisplayName', [truth_name,' ',elements{i}]);
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
        title(this_axes, [description,' Quaternion Components'], 'interpreter', 'none');
    elseif (single_lines && i == num_rows + 1) || (~single_lines && i == 2)
        title(this_axes, [description,' Difference'], 'interpreter', 'none');
    end
    if use_datetime
        xlabel(this_axes, 'Date');
    else
        xlabel(this_axes, ['Time [',time_units,']',start_date]);
    end
    if is_diff_plot
        ylabel(this_axes, [description,' Difference [rad]']);
    else
        ylabel(this_axes, [description,' Quaternion Components [dimensionless]']);
    end
    grid(this_axes, 'on');
    % plot RMS lines
    if show_rms
        plot_rms_lines(this_axes, [rms_pts1,rms_pts2],ylim);
    end
    hold(this_axes, 'off');
end
% line axes to zoom together
if length(ax) > 1
    linkaxes(ax, 'x');
end