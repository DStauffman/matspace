function [fig_hand, err] = make_quaternion_plot(description, time_one, quat_one, time_two, quat_two, varargin)

% Generic quaternion comparison plot for use in other wrapper functions.
%
% Plots two quaternion histories over time, along with a difference from one another.
%
% Input:
%     TBD
%
% Output:
%     fig_hand : (1xN) figure handles
%     err : Differences
%
% Prototype:
%     description      = 'example';
%     time_one         = 0:10;
%     time_two         = 2:12;
%     quat_one         = matspace.quaternions.quat_norm(rand(4, 11));
%     quat_two         = matspace.quaternions.quat_norm(quat_one(:, [3, 4, 5, 6, 7, 8, 9, 10, 11, 1, 2]) + 1e-5 * rand(4, 11));
%     name_one         = 'test1';
%     name_two         = 'test2';
%     time_units       = 'sec';
%     start_date       = [', t0 = ',char(datetime('now'))];
%     rms_xmin         = 1;
%     rms_xmax         = 10;
%     disp_xmin        = -2;
%     disp_xmax        = inf;
%     make_subplots    = true;
%     single_lines     = false;
%     use_mean         = false;
%     plot_zero        = false;
%     show_rms         = true;
%     legend_loc       = 'best';
%     show_extra       = true;
%     plot_components  = true;
%     second_units     = {"µrad", 1e6};
%     legend_scale     = [];
%     data_as_rows     = true;
%     tolerance        = 0;
%     use_zoh          = false;
%     label_vert_lines = true;
%     extra_plotter    = [];
%     use_datashader   = false;
%     fig_hand = matspace.plotting.make_quaternion_plot(description, time_one, time_two, quat_one, quat_two, ...
%         NameOne=name_one, NameTwo=name_two, TimeUnits=time_units, StartDate=start_date, ...
%         RmsXmin=rms_xmin, RmsXmax=rms_xmax, DispXmin=disp_xmin, DispXmax=disp_xmax, ...
%         MakeSubplots=make_subplots, SingleLines=single_lines, UseMean=use_mean, ...
%         PlotZero=plot_zero, ShowRms=show_rms, LegendLoc=legend_loc, ShowExtra=show_extra, ...
%         PlotComponents=plot_components, SecondUnits=second_units, LegendScale=legend_scale, ...
%         DataAsRows=data_as_rows, Tolerance=tolerance, UseZoh=use_zoh, ...
%         LabelVertLines=label_vert_lines, ExtraPlotter=extra_plotter, UseDatashader=use_datashader);
%
%     % Close plots
%     close(fig_hand);
%
% Change Log:
%     1.  Written by David C. Stauffer in MATLAB in October 2011, updated in 2018.
%     2.  Ported to Python by David C. Stauffer in December 2018.
%     3.  Made fully functional by David C. Stauffer in March 2019.
%     4.  Wrapped to the generic do everything version by David C. Stauffer in March 2021.
%     5.  Ported by to Matlab by David C. Stauffer in January 2026.

%% Imports
import matspace.plotting.colors.get_color_lists
import matspace.plotting.make_difference_plot
import matspace.plotting.private.fun_is_2nd_units
import matspace.plotting.private.fun_is_bool
import matspace.plotting.private.fun_is_bound
import matspace.plotting.private.fun_is_dt
import matspace.plotting.private.fun_is_extra_plotter
import matspace.plotting.private.fun_is_fig_ax
import matspace.plotting.private.fun_is_log_level
import matspace.plotting.private.fun_is_quat
import matspace.plotting.private.fun_is_text
import matspace.plotting.private.fun_is_time
import matspace.utils.ifelse

%% Parser
% Argument parser
p = inputParser;
addRequired(p, 'Description', @fun_is_text);
addRequired(p, 'TimeOne', @fun_is_time);
addRequired(p, 'QuatOne', @fun_is_quat);
addRequired(p, 'TimeTwo', @fun_is_time);
addRequired(p, 'QuatTwo', @fun_is_quat);
addParameter(p, 'NameOne', '', @fun_is_text);
addParameter(p, 'NameTwo', '', @fun_is_text);
addParameter(p, 'TimeUnits', 'sec', @fun_is_text);
addParameter(p, 'StartDate', '', @fun_is_text);
addParameter(p, 'PlotComponents', true, @fun_is_bool);
addParameter(p, 'RmsXmin', -inf, @fun_is_bound);
addParameter(p, 'RmsXmax', inf, @fun_is_bound);
addParameter(p, 'DispXmin', -inf, @fun_is_bound);
addParameter(p, 'DispXmax', inf, @fun_is_bound);
addParameter(p, 'MakeSubplots', true, @fun_is_bool);
addParameter(p, 'SingleLines', false, @(x) islogical(x) & isvector(x));  % Can be more than one boolean
addParameter(p, 'FigVisible', true, @fun_is_bool);
addParameter(p, 'UseMean', false, @fun_is_bool);
addParameter(p, 'PlotZero', false, @fun_is_bool);
addParameter(p, 'ShowRms', true, @fun_is_bool);
addParameter(p, 'LegendLoc', 'Best', @fun_is_text);
addParameter(p, 'ShowExtra', true, @fun_is_bool);
addParameter(p, 'SecondUnits', nan, @fun_is_2nd_units);
addParameter(p, 'LegendScale', 'unity', @fun_is_2nd_units);
addParameter(p, 'DataAsRows', true, @fun_is_bool);
addParameter(p, 'Tolerance', 0, @fun_is_dt);
addParameter(p, 'UseZoh', false, @fun_is_bool);
addParameter(p, 'LabelVertLines', true, @fun_is_bool);
addParameter(p, 'ExtraPlotter', [], @fun_is_extra_plotter);
addParameter(p, 'UseDatashader', false, @fun_is_bool);
addParameter(p, 'FigAx', [], @fun_is_fig_ax);
addParameter(p, 'LogLevel', 10, @fun_is_log_level);
% do parse
parse(p, description, time_one, quat_one, time_two, quat_two, varargin{:});
% create some convenient aliases
name_one         = p.Results.NameOne;
name_two         = p.Results.NameTwo;
time_units       = p.Results.TimeUnits;
start_date       = p.Results.StartDate;
plot_components  = p.Results.PlotComponents;
rms_xmin         = p.Results.RmsXmin;
rms_xmax         = p.Results.RmsXmax;
disp_xmin        = p.Results.DispXmin;
disp_xmax        = p.Results.DispXmax;
make_subplots    = p.Results.MakeSubplots;
single_lines     = p.Results.SingleLines;
use_mean         = p.Results.UseMean;
plot_zero        = p.Results.PlotZero;
show_rms         = p.Results.ShowRms;
legend_loc       = p.Results.LegendLoc;
show_extra       = p.Results.ShowExtra;
second_units     = p.Results.SecondUnits;
legend_scale     = p.Results.LegendScale;
data_as_rows     = p.Results.DataAsRows;
tolerance        = p.Results.Tolerance;
use_zoh          = p.Results.UseZoh;
label_vert_lines = p.Results.LabelVertLines;
extra_plotter    = p.Results.ExtraPlotter;
use_datashader   = p.Results.UseDatashader;
fig_ax           = p.Results.FigAx;
log_level        = p.Results.LogLevel;
fig_visible_bool = p.Results.FigVisible;

diff_type = ifelse(plot_components, 'quat_comp', 'quat_mag');
if isscalar(single_lines) && single_lines
    diff_type = 'quat_all';
end
if ~isscalar(single_lines) && single_lines(2)
    diff_type = 'quat_all';
end
color_lists = get_color_lists();
[fig_hand, err] = make_difference_plot(...
    description, ...
    time_one, ...
    quat_one, ...
    time_two, ...
    quat_two, ...
    NameOne=name_one, ...
    NameTwo=name_two, ...
    Elements=["X", "Y", "Z", "S"], ...
    Units='rad', ...
    TimeUnits=time_units, ...
    StartDate=start_date, ...
    RmsXmin=rms_xmin, ...
    RmsXmax=rms_xmax, ...
    DispXmin=disp_xmin, ...
    DispXmax=disp_xmax, ...
    SingleLines=single_lines, ...
    MakeSubplots=make_subplots, ...
    ColorMap=color_lists.quat_comp, ...  ColorMap(color_lists.quat_comp), ...
    UseMean=use_mean, ...
    PlotZero=plot_zero, ...
    ShowRms=show_rms, ...
    LegendLoc=legend_loc, ...
    ShowExtra=show_extra, ...
    SecondUnits=second_units, ...
    LegendScale=legend_scale, ...
    Tolerance=tolerance, ...
    DataAsRows=data_as_rows, ...
    ExtraPlotter=extra_plotter, ...
    UseZoh=use_zoh, ...
    LabelVertLines=label_vert_lines, ...
    UseDatashader=use_datashader, ...
    DiffType=diff_type, ...
    FigAx=fig_ax, ...
    LogLevel=log_level, ...
    FigVisible=fig_visible_bool);