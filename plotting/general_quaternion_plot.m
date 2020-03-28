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
%         'PlotComp'     : (scalar) true/false flag to plot components as opposed to angular difference [bool]
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
%     quat_two        = quat_norm(rand(4,11));
%     name_one        = 'test1';
%     name_two        = 'test2';
%     start_date      = datestr(now);
%     rms_xmin        = 1;
%     rms_xmax        = 10;
%     disp_xmin       = -2;
%     disp_xmax       = inf;
%     fig_visible     = true;
%     make_subplots   = true;
%     plot_components = true;
%     use_mean        = false;
%     plot_zero       = false;
%     show_rms        = true;
%     [fig_hand, err] = general_quaternion_plot(description, time_one, time_two, quat_one, quat_two, ...
%         'NameOne', name_one, 'NameTwo', name_two, 'StartDate', start_date, 'PlotComp', plot_components, ...
%         'RmsXmin', rms_xmin, 'RmsXmax', rms_xmax, 'DispXmin', disp_xmin, 'DispXmax', disp_xmax, ...
%         'FigVisible', fig_visible, 'MakeSubplots', make_subplots, 'UseMean', use_mean, ...
%         'PlotZero', plot_zero, 'ShowRms', show_rms);
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
is_cellstr = @(x) isstring(x) || iscell(x);
% Argument parser
p = inputParser;
addParameter(p, 'NameOne','', @ischar);
addParameter(p, 'NameTwo','', @ischar);
addParameter(p, 'TimeUnits', 'sec', @ischar);
addParameter(p, 'StartDate','', @ischar);
addParameter(p, 'PlotComp', true, @islogical);
addParameter(p, 'RmsXmin',-inf, @isnumeric);
addParameter(p, 'RmsXmax',inf, @isnumeric);
addParameter(p, 'DispXmin',-inf, @isnumeric);
addParameter(p, 'DispXmax',inf, @isnumeric);
addParameter(p, 'FigVisible',true, @islogical);
addParameter(p, 'MakeSubplots',true, @islogical);
addParameter(p, 'UseMean',false, @islogical);
addParameter(p, 'PlotZero',false, @islogical);
addParameter(p, 'ShowRms',true, @islogical);
addParameter(p, 'LegendLoc','North', @ischar);
addParameter(p, 'TruthName', "Truth", is_cellstr);
addParameter(p, 'TruthTime', [], @isnumeric);
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

%% calculations
[time_overlap, q1_diff_ix, q2_diff_ix] = intersect(time_one, time_two); % TODO: add a tolerance?
rms_ix1  = time_one >= rms_xmin & time_one <= rms_xmax;
rms_ix2  = time_two >= rms_xmin & time_two <= rms_xmax;
rms_ix3  = time_overlap >= rms_xmin & time_overlap <= rms_xmax;
rms_pts1 = max([rms_xmin min([min(time_one) min(time_two)])]);
rms_pts2 = min([rms_xmax max([max(time_one) max(time_two)])]);
% calculate the difference
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
% unit conversion value
[leg_scale, prefix] = get_factors('micro');

% determine if you have the quaternions
have_quat_one = any(any(~isnan(quat_one)));
have_quat_two = any(any(~isnan(quat_two)));

%% Overlay plots
f1 = figure('Visible',fig_visible);
% create axis
if make_subplots
    set(f1,'name',description);
    if have_quat_one && have_quat_two
        ax1 = subplot(2,1,1);
    else
        ax1 = axes;
    end
else
    set(f1,'name',[description,' Quaternion Components']);
    ax1 = axes;
end
% plot data
hold on;
if have_quat_one
    if have_data_two
        symbol = '^-';
    else
        symbol = '.-';
    end
    for i = 1:4
        if show_rms
            this_name = [name_one,' ',elements{i},' (',func_name,': ',num2str(q1_func(i),'%1.3f'),')'];
        else
            this_name = [name_one,' ',elements{i}];
        end
        plot(ax1,time_one,quat_one(i,:),symbol,'MarkerSize',4,'Color',colororder8(i+4-4*have_quat_two,:),...
            'DisplayName',this_name);
    end
end
if have_quat_two
    if have_data_one
        symbol = 'v:';
    else
        symbol = '.-';
    end
    for i = 1:4
        if show_rms
            this_name = [name_two,' ',elements{i},' (',func_name,': ',num2str(q2_func(i),'%1.3f'),')'];
        else
            this_name = [name_two,' ',elements{i}];
        end
        plot(ax1,time_two,quat_two(i,:),symbol,'MarkerSize',4,'Color',colororder8(i+4,:),...
            'DisplayName',this_name);
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
    for i = 1:4
        % TODO: add RMS to Truth data?
        plot(ax1, truth_time, truth_data(i,:), '.-', 'Color', truth_color, 'MarkerFaceColor', ...
            truth_color, 'LineWidth', 2, 'DisplayName', [truth_name,' ',elements{i}]);
    end
end
% format display of plot
legend('show','Location','North');
title([description,' Quaternion Components'],'interpreter','none');
xlabel(['Time [',time_units,']',start_date]);
ylabel([description,' Quaternion Components [dimensionless]']);
grid on;
% plot RMS lines
if show_rms
    plot_rms_lines([rms_pts1,rms_pts2],ylim);
end
hold off;

%% Difference plot
if have_quat_one && have_quat_two
    % make axis
    if make_subplots
        f2  = [];
        ax2 = subplot(2,1,2);
    else
        f2  = figure('name',[description,' Difference'],'Visible',fig_visible);
        ax2 = axes;
    end
    % plot data
    if plot_components
        hold on;
        for i = [3 1 2]
            if show_rms
                this_name = [elements{i},' (',func_name,': ',num2str(1/leg_scale*nondeg_func(i),'%1.3f'),' ',prefix,'rad)'];
            else
                this_name = elements{i};
            end
            plot(ax2,time_overlap,nondeg_error(i,:),'^-','MarkerSize',4,'Color',colororder3(i,:),...
                'DisplayName',this_name);
        end
    else
        if show_rms
            this_name = ['Angle (',func_name,': ',num2str(1/leg_scale*mag_func,'%1.3f'),' ',prefix,'rad)'];
        else
            this_name = 'Angle';
        end
        plot(ax2,time_overlap,nondeg_angle,'^-','MarkerSize',4,'Color',colororder3(1,:),...
            'DisplayName',this_name);
    end
    % format display of plot
    if plot_zero
        show_zero_ylim(ax2)
    end
    legend('show','Location','North');
    title([description,' Difference'],'interpreter','none');
    xlabel(['Time [',time_units,']',start_date]);
    ylabel([description,' Difference [rad]']);
    grid on;
    if show_rms
        plot_rms_lines([rms_pts1,rms_pts2],ylim);
    end
    hold off;
    % link axes to zoom together (TODO: check that this uses old xmin limits)
    linkaxes([ax1 ax2],'x');
else
    f2 = [];
end
fig_hand = [f1 f2];