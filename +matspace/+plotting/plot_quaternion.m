function [fig_hand] = plot_quaternion(time_one, quat_one, varargin)

% PLOT_QUATERNION  plots multiple metrics over time.
%
%
% Input:
%     time_one .. : (1xN) time points [years]
%     quat_one .. : (MxN) data points [num]
%     OPTS ...... : (class) optional plotting commands, see Opts.m for more information
%     varargin .. : (char, value) pairs for other options, from:
%         'Description' : (char) text to put on the plot titles, default is empty string
%         'Type'        : (char) type of data to use when converting axis scale, default is 'unity'
%         'TimeTwo'     : (1xA) time points for series two, default is empty
%         'QuatTwo'     : (BxA) data points for series two, default is empty
%         'TruthTime'   : (1xC) time points for truth data, default is empty
%         'TruthData'   : (DxC) data points for truth data, default is empty
%         'TruthName'   : (char) or {Dx1} of (char) name for truth data on the legend, if empty
%                              don't include, default is 'Truth'
%
% Output:
%     fig_hand .. : (scalar) figure handles [num]
%
% Prototype:
%     q1 = matspace.quaternions.quat_norm([0.1; -0.2; 0.3; 0.4]);
%     dq = matspace.quaternions.quat_from_euler(1e-6*[-300; 100; 200], [3; 1; 2]);
%     q2 = matspace.quaternions.quat_mult_single(dq, q1);
%
%     time_one = 0:10;
%     quat_one = repmat(q1, [1 length(time_one)]);
%
%     time_two = 2:12;
%     quat_two = repmat(q2, [1, length(time_two)]);
%     quat_two(4,3) = quat_two(4,3) + 50e-6;
%     quat_two = matspace.quaternions.quat_norm(quat_two);
%
%     OPTS = matspace.plotting.Opts();
%     OPTS.case_name = 'test_plot';
%     OPTS.quat_comp = true;
%     OPTS.sub_plots = true;
%     OPTS.names = ["KF1", "KF2"];
%
%     fig_hand = matspace.plotting.plot_quaternion(time_one, quat_one, OPTS, 'TimeTwo', time_two, ...
%         'QuatTwo', quat_two);
%
%     % clean up
%     close(fig_hand);
%
% See Also:
%     figmenu, setup_dir, plot_rms_lines, general_difference_plot
%
% Change Log:
%     1.  Written by David C. Stauffer in March 2025 to wrap existing general_quaternion_plot.

%% Imports
import matspace.plotting.convert_time_to_date
import matspace.plotting.figmenu
import matspace.plotting.general_quaternion_plot
import matspace.plotting.get_start_date
import matspace.plotting.Opts
import matspace.plotting.setup_plots

%% Parse Inputs
% create parser
p = inputParser;
% create some validation functions
fun_is_opts = @(x) isa(x, 'matspace.plotting.Opts') || isempty(x);
fun_is_time = @(x) (isnumeric(x) || isdatetime(x)) && (isempty(x) || isvector(x));
fun_is_delta = @(x) isnumeric(x) || isduration(x);
% set options
addRequired(p, 'TimeOne', fun_is_time);
addRequired(p, 'QuatOne', @isnumeric);
addOptional(p, 'OPTS', Opts, fun_is_opts);
addParameter(p, 'Description', '', @ischar);
addParameter(p, 'TimeTwo', [], fun_is_time);
addParameter(p, 'QuatTwo', zeros(4, 0, class(quat_one)), @isnumeric);
addParameter(p, 'Tolerance', 0.0, fun_is_delta);
addParameter(p, 'TruthTime', [], fun_is_time);
addParameter(p, 'TruthData', zeros(4, 0, class(quat_one)), @isnumeric);
addParameter(p, 'TruthName', 'Truth', @ischar);
% do parse
parse(p, time_one, quat_one, varargin{:});
% create some convenient aliases
description = p.Results.Description;
tolerance   = p.Results.Tolerance;
% create data channel aliases
time_two    = p.Results.TimeTwo;
quat_two    = p.Results.QuatTwo;
truth_name  = p.Results.TruthName;
truth_time  = p.Results.TruthTime;
truth_data  = p.Results.TruthData;
% check time formats for default values
if isdatetime(time_one)
    if isempty(time_two)
        time_two = NaT(0);
    end
    if isempty(truth_time)
        truth_time = NaT(0);
    end
end

%% Process inputs
if ~iscell(truth_name)
    truth_name = {truth_name};
end
if isempty(p.Results.OPTS)
    OPTS = Opts();
else
    OPTS = p.Results.OPTS;
end

%% Process for comparisons and alias OPTS information
% alias OPTS information
show_plot   = OPTS.show_plot;
sub_plots   = OPTS.sub_plots;
single_line = OPTS.sing_line;
show_rms    = OPTS.show_rms;
use_mean    = OPTS.use_mean;
show_zero   = OPTS.show_zero;
plot_comp   = OPTS.quat_comp;
time_units  = OPTS.time_base;
rms_xmin    = OPTS.rms_xmin;
rms_xmax    = OPTS.rms_xmax;
disp_xmin   = OPTS.disp_xmin;
disp_xmax   = OPTS.disp_xmax;
show_extra  = OPTS.show_xtra;
start_date  = get_start_date(OPTS.date_zero);
legend_loc  = OPTS.leg_spot;
if length(OPTS.names) >= 1
    name_one = OPTS.names{1};
else
    name_one = '';
end
if length(OPTS.names) >= 2
    name_two = OPTS.names{2};
else
    name_two = '';
end

%% Potentially convert times to dates
if strcmp(OPTS.time_unit, 'datetime')
    date_zero  = OPTS.date_zero;
    time_one   = convert_time_to_date(time_one,   date_zero, time_units);
    time_two   = convert_time_to_date(time_two,   date_zero, time_units);
    truth_time = convert_time_to_date(truth_time, date_zero, time_units);
    disp_xmin  = convert_time_to_date(disp_xmin,  date_zero, time_units);
    disp_xmax  = convert_time_to_date(disp_xmax,  date_zero, time_units);
    rms_xmin   = convert_time_to_date(rms_xmin,   date_zero, time_units);
    rms_xmax   = convert_time_to_date(rms_xmax,   date_zero, time_units);
end

%% Plot data
% calls lower level function
fig_hand = general_quaternion_plot(description, time_one, time_two, quat_one, quat_two, ...
    'NameOne', name_one, 'NameTwo', name_two, 'TimeUnits', time_units, 'StartDate', start_date, ...
    'PlotComp', plot_comp, 'RmsXmin', rms_xmin, 'RmsXmax', rms_xmax, 'DispXmin', disp_xmin, 'DispXmax', disp_xmax, ...
    'FigVisible', show_plot, 'MakeSubplots', sub_plots, 'SingleLines', single_line, ...
    'UseMean', use_mean, 'PlotZero', show_zero, 'ShowRms', show_rms, ...
    'LegendLoc', legend_loc, 'ShowExtra', show_extra, ...
    'TruthName', truth_name, 'TruthTime', truth_time, 'TruthData', truth_data, ...
    'Tolerance', tolerance);

% create figure controls
figmenu;

% setup plots
setup_plots(fig_hand, OPTS, 'time');