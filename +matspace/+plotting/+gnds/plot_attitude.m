function [fig_hand, err] = plot_attitude(kf1, kf2, varargin)

% Plots the attitude quaternion history.
%
% Input:
% kf1 : class Kf
%     Kalman filter output
% kf2 : class Kf, optional
%     Second filter output for potential comparison
% truth : class Kf, optional
%     Third filter output that is considered truth
% opts : class Opts, optional
%     Plotting options
% skip_setup_plots : bool, optional, default is False
%     Whether to skip the setup_plots step
% groups : iterable of ints
%     How to group plots based on state numbers
% fields : dict[str, str], optional
%     Fields to plot, default is covar and Covariance
% **kwargs : dict
%     Additional keyword arguments to override plotting options or pass to lower level plot function
%
% Output:
% fig_hand : list of class matplotlib.figure.Figure
%     Figure handles
% err : dict
%     Numerical outputs of comparison
%
% Prototype:
%     q1 = matspace.quaternions.quat_norm([0.1, -0.2, 0.3, 0.4]);
%     dq = matspace.quaternions.quat_from_euler(1e-6*[-300; 100; 200], [3; 1; 2]);
%     q2 = matspace.quaternions.quat_mult(dq, q1);
%
%     kf1      = [];  % Kf();
%     kf1.name = 'KF1';
%     kf1.time = 0:10;
%     kf1.att  = repmat(q1, [1 length(kf1.time)]);
%
%     kf2      = [];  % Kf();
%     kf2.name = 'KF2'
%     kf2.time = 2:12;
%     kf2.att  = repmat(q2, [1 length(kf2.time)]);
%     kf2.att(4, 5) = kf2.att(4, 5) + 50e-6;
%     kf2.att = matspace.quaternions.quat_norm(kf2.att);
%
%     opts = matspace.plotting.Opts();
%     opts.case_name = 'test_plot'
%     opts.quat_comp = true;
%     opts.sub_plots = true;
%
%     fig_hand = matspace.plotting.gnds.plot_attitude(kf1, kf2, opts=opts);
%
%     % Close plots
%     close(fig_hand);

%% Imports
import matspace.plotting.figmenu
import matspace.plotting.make_quaternion_plot
import matspace.plotting.Opts
import matspace.plotting.private.fun_is_bool
import matspace.plotting.private.fun_is_dict
import matspace.plotting.private.fun_is_gnd
import matspace.plotting.private.fun_is_log_level
import matspace.plotting.private.fun_is_opts
import matspace.plotting.private.fun_is_text
import matspace.plotting.private.kwargs_pop
import matspace.plotting.setup_plots

%% Parser
% Argument parser
p = inputParser;
p.KeepUnmatched = true;
addRequired(p, 'Kf1', @fun_is_gnd);
addRequired(p, 'Kf2', @fun_is_gnd);
addParameter(p, 'Opts', Opts(), @fun_is_opts);
addParameter(p, 'Truth', [], @fun_is_gnd);
addParameter(p, 'SkipSetupPlots', false, @fun_is_bool);
addParameter(p, 'Fields', '', @fun_is_dict);
addParameter(p, 'LogLevel', 10, @fun_is_log_level);
addParameter(p, 'CaseName', '', @fun_is_text);
addParameter(p, 'SavePlot', false, @fun_is_bool);
addParameter(p, 'SavePath', '', @fun_is_text);
addParameter(p, 'Classify', @fun_is_text);
% do parse
parse(p, kf1, kf2, varargin{:});
% create some convenient aliases
opts             = p.Results.Opts;
truth            = p.Results.Truth;
skip_setup_plots = p.Results.SkipSetupPlots;
fields           = p.Results.Fields;
log_level        = p.Results.LogLevel;
unmatched        = p.Unmatched;

% check optional inputs
% if isempty(kf1)
%     kf1 = Kf();
% end
% if isempty(kf2)
%     kf2 = Kf();
% end
if isempty(fields)
    fields = dictionary('att', 'Attitude Quaternion');
end

% determine if converting units
is_date_1 = isdatetime(kf1.time);
is_date_2 = isdatetime(kf2.time);
is_date_o = strcmp(opts.time_unit, "datetime");

% make local copy of opts that can be modified without changing the original
this_opts = Opts(opts);
% allow opts to convert as necessary
if is_date_1 || (is_date_2 && ~is_date_o)
    this_opts = this_opts.convert_dates('datetime');
elseif is_date_o && ~is_date_1 && ~is_date_2
    this_opts = this_opts.convert_dates('sec');
end
% opts overrides
[this_opts.case_name, unmatched] = kwargs_pop(unmatched, 'CaseName', this_opts.case_name);
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
[second_units, unmatched] = kwargs_pop(unmatched, 'SecondUnits', 'micro');

% initialize outputs
fig_hand = gobjects(1, 0);
err = [];
printed = false;

if ~isempty(truth)
    error('Truth manipulations are not yet implemented.');
end

% call wrapper function for most of the details
all_keys = keys(fields);
for k = 1:length(all_keys)
    field = all_keys{k};
    description = fields(field);
    % print status
    if ~printed
        if log_level >= 4
            fprintf(1, 'Plotting %s plots ...', description);
        end
        printed = true;
    end
    % make plots
    unmatched_args = namedargs2cell(unmatched);
    [out_figs, out_err] = make_quaternion_plot(...
        description, ...
        kf1.time, ...
        kf1.(field), ...
        kf2.time, ...
        kf2.(field), ...
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
    fig_hand = [fig_hand, out_figs]; %#ok<AGROW>
    err.(field) = out_err;
end

% Setup plots
if ~skip_setup_plots
    figmenu;
    setup_plots(fig_hand, this_opts);
end
if printed && log_level >= 4
    fprintf(1, '%s\n', '... done.');
end