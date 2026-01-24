function [fig_hand, err] = plot_quaternion(description, time_one, time_two, quat_one, quat_two, varargin)

% PLOT_QUATERNION  plots multiple metrics over time.
%
%
% Input:
%         'Description' : (char) text to put on the plot titles, default is empty string
%         'TimeTwo'     : (1xA) time points for series two, default is empty
%         'QuatTwo'     : (BxA) data points for series two, default is empty
%     time_one .. : (1xN) time points [years]
%     quat_one .. : (MxN) data points [num]
%     OPTS ...... : (class) optional plotting commands, see Opts.m for more information
%     varargin .. : (char, value) pairs for other options, from:
%         'Type'        : (char) type of data to use when converting axis scale, default is 'unity'
%         'TruthTime'   : (1xC) time points for truth data, default is empty
%         'TruthData'   : (DxC) data points for truth data, default is empty
%         'TruthName'   : (char) or {Dx1} of (char) name for truth data on the legend, if empty
%                              don't include, default is 'Truth'
%
% Output:
%     fig_hand .. : (scalar) figure handles [num]
%     err
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
%     opts = matspace.plotting.Opts();
%     opts.case_name = 'test_plot';
%     opts.quat_comp = true;
%     opts.sub_plots = true;
%     opts.names = ["KF1", "KF2"];
%
%     fig_hand = matspace.plotting.plot_quaternion('Quaternion', time_one, time_two, quat_one, quat_two, Opts=opts);
%
%     % clean up
%     close(fig_hand);
%
% See Also:
%     figmenu, setup_dir, plot_rms_lines, make_quaternion_plot
%
% Change Log:
%     1.  Written by David C. Stauffer in March 2025 to wrap existing general_quaternion_plot.
%     2.  Updated by David C. Stauffer in January 2026 to more closely mimic Python version.

%% Imports
import matspace.plotting.convert_time_to_date
import matspace.plotting.figmenu
import matspace.plotting.get_start_date
import matspace.plotting.make_quaternion_plot
import matspace.plotting.Opts
import matspace.plotting.private.fun_is_log_level
import matspace.plotting.private.fun_is_opts
import matspace.plotting.private.fun_is_quat
import matspace.plotting.private.fun_is_text
import matspace.plotting.private.fun_is_time
import matspace.plotting.private.kwargs_pop
import matspace.plotting.setup_plots

%% Parse Inputs
% create parser
p = inputParser;
p.KeepUnmatched = true;
% set options
addRequired(p, 'Description', @fun_is_text);
addRequired(p, 'TimeOne', @fun_is_time);
addRequired(p, 'TimeTwo', @fun_is_time);
addRequired(p, 'QuatOne', @fun_is_quat);
addRequired(p, 'QuatTwo', @fun_is_quat);
addParameter(p, 'Opts', Opts(), @fun_is_opts);
addParameter(p, 'SkipSetupPlots', false, @fun_is_bool);
addParameter(p, 'LogLevel', 10, @fun_is_log_level);
%addParameter(p, 'TruthTime', [], @fun_is_time);
%addParameter(p, 'TruthData', zeros(4, 0, class(quat_one)), @isnumeric);
%addParameter(p, 'TruthName', 'Truth', @fun_is_text);
% do parse
parse(p, description, time_one, time_two, quat_one, quat_two, varargin{:});
% create some convenient aliases
opts             = p.Results.Opts;
skip_setup_plots = p.Results.SkipSetupPlots;
log_level        = p.Results.LogLevel;
%truth_name       = p.Results.TruthName;
%truth_time       = p.Results.TruthTime;
%truth_data       = p.Results.TruthData;
unmatched        = p.Unmatched;

% determine if converting units
is_date_1 = isdatetime(time_one);
is_date_2 = isdatetime(time_two);
is_date_o = opts.time_unit == "datetime";

% make local copy of opts that can be modified without changing the original
this_opts = Opts(opts);
% allow opts to convert as necessary
if is_date_1 || (is_date_2 && ~is_date_o)
    this_opts.convert_dates("datetime", old_form=opts.time_base)
elseif is_date_o && ~is_date_1 && ~is_date_2
    this_opts.convert_dates("sec", old_form=opts.time_base)
end
% opts overrides
[this_opts.save_plot, unmatched] = kwargs_pop(unmatched, 'SavePlot', this_opts.save_plot);
[this_opts.save_path, unmatched] = kwargs_pop(unmatched, 'save_path', this_opts.save_path);
[this_opts.classify,  unmatched] = kwargs_pop(unmatched, 'classify', this_opts.classify);

% alias opts
[time_units,   unmatched] = kwargs_pop(unmatched, 'TimeUnits', this_opts.time_base);
[start_date,   unmatched] = kwargs_pop(unmatched, 'StartDate', this_opts.get_date_zero_str());
[rms_xmin,     unmatched] = kwargs_pop(unmatched, 'RmsXmin', this_opts.rms_xmin);
[rms_xmax,     unmatched] = kwargs_pop(unmatched, 'RmsXmax', this_opts.rms_xmax);
[disp_xmin,    unmatched] = kwargs_pop(unmatched, 'DispXmin', this_opts.disp_xmin);
[disp_xmax,    unmatched] = kwargs_pop(unmatched, 'DispXmax', this_opts.disp_xmax);
[sub_plots,    unmatched] = kwargs_pop(unmatched, 'MakeSubplots', this_opts.sub_plots);
[plot_comps,   unmatched] = kwargs_pop(unmatched, 'PlotComponents', this_opts.quat_comp);
[single_lines, unmatched] = kwargs_pop(unmatched, 'SingleLines', this_opts.sing_line);
[use_mean,     unmatched] = kwargs_pop(unmatched, 'UseMean', this_opts.use_mean);
[lab_vert,     unmatched] = kwargs_pop(unmatched, 'LabelVertLines', this_opts.lab_vert);
[plot_zero,    unmatched] = kwargs_pop(unmatched, 'PlotZero', this_opts.show_zero);
[show_rms,     unmatched] = kwargs_pop(unmatched, 'ShowRms', this_opts.show_rms);
[legend_loc,   unmatched] = kwargs_pop(unmatched, 'LegendLoc', this_opts.leg_spot);
[show_extra,   unmatched] = kwargs_pop(unmatched, 'ShowExtra', this_opts.show_xtra);
[name_one,     unmatched] = kwargs_pop(unmatched, 'NameOne', '');
[name_two,     unmatched] = kwargs_pop(unmatched, 'NameTwo', '');
[name_one, name_two] = this_opts.get_name_one_and_two(NameOne=name_one, NameTwo=name_two);

% hard-coded defaults
[second_units, unmatched] = kwargs_pop(unmatched, 'second_units', 'micro');

% print status
if log_level >= 4
    fprintf(1, "Plotting %s plots ...", description);
end

% make plots
unmatched_args = namedargs2cell(unmatched);
[fig_hand, err] = make_quaternion_plot(...
    description, ...
    time_one, ...
    time_two, ...
    quat_one, ...
    quat_two, ...
    unmatched_args{:}, ...
    NameOne=name_one, ...
    NameTwo=name_two, ...
    TimeUnits=time_units, ...
    StartDate=start_date, ...
    RmsXmin=rms_xmin, ...
    RmsXmax=rms_xmax, ...
    DispXmin=disp_xmin, ...
    DispXmax=disp_xmax, ...
    MakeSubplots=sub_plots, ...
    PlotComponents=plot_comps, ...
    SingleLines=single_lines, ...
    UseMean=use_mean, ...
    LabelVertLines=lab_vert, ...
    PlotZero=plot_zero, ...
    ShowRms=show_rms, ...
    LegendLoc=legend_loc, ...
    ShowExtra=show_extra, ...
    SecondUnits=second_units,...
    LogLevel=log_level);

if ~skip_setup_plots
    % create figure controls
    figmenu;
    
    % setup plots
    setup_plots(fig_hand, opts, 'time');
end