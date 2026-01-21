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
%     figmenu, setup_dir, plot_rms_lines, general_difference_plot
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
case_name        = p.Results.CaseName;
save_plot        = p.Results.SavePlot;
save_path        = p.Results.SavePath;
classify         = p.Results.Classify;
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
this_opts = Opts(opts);
% opts overrides
if ~ismember('CaseName', p.UsingDefaults)
    this_opts.case_name = case_name;
end
if ~ismember('SavePlot', p.UsingDefaults)
    this_opts.save_plot = save_plot;
end
if ~ismember('SavePath', p.UsingDefaults)
    this_opts.save_path = save_path;
end
if ~ismember('Classify', p.UsingDefaults)
    this_opts.classify = classify;
end

% alias opts
if isfield(unmatched, 'TimeUnits')
    time_units = unmatched.TimeUnits;
    unmatched = rmfield(unmatched, 'TimeUnits');
else
    time_units = this_opts.time_base;
end
if isfield(unmatched, 'StartDate')
    start_date = unmatched.StartDate;
    unmatched = rmfield(unmatched, 'StartDate');
else
    start_date = get_start_date(this_opts.date_zero);  % this_opts.get_date_zero_str();
end
if isfield(unmatched, 'RmsXmin')
    rms_xmin = unmatched.RmsXmin;
    unmatched = rmfield(unmatched, 'RmsXmin');
else
    rms_xmin = this_opts.rms_xmin;
end
if isfield(unmatched, 'RmsXmax')
    rms_xmax = unmatched.RmsXmax;
    unmatched = rmfield(unmatched, 'RmsXmax');
else
    rms_xmax = this_opts.rms_xmax;
end
if isfield(unmatched, 'DispXmin')
    disp_xmin = unmatched.DispXmin;
    unmatched = rmfield(unmatched, 'DispXmin');
else
    disp_xmin = this_opts.disp_xmin;
end
if isfield(unmatched, 'DispXmax')
    disp_xmax = unmatched.DispXmax;
    unmatched = rmfield(unmatched, 'DispXmax');
else
    disp_xmax = this_opts.disp_xmax;
end
if isfield(unmatched, 'SingleLines')
    single_lines = unmatched.SingleLines;
    unmatched = rmfield(unmatched, 'SingleLines');
else
    single_lines = this_opts.sing_line;
end
if isfield(unmatched, 'ColorMap')
    color_map = unmatched.ColorMap;
    unmatched = rmfield(unmatched, 'ColorMap');
else
    color_map = this_opts.colormap;
    if isempty(color_map)
        color_map = parula(8);  % TODO: make full ColorMap class
    end
end
if isfield(unmatched, 'UseMean')
    use_mean = unmatched.UseMean;
    unmatched = rmfield(unmatched, 'UseMean');
else
    use_mean = this_opts.use_mean;
end
if isfield(unmatched, 'LabelVertLines')
    lab_vert = unmatched.LabelVertLines;
    unmatched = rmfield(unmatched, 'LabelVertLines');
else
    lab_vert = this_opts.lab_vert;
end
if isfield(unmatched, 'PlotZero')
    plot_zero = unmatched.PlotZero;
    unmatched = rmfield(unmatched, 'PlotZero');
else
    plot_zero = this_opts.show_zero;
end
if isfield(unmatched, 'ShowRms')
    show_rms = unmatched.ShowRms;
    unmatched = rmfield(unmatched, 'ShowRms');
else
    show_rms = this_opts.show_rms;
end
if isfield(unmatched, 'LegendLoc')
    legend_loc = unmatched.LegendLoc;
    unmatched = rmfield(unmatched, 'LegendLoc');
else
    legend_loc = this_opts.leg_spot;
end

%% Plot data
% call wrapper function for most of the details
fig_hand = make_time_plot(...
    description, ...
    time, ...
    data, ...
    unmatched, ...
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
    LegendLoc=legend_loc ...
);

if ~skip_setup_plots
    % create figure controls
    figmenu;
    
    % setup plots
    setup_plots(fig_hand, this_opts, 'time');
end