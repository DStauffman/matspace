function [fig_hand] = plot_time_history(description, time, data, varargin)

% PLOT_TIME_HISTORY  plots multiple metrics over time.
%
%
% Input:
%     description : (char) text to put on the plot titles, default is empty string
%     time ...... : (1xN) time points [years]
%     data ...... : (MxN) data points [num]
%     varargin .. : (char, value) pairs for other options, from:
%         Opts ......... : (char) (class) optional plotting commands, see Opts.m for more information
%         IgnoreEmpties  :
%         SkipSetupPlots :
%         CaseName ..... :
%         SavePlot ..... :
%         SavePath ..... :
%         Classify ..... :
%     additional arguments from make_time_plot:
%         Name
%         Elements
%         Units
%         TimeUnits
%         StartDate
%         RmsXmin
%         RmsXmax
%         DispXmin
%         DispXmax
%         SingleLines
%         FigVisible
%         ColorMap
%         UseMean
%         PlotZero
%         ShowRms
%         LegendLoc
%         SecondUnits
%         LegendScale
%         YLabel
%         YLims
%         DataAsRows
%         ExtraPlotter
%         UseZoh
%         LabelVertLines
%         UseDatashader
%         FigAx
%         PlotType
%
% Output:
%     fig_hand .. : (scalar) figure handles [num]
%
% Prototype:
%     description = 'Random Data';
%     time        = 1:10;
%     data        = rand(5,length(time));
%     fig_hand    = matspace.plotting.plot_time_history(description, time, data);
%
%     % clean up
%     close(fig_hand);
%
% See Also:
%     matspace.plotting.figmenu, matspace.plotting.make_time_plot, matspace.plotting.setup_plots
%
% Change Log:
%     1.  Written by David C. Stauffer in September 2017.
%     2.  Updated by David C. Stauffer in March 2019 to be a wrapper to an even more generic
%         function for plotting.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.
%     4.  Rewritten by David C. Stauffer in January 2026 based on newer python version.

%% Imports
import matspace.plotting.figmenu
import matspace.plotting.get_start_date
import matspace.plotting.make_time_plot
import matspace.plotting.ignore_plot_data
import matspace.plotting.Opts
import matspace.plotting.private.fun_is_bool
import matspace.plotting.private.fun_is_data
import matspace.plotting.private.fun_is_log_level
import matspace.plotting.private.fun_is_opts
import matspace.plotting.private.fun_is_text
import matspace.plotting.private.fun_is_time
import matspace.plotting.private.kwargs_pop
import matspace.plotting.setup_plots

%% Parser
% Argument parser
p = inputParser;
p.KeepUnmatched = true;
addRequired(p, 'Description', @fun_is_text);
addRequired(p, 'Time', @fun_is_time);
addRequired(p, 'Data', @fun_is_data);
addParameter(p, 'Opts', Opts(), @fun_is_opts);
addParameter(p, 'IgnoreEmpties', false, @fun_is_bool);
addParameter(p, 'SkipSetupPlots', false, @fun_is_bool);
addParameter(p, 'CaseName', '', @fun_is_text);
addParameter(p, 'SavePlot', false, @fun_is_bool);
addParameter(p, 'SavePath', '', @fun_is_text);
addParameter(p, 'Classify', @fun_is_text);
addParameter(p, 'LogLevel', 10, @fun_is_log_level);
% do parse
parse(p, description, time, data, varargin{:});
% create some convenient aliases
opts             = p.Results.Opts;
ignore_empties   = p.Results.IgnoreEmpties;
skip_setup_plots = p.Results.SkipSetupPlots;
log_level        = p.Results.LogLevel;
unmatched        = p.Unmatched;

%% Check for valid data
if ignore_plot_data(data, ignore_empties)
    if log_level >= 5
        fprintf(1, ' %s plot skipped due to missing data.\n', description);
    end
    fig_hand = gobjects(1, 0);  % TODO: handle FigAx input case
    return
end

%% Processing
% make local copy of opts that can be modified without changing the original
this_opts = Opts(opts);
% opts overrides
[this_opts.case_name, unmatched] = kwargs_pop(unmatched, 'CaseName', this_opts.case_name);
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
[single_lines, unmatched] = kwargs_pop(unmatched, 'SingleLines', this_opts.sing_line);
[color_map,    unmatched] = kwargs_pop(unmatched, 'ColorMap', this_opts.colormap);
if isempty(color_map)
    color_map = parula(8);  % TODO: make full ColorMap class
end
[use_mean,     unmatched] = kwargs_pop(unmatched, 'UseMean', this_opts.use_mean);
[lab_vert,     unmatched] = kwargs_pop(unmatched, 'LabelVertLines', this_opts.lab_vert);
[plot_zero,    unmatched] = kwargs_pop(unmatched, 'PlotZero', this_opts.show_zero);
[show_rms,     unmatched] = kwargs_pop(unmatched, 'ShowRms', this_opts.show_rms);
[legend_loc,   unmatched] = kwargs_pop(unmatched, 'LegendLoc', this_opts.leg_spot);
[fig_visible,  unmatched] = kwargs_pop(unmatched, 'FigVisible', this_opts.show_plot);

%% Plot data
% call wrapper function for most of the details
unmatched_args = namedargs2cell(unmatched);
fig_hand = make_time_plot(...
    description, ...
    time, ...
    data, ...
    unmatched_args{:}, ...
    TimeUnits=time_units, ...
    StartDate=start_date, ...
    RmsXmin=rms_xmin, ...
    RmsXmax=rms_xmax, ...
    DispXmin=disp_xmin, ...
    DispXmax=disp_xmax, ...
    SingleLines=single_lines, ...
    ColorMap=color_map, ...
    UseMean=use_mean, ...
    LabelVertLines=lab_vert, ...
    PlotZero=plot_zero, ...
    ShowRms=show_rms, ...
    LegendLoc=legend_loc, ...
    FigVisible=fig_visible);

if ~skip_setup_plots
    % create figure controls
    figmenu;

    % setup plots
    setup_plots(fig_hand, this_opts, 'time');
end