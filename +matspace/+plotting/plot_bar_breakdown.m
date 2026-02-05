function [fig_hand] = plot_bar_breakdown(description, time, data, varargin)

% PLOT_BAR_BREAKDOWN  Plot the pie chart like breakdown by percentage in each category over time.
%
% Inputs:
%     description : (1xN) Plot title [char]
%     time        : (1xN) time history
%     data        : (MxN) data for corresponding time history
%     kwargs ........... :
%         Opts           : (class) plotting options
%         IgnoreEmpties  : Removes any entries from the plot and legend that contain only zeros or only NaNs
%         SkipSetupPlots : Whether to skip the setup_plots step, in case you are manually adding to an existing axis
%         SlideBy        : If non-zero, then calculate a sliding mean over the given number of data points
%         SubBy          : If non-zero, then only plot zero sub_by time point, holding values in-between
%         (Extras)
%
% Output:
%     fig_hand .. : (scalar) figure handle
%
% Prototype:
%     description = 'Test';
%     time        = (0:1/12:5) + 2000;
%     data        = rand(5, length(time));
%     mag         = sum(data, 1);
%     data        = data ./ mag;
%     fig_hand    = matspace.plotting.plot_bar_breakdown(description, time, data);
%
%     % Close plot
%     close(fig_hand)
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2017.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.
%     3.  Updated by David C. Stauffer in February 2026 for SlideBy and SubBy options.

%% Imports
import matspace.plotting.figmenu
import matspace.plotting.make_bar_plot
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
addParameter(p, 'SlideBy', 0, @isscalar);  % && @isnumeric
addParameter(p, 'SubBy', 0, @isscalar)  % && @isnumeric
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
slide_by         = p.Results.SlideBy;
sub_by           = p.Results.SubBy;
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
[color_map,    unmatched] = kwargs_pop(unmatched, 'ColorMap', this_opts.colormap);
if isempty(color_map)
    color_map = parula(8);  % TODO: replace with ColorMap class
end
[use_mean,     unmatched] = kwargs_pop(unmatched, 'UseMean', this_opts.use_mean);
[lab_vert,     unmatched] = kwargs_pop(unmatched, 'LabelVertLines', this_opts.lab_vert);
[plot_zero,    unmatched] = kwargs_pop(unmatched, 'PlotZero', this_opts.show_zero);
[show_rms,     unmatched] = kwargs_pop(unmatched, 'ShowRms', this_opts.show_rms);
[legend_loc,   unmatched] = kwargs_pop(unmatched, 'LegendLoc', this_opts.leg_spot);
[fig_visible,  unmatched] = kwargs_pop(unmatched, 'FigVisible', this_opts.show_plot);

% hard-coded values
scale = 100;
units = '%';

% smooth over the given number of data points
[data_as_rows, unmatched] = kwargs_pop(unmatched, 'DataAsRows', true);
if slide_by ~= 0
    if ~data_as_rows
        error('This has not been coded.');  % TODO: is this true?
    end
    smooth_time = time;
    smooth_data = data;
    if isvector(smooth_data) && iscol(smooth_data)
        axis = 1;
    else
        axis = 2;
    end
    for i = 1:size(smooth_data, axis)  % TODO: get rid of this loop
        if axis == 1
            smooth_data(i, :) = mean(smooth_data(i:i+slide_by, :), axis, 'OmitNaN');
        else
            smooth_data(:, i) = mean(smooth_data(:, i:i+slide_by), axis, 'OmitNaN');
        end
        smooth_data(isnan(data)) = nan;
    end
else
    smooth_time = time;
    smooth_data = data;
end

% subsample the (potentially smoothed) data points
if sub_by ~= 0
    if data_as_rows
        sub_time = smooth_time(:, 1:sub_by:end);
        sub_data = smooth_data(:, 1:sub_by:end);
    else
        sub_time = smooth_time(1:sub_by:end, :);
        sub_data = smooth_data(1:sub_by:end, :);
    end
else
    sub_time = smooth_time;
    sub_data = smooth_data;
end

% call wrapper function for most of the details
unmatched_args = namedargs2cell(unmatched);
fig_hand = make_bar_plot(...
    description, ...
    sub_time, ...
    scale * sub_data, ...
    unmatched_args{:}, ...
    Units=units, ...
    TimeUnits=time_units, ...
    StartDate=start_date, ...
    RmsXmin=rms_xmin, ...
    RmsXmax=rms_xmax, ...
    DispXmin=disp_xmin, ...
    DispXmax=disp_xmax, ...
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