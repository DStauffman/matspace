function [fig_hand, err] = plot_time_difference(description, time_one, data_one, time_two, data_two, varargin)

% Plot multiple metrics over time.
%
% Parameters
% ----------
% description : str
%     Name to label on the plots
% time_one : 1D ndarray
%     time history
% data_one : 0D, 1D, or 2D ndarray
%     data for corresponding time history, time is last dimension unless passing data_as_rows=False through
% time_two : 1D ndarray
%     time history for series two
% data_two : 0D, 1D, or 2D ndarray
%     data for corresponding time history, time is last dimension unless passing data_as_rows=False through
% opts : class Opts, optional
%     plotting options
% ignore_empties : bool, optional
%     Removes any entries from the plot and legend that contain only zeros or only NaNs
% skip_setup_plots : bool, optional, default is False
%     Whether to skip the setup_plots step, in case you are manually adding to an existing axis
% save_plot : bool, optional
%     Ability to overide the option in opts
% return_err : bool, optional, default is False
%     Whether the function should return the error differences in addition to the figure handles
% **kwargs : dict
%     Remaining keyword arguments will be passed to make_time_plot
%
% Returns
% -------
% figs : list of class matplotlib.figure.Figure
%     figure handles
%
% See Also
% --------
% make_time_plot
%
% Notes
% -----
% #.  Written by David C. Stauffer in December 2022.
%
% Prototype:
%     description = 'Random Data'
%     time_one = 2000:1/12:2005;
%     data_one = cumsum(rand(5, length(time_one)), 2);
%     data_one(:) = 10 * data_one ./ data_one(:, end);
%     time_two = 2000:0.5:2005;
%     data_two = cumsum(rand(5, length(time_two)), 2);
%     data_two(:) = 10 * data_two ./ data_two(:, end);
%     figs1 = plot_time_difference(description, time_one, data_one, time_two, data_two);
%
% Date based version
%     time1 = datetime(2020, 05, 01, 00, 00, 00) + seconds(0:5:5*60);
%     time2 = datetime(2020, 05, 01, 00, 00, 00) + seconds(0:30:5*60);
%     figs2 = plot_time_difference(description, time1, data_one, time2, data_two, TimeUnits='datetime');
%
%     % Close plots
%     close(fig_hand1);
%     close(fig_hand2);

%% Imports
import matspace.plotting.convert_time_to_date
import matspace.plotting.figmenu
import matspace.plotting.get_start_date
import matspace.plotting.ignore_plot_data
import matspace.plotting.make_difference_plot
import matspace.plotting.Opts
import matspace.plotting.private.fun_is_data
import matspace.plotting.private.fun_is_log_level
import matspace.plotting.private.fun_is_opts
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
addRequired(p, 'DataOne', @fun_is_data);  % TODO: reorder to match the rest of them?
addRequired(p, 'TimeTwo', @fun_is_time);
addRequired(p, 'DataTwo', @fun_is_data);
addParameter(p, 'Opts', Opts(), @fun_is_opts);
addParameter(p, 'IgnoreEmpties', false, @fun_is_bool);
addParameter(p, 'SkipSetupPlots', false, @fun_is_bool);
addParameter(p, 'LogLevel', 10, @fun_is_log_level);
% do parse
parse(p, description, time_one, data_one, time_two, data_two, varargin{:});
% create some convenient aliases
opts             = p.Results.Opts;
ignore_empties   = p.Results.IgnoreEmpties;
skip_setup_plots = p.Results.SkipSetupPlots;
log_level        = p.Results.LogLevel;
unmatched        = p.Unmatched;

%% Check for valid data
if ignore_plot_data(data_one, ignore_empties) && ignore_plot_data(data_two, ignore_empties)
    if log_level >= 5
        fprint1(1, " %s plot skipped due to missing data.", description);
    end
    fig_hand = gobjects(1, 0);
    err = [];
    return
end

%% Processing
% determine if converting units
is_date_1 = isdatetime(time_one);
is_date_2 = isdatetime(time_two);
is_date_o = opts.time_unit == "datetime";

% make local copy of opts that can be modified without changing the original
this_opts = Opts(opts);
% allow opts to convert as necessary
if is_date_1 || (is_date_2 && ~is_date_o)
    this_opts.convert_dates('datetime');
elseif is_date_o && ~is_date_1 && ~is_date_2
    this_opts.convert_dates('sec');
end
% opts overrides
[this_opts.save_plot, unmatched] = kwargs_pop(unmatched, 'SavePlot', this_opts.save_plot);
[this_opts.save_path, unmatched] = kwargs_pop(unmatched, 'SavePath', this_opts.save_path);
[this_opts.classify,  unmatched] = kwargs_pop(unmatched, 'Classify', this_opts.classify);

% alias opts
[time_units,   unmatched] = kwargs_pop(unmatched, 'TimeUnits', this_opts.time_base);
[start_date,   unmatched] = kwargs_pop(unmatched, 'StartDate', this_opts.get_date_zero_str());
[rms_xmin,     unmatched] = kwargs_pop(unmatched, 'RmsXmin', this_opts.rms_xmin);
[rms_xmax,     unmatched] = kwargs_pop(unmatched, 'RmsXmax', this_opts.rms_xmax);
[disp_xmin,    unmatched] = kwargs_pop(unmatched, 'DispXmin', this_opts.disp_xmin);
[disp_xmax,    unmatched] = kwargs_pop(unmatched, 'DispXmax', this_opts.disp_xmax);
[sub_plots,    unmatched] = kwargs_pop(unmatched, 'MakeSubplots', this_opts.sub_plots);
[single_lines, unmatched] = kwargs_pop(unmatched, 'SingleLines', this_opts.sing_line);
[color_map,    unmatched] = kwargs_pop(unmatched, 'ColorMap', this_opts.colormap);
[use_mean,     unmatched] = kwargs_pop(unmatched, 'UseMean', this_opts.use_mean);
[lab_vert,     unmatched] = kwargs_pop(unmatched, 'LabelVertLines', this_opts.lab_vert);
[plot_zero,    unmatched] = kwargs_pop(unmatched, 'PlotZero', this_opts.show_zero);
[show_rms,     unmatched] = kwargs_pop(unmatched, 'ShowRms', this_opts.show_rms);
[legend_loc,   unmatched] = kwargs_pop(unmatched, 'LegendLoc', this_opts.leg_spot);
[show_extra,   unmatched] = kwargs_pop(unmatched, 'ShowExtra', this_opts.show_xtra);
[name_one,     unmatched] = kwargs_pop(unmatched, 'NameOne', '');
[name_two,     unmatched] = kwargs_pop(unmatched, 'NameTwo', '');
[name_one, name_two] = this_opts.get_name_one_and_two(NameOne=name_one, NameTwo=name_two);

% print status
if log_level >= 4
    fprintf(1, "Plotting %s plots ...", description);
end

% make plots
unmatched_args = namedargs2cell(unmatched);
[fig_hand, err] = make_difference_plot(...
    description, ...
    time_one, ...
    data_one, ...
    time_two, ...
    data_two, ...
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
    SingleLines=single_lines, ...
    ColorMap=color_map, ...
    UseMean=use_mean, ...
    LabelVertLines=lab_vert, ...
    PlotZero=plot_zero, ...
    ShowRms=show_rms, ...
    LegendLoc=legend_loc, ...
    ShowExtra=show_extra, ...
    LogLevel=log_level);

if ~skip_setup_plots
    % create figure controls
    figmenu;

    % setup plots
    setup_plots(fig_hand, opts, 'time');
end