function [fig_hand, err] = general_quaternion_plot(description, time_one, time_two, quat_one, quat_two, ...
    name_one, name_two, start_date, rms_xmin, rms_xmax, fig_visible, make_subplots, plot_components)

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
%     name_one        : (row) name of data source 1 [char]
%     name_two        : (row) name of data source 2 [char]
%     start_date      : (row) date of t(0), may be an empty string [char]
%     rms_xmin        : (scalar) time for first point of RMS calculation [sec]
%     rms_xmax        : (scalar) time for last point of RMS calculation [sec]
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
%     time_one        = 0:10;
%     time_two        = 2:12;
%     quat_one        = quat_norm(rand(4,11));
%     quat_two        = quat_norm(rand(4,11));
%     name_one        = 'test1';
%     name_two        = 'test2';
%     start_date      = datestr(now);
%     rms_xmin        = 1;
%     rms_xmax        = 10;
%     fig_visible     = 'on';
%     make_subplots   = true;
%     plot_components = true;
%     [fig_hand, err] = general_quaternion_plot(description, time_one, time_two, quat_one, quat_two, ...
%         name_one, name_two, start_date, rms_xmin, rms_xmax, fig_visible, make_subplots, ...
%         plot_components);
%
% See Also:
%     TBD_wrapper
%
% Change Log:
%     1.  Functionalized by David C. Stauffer in October 2011.
%     2.  Incorporated by David C. Stauffer into DStauffman tools in December 2018.

%% calculations
precision = 1e-12;
[time_overlap, q1_diff_ix, q2_diff_ix] = intersect2(time_one, time_two, precision);
rms_ix1  = time_one >= rms_xmin & time_one <= rms_xmax;
rms_ix2  = time_two >= rms_xmin & time_two <= rms_xmax;
rms_ix3  = time_overlap >= rms_xmin & time_overlap <= rms_xmax;
rms_pts1 = max([rms_xmin min([min(time_one) min(time_two)])]);
rms_pts2 = min([rms_xmax max([max(time_one) max(time_two)])]);
q1_rms   = nanrms(quat_one(:,rms_ix1),2);
q2_rms   = nanrms(quat_two(:,rms_ix2),2);
[nondeg_angle, nondeg_error] = quat_angle_diff(quat_one(:, q1_diff_ix), quat_two(:, q2_diff_ix));
nondeg_rms = nanrms(nondeg_error(:, rms_ix3), 2);
% output errors
err = [q1_rms; q2_rms; nondeg_rms; nondeg_angle];
% get default plotting colors
color_lists = get_color_lists();
colororder3 = cell2mat(color_lists.vec_diff);
colororder8 = cell2mat(color_lists.quat_diff);
% quaternion component names
elements = {'X','Y','Z','S'};
% names = {'qx','qy','qz','qs'};
% TODO: make non-harded coded
% unit conversion value
rad2urad = 1e6;
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
    for i = 1:4
        plot(ax1,time_one,quat_one(i,:),'^-','MarkerSize',4,'Color',colororder8(i+4-4*have_quat_two,:),...
            'DisplayName',[name_one,' ',elements{i},' (RMS: ',num2str(q1_rms(i),'%1.3f'),')']);
    end
end
if have_quat_two
    for i = 1:4
        plot(ax1,time_two,quat_two(i,:),'v:','MarkerSize',4,'Color',colororder8(i+4,:),...
            'DisplayName',[name_two,' ',elements{i},' (RMS: ',num2str(q2_rms(i),'%1.3f'),')']);
    end
end
% format display of plot
legend('show','Location','North');
plot_rms_lines([rms_pts1,rms_pts2],ylim);
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
        hold on;
        for i = 3:-1:1 % plot Z, Y, X so X is on top
            plot(ax2,time_overlap,nondeg_error(i,:),'^-','MarkerSize',4,'DisplayName',...
                [elements{i},' (RMS: ',num2str(rad2urad*nondeg_rms(1),'%1.3f'),' \murad)']);
        end
        lg = legend('show','Location','North');
        % reorder to put X first in legend, but still on top of plot
        lg.PlotChildren = lg.PlotChildren(3:-1:1); % TODO: doesn't seem to work
        % This reorders the legend:
        %h = get(ax2,'Children');
        %uistack(h(2),'bottom');
        %uistack(h(3),'bottom');
    else
        plot(ax2,time_overlap,nondeg_angle,'^-','MarkerSize',4,'DisplayName',...
            ['Angle (RMS: ',num2str(rad2urad*nondeg_rms(1),'%1.3f'),' \murad)']);
        legend('show','Location','North');
    end
    % format display of plot
    plot_rms_lines([rms_pts1,rms_pts2],ylim);
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