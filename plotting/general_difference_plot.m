function [fig_hand,err] = general_difference_plot(description, time_one, time_two, data_one, data_two, ...
    name_one, name_two, elements, units, leg_scale, start_date, rms_xmin, rms_xmax, fig_visible, ...
    make_subplots, colororder, use_mean, plot_zero, show_rms)

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
%     name_one      : (row) name of data source 1 [char]
%     name_two      : (row) name of data source 2 [char]
%     elements      : {1xN} of (row) of names of M data elements
%     units         : (row) name of units for plots [char]
%     leg_scale     : (row) prefix for get_factors to use to scale RMS in legend [char]
%     start_date    : (row) date of t(0), may be an empty string [char]
%     rms_xmin      : (scalar) time for first point of RMS calculation [sec]
%     rms_xmax      : (scalar) time for last point of RMS calculation [sec]
%     fig_visible   : (row) setting value for whether figure is visible, from {'on','off'} [char]
%     make_subplots : (scalar) true/false flag to use subplots [bool]
%     colororder    : (3xN) color RGB triples for each channel of data [ndim]
%     use_mean      : (scalar) true/false flag to use mean instead of rms in calculations [bool]
%     plot_zero     : (scalar) true/false flag to always show zero on the vertical axis [bool]
%     show_rms      : (scalar) true/false flag to show the RMS calculation in the legend [bool]
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
%     start_date    = datestr(now);
%     rms_xmin      = 1;
%     rms_xmax      = 10;
%     fig_visible   = 'on';
%     make_subplots = true;
%     color_lists   = get_color_lists();
%     colororder    = [cell2mat(color_lists.dbl_diff); cell2mat(color_lists.two)];
%     use_mean      = false;
%     plot_zero     = false;
%     show_rms      = true;
%     [fig_hand, err] = general_difference_plot(description, time_one, time_two, data_one, data_two, ...
%         name_one, name_two, elements, units, leg_scale, start_date, rms_xmin, rms_xmax, fig_visible, ...
%         make_subplots, colororder, use_mean, plot_zero, show_rms);
%
% See Also:
%     TBD_wrapper
%
% Change Log:
%     1.  Functionalized by David C. Stauffer in October 2011.
%     2.  Incorporated by David C. Stauffer into DStauffman tools in February 2019.
%     3.  Updated by David C. Stauffer in February 2019 to allow different time histories.

%% Parser
% TODO: make most of the inputs optional, set defaults and use a parser.

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
    for i = 1:n
        if show_rms
            this_name = [name_one,' ',elements{i},' (',func_name,': ',num2str(leg_conv*data1_func(i),'%1.3f'),' ',prefix,units,')'];
        else
            this_name = [name_one,' ',elements{i}];
        end
        plot(ax1,time_one,data_one(i,:),'^-','MarkerSize',4,'Color',colororder(i,:),'DisplayName',this_name);
    end
end
if have_data_two
    for i = 1:n
        if show_rms
            this_name = [name_two,' ',elements{i},' (',func_name,': ',num2str(leg_conv*data2_func(i),'%1.3f'),' ',prefix,units,')'];
        else
            this_name = [name_two,' ',elements{i}];
        end
        plot(ax1,time_two,data_two(i,:),'v:','MarkerSize',4,'Color',colororder(i+n,:),'DisplayName',this_name);
    end
end
% format display of plot
if plot_zero
    show_zero_ylim(ax1)
end
legend('show','Location','North');
plot_rms_lines([rms_pts1,rms_pts2],ylim);
title(description,'interpreter','none');
xlabel(['Time [sec]',start_date]);
ylabel([description,' [',units,']']);
grid on;
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
            this_name = [elements{i},' (',func_name,': ',num2str(leg_conv*nondeg_func(i),'%1.3f'),' ',prefix,units,')'];
        else
            this_name = elements{i};
        end
        plot(ax2,time_overlap,nondeg_error(i,:),'^-','MarkerSize',4,'Color',colororder(i+2*n,:),...
            'DisplayName',this_name);
    end
    plot(ax2,time_one(d1_miss_ix),zeros(1,length(d1_miss_ix)),'kx','MarkerSize',8,'LineWidth',2,...
        'DisplayName',[name_one,' Extra']);
    plot(ax2,time_two(d2_miss_ix),zeros(1,length(d2_miss_ix)),'go','MarkerSize',6,'LineWidth',2,...
        'DisplayName',[name_two,' Extra']);
    legend('show','Location','North');
    % format display of plot
    if plot_zero
        show_zero_ylim(ax2)
    end
    plot_rms_lines([rms_pts1,rms_pts2],ylim);
    title([description,' Difference'],'interpreter','none');
    xlabel(['Time [sec]',start_date]);
    ylabel([description,' Difference [',units,']']);
    grid on;
    hold off;
    % line axes to zoom together
    linkaxes([ax1 ax2],'x');
else
    f2 = [];
end
fig_hand = [f1 f2];