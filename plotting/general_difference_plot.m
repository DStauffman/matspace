function [fig_hand,err] = general_difference_plot(description, time_one, time_two, data_one, data_two, ...
    name_one, name_two, elements, units, leg_scale, start_date, rms_xmin, rms_xmax, fig_visible, ...
    make_subplots, colororder)

% GENERAL_DIFFERENCE_PLOT  is a general difference comparsion plot for use in plot_los.
%
% Summary:
%     This function plots two histories over time, along with a difference from one another.
%
% Input:
%     description     : (row) name of the data being plotted [char]
%     time_one        : (1xN) time history for channel 1 [sec]
%     time_two        : (1xN) time history for channel 2 [sec]
%     data_one        : (MxN) data array [any]
%     data_two        : (MxN) data array [any]
%     name_one        : (row) name of data source 1 [char]
%     name_two        : (row) name of data source 2 [char]
%     elements        : {1xN} of (row) of names of M data elements
%     units           : (row) name of units for plots [char]
%     leg_scale       : (row) prefix for get_factors to use to scale RMS in legend [char]
%     start_date      : (row) date of t(0), may be an empty string [char]
%     rms_xmin        : (scalar) time for first point of RMS calculation [sec]
%     rms_xmax        : (scalar) time for last point of RMS calculation [sec]
%     fig_visible     : (row) setting value for whether figure is visible, from {'on','off'} [char]
%     make_subplots   : (scalar) true/false flag to use subplots [bool]
%     colororder      : (3xN) color RGB triples for each channel of data [ndim]
%
% Output:
%     fig_hand        : (1xN) list of figure handles [num]
%     err             : (Mx1) error outputs [num]
%
% Prototype:
%     description     = 'example';
%     time_one        = 0:10;
%     time_two        = 2:12;
%     data_one        = rand(2,11)*1e-6;
%     data_two        = data_one(:,[3:11 1 2]) - 1e-6;
%     name_one        = 'test1';
%     name_two        = 'test2';
%     elements        = {'x','y'};
%     units           = 'rad';
%     leg_scale       = 'micro';
%     start_date      = datestr(now);
%     rms_xmin        = 1;
%     rms_xmax        = 10;
%     fig_visible     = 'on';
%     make_subplots   = true;
%     colororder      = [0.89453125 0 0; 0.01171875 0.26171875 0.87109375; 0.92578125 0.05078125 0.84765625;...
%         0 0.99609375 0.99609375];
%     [fig_hand,err]  = general_difference_plot(description, time_one, time_two, data_one, data_two, ...
%         name_one, name_two, elements, units, leg_scale, start_date, rms_xmin, rms_xmax, fig_visible, make_subplots)
%
% See Also:
%     TBD_wrapper
%
% Change Log:
%     1.  Functionalized by David C. Stauffer in October 2011.
%     2.  Incorporated by David C. Stauffer into DStauffman tools in February 2019.
%     3.  Updated by David C. Stauffer in February 2019 to allow different time histories.

%% Calculations
precision = 0;
[time_overlap, d1_diff_ix, d2_diff_ix] = intersect2(time_one, time_two, precision);
rms_ix1  = time_one >= rms_xmin & time_one <= rms_xmax;
rms_ix2  = time_two >= rms_xmin & time_two <= rms_xmax;
rms_ix3  = time_overlap >= rms_xmin & time_overlap <= rms_xmax;
rms_pts1 = max([rms_xmin min([min(time_one) min(time_two)])]);
rms_pts2 = min([rms_xmax max([max(time_one) max(time_two)])]);
% find number of elements being differenced
n = length(elements);
% calculate the rms values
data1_rms = nanrms(data_one(:,rms_ix1),2);
data2_rms = nanrms(data_two(:,rms_ix2),2);
nondeg_error = data_two(:,d2_diff_ix) - data_one(:,d1_diff_ix);
nondeg_rms   = nanrms(nondeg_error(:,rms_ix3),2);
% output errors
err = [data1_rms; data2_rms; nondeg_rms];
% unit conversion value
[temp, prefix] = get_factors(leg_scale);
leg_conv = 1/temp;
% determine if you have the histories
have_data_one = any(any(~isnan(data_one)));
have_data_two = any(any(~isnan(data_two)));

%% Overlay plots
f1 = figure('Visible',fig_visible);
% create axis
if make_subplots
    set(f1,'name',description);
    if have_data_one && have_data_two
        ax1 = subplot(2,1,1);
    else
        ax1 = axes;
    end
else
    set(f1,'name',[description,' Vector Components']);
    ax1 = axes;
end
% plot data
hold on;
if have_data_one
    for i = 1:n
        plot(ax1,time_one,data_one(i,:),'^-','MarkerSize',4,'Color',colororder(i,:),...
            'DisplayName',[name_one,' ',elements{i},' (RMS: ',num2str(leg_conv*data1_rms(i),'%1.3f'),' ',prefix,units,')']);
    end
end
if have_data_two
    for i = 1:n
        plot(ax1,time_two,data_two(i,:),'v:','MarkerSize',4,'Color',colororder(i+n,:),...
            'DisplayName',[name_two,' ',elements{i},' (RMS: ',num2str(leg_conv*data2_rms(i),'%1.3f'),' ',prefix,units,')']);
    end
end
% format display of plot
legend('show','Location','North');
plot_rms_lines([rms_pts1,rms_pts2],ylim);
title([description,' Vector Components'],'interpreter','none');
xlabel(['Time [sec]',start_date]);
ylabel([description,' Vector Components [rad]']);
grid on;
hold off;

%% Difference plot
if have_data_one && have_data_two
    % make axis
    if make_subplots
        set(f1,'DefaultAxesColorOrder',colororder);
        ax2 = subplot(2,1,2);
        f2 = [];
    else
        f2  = figure('name',[description,'Difference'],'DefaultAxesColorOrder',colororder,'Visible',fig_visible);
        ax2 = axes;
    end
    % plot data
    hold on;
    for i = 1:n
        plot(ax2,time_overlap,nondeg_error(i,:),'^-','MarkerSize',4,'Color',colororder(i+2*n,:),...
            'DisplayName',[elements{i},' (RMS: ',num2str(leg_conv*nondeg_rms(i),'%1.3f'),' ',prefix,units,')']);
    end
    legend('show','Location','North');
    % format display of plot
    plot_rms_lines([rms_pts1,rms_pts2],ylim);
    title([description,' Difference'],'interpreter','none');
    xlabel(['Time [sec]',start_date]);
    ylabel([description,' Difference [rad]']);
    grid on;
    hold off;
    % line axes to zoom together
    linkaxes([ax1 ax2],'x');
else
    f2 = [];
end
fig_hand = [f1 f2];