function [fig_hand, err] = general_quaternion_plot(description, time, quat_one, quat_two, name_one, name_two, ...
    start_date, ix_rms_xmin, ix_rms_xmax, fig_visible, make_subplots, plot_components)

% GENERAL_QUATERNION_PLOT  is a general quaternion comparison plot for use in other wrapper functions.
%
% Summary:
%     This function plots two quaternion histories over time, along with a difference from one another.
%
% Input:
%     description     : (row) name of the data being plotted, used as title [char]
%     time            : (1xN) time history [sec]
%     quat_one        : (4xN) data array [num]
%     quat_two        : (4xN) data array [num]
%     name_one        : (row) name of data source 1 [char]
%     name_two        : (row) name of data source 2 [char]
%     start_date      : (row) date of t(0), may be an empty string [char]
%     ix_rms_xmin     : (scalar) index to first point of RMS calculation [num]
%     ix_rms_xmax     : (scalar) index to last point of RMS calculation [num]
%     fig_visible     : (row) setting value for whether figure is visible, from {'on','off'} [char]
%     make_subplots   : (scalar) true/false flag to use subplots [bool]
%     plot_components : (scalar) true/false flag to plot components as opposed to angular difference [bool]
%
% Output:
%     fig_hand        : (1xN) list of figure handles [num]
%     err             : (3x1) Quaternion differences expressed in Q1 frame [num]
%
% Prototype:
%     description     = 'example';
%     time            = 0:10;
%     quat_one        = quat_norm(rand(4,11));
%     quat_two        = quat_norm(rand(4,11));
%     name_one        = 'test1';
%     name_two        = 'test2';
%     start_date      = datestr(now);
%     ix_rms_xmin     = 1;
%     ix_rms_xmax     = 10;
%     fig_visible     = 'on';
%     make_subplots   = true;
%     plot_components = true;
%     [fig_hand, err] = general_quaternion_plot(...
%         description, ...
%         time, ...
%         quat_one, ...
%         quat_two, ...
%         name_one, ...
%         name_two, ...
%         start_date, ...
%         ix_rms_xmin, ...
%         ix_rms_xmax, ...
%         fig_visible, ...
%         make_subplots, ...
%         plot_components);
%
% See Also:
%     TBD_wrapper
%
% Change Log:
%     1.  Functionalized by David C. Stauffer in October 2011.
%     2.  Incorporated by David C. Stauffer into DStauffman tools in December 2018.

%% calculations
q1_rms = nanrms(quat_one(:,ix_rms_xmin:ix_rms_xmax),2);
q2_rms = nanrms(quat_two(:,ix_rms_xmin:ix_rms_xmax),2);
[nondeg_angle, nondeg_error] = quat_angle_diff(quat_one, quat_two);
nondeg_rms = nanrms(nondeg_error(:, ix_rms_xmin:ix_rms_xmax), 2);
% output errors
if plot_components
    err = nondeg_rms;
else
    err = [nondeg_rms; nan(2, 1)];
end
% get default plotting colors
color_lists = get_color_lists();
colororder3 = cell2mat(color_lists.vec_diff);
colororder8 = cell2mat(color_lists.quat_diff);
% quaternion component names
names = {'X','Y','Z','S'};
% names = {'qx','qy','qz','qs'};
% TODO: make non-harded coded
% unit conversion value
rad2urad = 1e6;
% determine if you have the quaternions
have_quat_one = any(any(~isnan(quat_one)));
have_quat_two = any(any(~isnan(quat_one)));

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
    for i = 1:4
        plot(ax1,time,quat_one(i,:),'^-','MarkerSize',4,'Color',colororder8(i+4-4*have_quat_two,:),...
            'DisplayName',[name_one,' ',names{i},' (RMS: ',num2str(q1_rms(i),'%1.3f'),')']);
    end
end
if have_quat_two
    for i = 1:4
        plot(ax1,time,quat_two(i,:),'v:','MarkerSize',4,'Color',colororder8(i+4,:),...
            'DisplayName',[name_two,' ',names{i},' (RMS: ',num2str(q2_rms(i),'%1.3f'),')']);
    end
end
% format display of plot
legend('show','Location','North');
plot_rms_lines(time([ix_rms_xmin,ix_rms_xmax]),ylim);
title([description,' Quaternion Components'],'interpreter','none');
xlabel(['Time [sec]',start_date]);
ylabel([description,' Quaternion Components [dimensionless]']);
grid on;
hold off;

%% Difference plot
if have_quat_one && have_quat_two
    % make axis
    if make_subplots
        set(f1,'DefaultAxesColorOrder',colororder3);
        ax2 = subplot(2,1,2);
        f2 = [];
    else
        f2  = figure('name',[description,' Difference'],'DefaultAxesColorOrder',colororder3,'Visible',fig_visible);
        ax2 = axes;
    end
    % plot data
    if plot_components
        plot(ax2,time,nondeg_error,'^-','MarkerSize',4);
        legend(...
            ['X (RMS: ',num2str(rad2urad*nondeg_rms(1),'%1.3f'),' \murad)'],...
            ['Y (RMS: ',num2str(rad2urad*nondeg_rms(2),'%1.3f'),' \murad)'],...
            ['Z (RMS: ',num2str(rad2urad*nondeg_rms(3),'%1.3f'),' \murad)'],...
            'Location','North');
        %set z-axis data to be plotted underneath everything else
        h = get(ax2,'Children');
        uistack(h(1),'bottom');
    else
        plot(ax2,time,nondeg_angle,'^-','MarkerSize',4);
        legend(['Angle (RMS: ',num2str(rad2urad*nondeg_rms(1),'%1.3f'),' \murad)'],'Location','North');
    end
    % format display of plot
    plot_rms_lines(time([ix_rms_xmin,ix_rms_xmax]),ylim);
    title([description,' Difference'],'interpreter','none');
    xlabel(['Time [sec]',start_date]);
    ylabel([description,' Difference [rad]']);
    grid on;
    hold off;
    % link axes to zoom together
    linkaxes([ax1 ax2],'x');
else
    f2 = [];
end
fig_hand = [f1 f2];