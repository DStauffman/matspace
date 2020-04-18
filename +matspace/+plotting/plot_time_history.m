function [fig_hand] = plot_time_history(time, data, varargin)

% PLOT_TIME_HISTORY  plots multiple metrics over time.
%
%
% Input:
%     time ...... : (1xN) time points [years]
%     data ...... : (MxN) data points [num]
%     OPTS ...... : (class) optional plotting commands, see Opts.m for more information
%     varargin .. : (char, value) pairs for other options, from:
%         'Description' : (char) text to put on the plot titles, default is empty string
%         'Type'        : (char) type of data to use when converting axis scale, default is 'unity'
%         'Names'       : {1xN} of (char) Names for each channel on the legend, default is empty
%         'TruthTime'   : (1xC) time points for truth data, default is empty
%         'TruthData'   : (DxC) data points for truth data, default is empty
%         'TruthName'   : (char) or {Dx1} of (char) name for truth data on the legend, if empty
%                              don't include, default is 'Truth'
%
% Output:
%     fig_hand .. : (scalar) figure handles [num]
%
% Prototype:
%     time     = 1:10;
%     data     = rand(5,length(time));
%     fig_hand = matspace.plotting.plot_time_history(time, data, [], 'Description', 'Random Data');
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

%% Imports
import matspace.plotting.convert_time_to_date
import matspace.plotting.figmenu
import matspace.plotting.general_difference_plot
import matspace.plotting.get_scale_and_units
import matspace.plotting.get_start_date
import matspace.plotting.Opts
import matspace.plotting.setup_plots
import matspace.plotting.tab10
import matspace.plotting.whitten
import matspace.utils.modd

%% Parse Inputs
% create parser
p = inputParser;
% create some validation functions
fun_is_opts = @(x) isa(x, 'Opts') || isempty(x);
fun_is_time = @(x) (isnumeric(x) || isdatetime(x)) && (isempty(x) || isvector(x));
fun_is_cell_char_or_str = @(x) iscellstr(x) || isstring(x);
fun_is_num_or_cell      = @(x) isnumeric(x) || iscell(x);
% set options
addRequired(p, 'Time', fun_is_time);
addRequired(p, 'Data', @isnumeric);
addOptional(p, 'OPTS', Opts, fun_is_opts);
addParameter(p, 'Description', '', @ischar);
addParameter(p, 'Type', 'unity', @ischar);
addParameter(p, 'Names', {}, fun_is_cell_char_or_str);
addParameter(p, 'TimeTwo', [], fun_is_time);
addParameter(p, 'DataTwo', zeros(1, 0, class(data)), @isnumeric);
addParameter(p, 'TruthTime', [], fun_is_time);
addParameter(p, 'TruthData', zeros(1, 0, class(data)), @isnumeric);
addParameter(p, 'TruthName', 'Truth', @ischar);
addParameter(p, 'SecondYScale', nan, fun_is_num_or_cell);
% do parse
parse(p, time, data, varargin{:});
% create some convenient aliases
type        = p.Results.Type;
description = p.Results.Description;
names       = p.Results.Names;
second_y_scale = p.Results.SecondYScale;
% create data channel aliases
time_two    = p.Results.TimeTwo;
data_two    = p.Results.DataTwo;
truth_name  = p.Results.TruthName;
truth_time  = p.Results.TruthTime;
truth_data  = p.Results.TruthData;
% check time formats for default values
if isdatetime(time)
    if isempty(time_two)
        time_two = NaT(0);
    end
    if isempty(truth_time)
        truth_time = NaT(0);
    end
end

%% Process inputs
if isempty(names)
    names = arrayfun(@(x) ['Channel: ',int2str(x)], 1:size(data,1), 'UniformOutput', false);
end
if ~iscell(truth_name)
    truth_name = {truth_name};
end
if isempty(p.Results.OPTS)
    OPTS = Opts();
else
    OPTS = p.Results.OPTS;
end

%% determine units based on type of data
[scale, units] = get_scale_and_units(type);

%% Process for comparisons and alias OPTS information
% alias OPTS information
show_plot   = OPTS.show_plot;
sub_plots   = OPTS.sub_plots;
single_line = OPTS.sing_line;
show_rms    = OPTS.show_rms;
use_mean    = OPTS.use_mean;
show_zero   = OPTS.show_zero;
time_units  = OPTS.time_base;
rms_xmin    = OPTS.rms_xmin;
rms_xmax    = OPTS.rms_xmax;
disp_xmin   = OPTS.disp_xmin;
disp_xmax   = OPTS.disp_xmax;
show_extra  = OPTS.show_xtra;
start_date  = get_start_date(OPTS.date_zero);
if ~isempty(OPTS.colormap)
    if isnumeric(OPTS.colormap)
        colors1 = OPTS.colormap;
    else
        colors1 = feval(OPTS.colormap);
    end
else
    colors1 = tab10();
end
colors2     = whitten(colors1);

%% Potentially convert times to dates
if strcmp(OPTS.time_unit, 'datetime')
    date_zero  = OPTS.date_zero;
    time       = convert_time_to_date(time,       date_zero, time_units);
    time_two   = convert_time_to_date(time_two,   date_zero, time_units);
    truth_time = convert_time_to_date(truth_time, date_zero, time_units);
    disp_xmin  = convert_time_to_date(disp_xmin,  date_zero, time_units);
    disp_xmax  = convert_time_to_date(disp_xmax,  date_zero, time_units);
    rms_xmin   = convert_time_to_date(rms_xmin,   date_zero, time_units);
    rms_xmax   = convert_time_to_date(rms_xmax,   date_zero, time_units);
end

%% Plot data
% calls lower level function
num_labels      = length(names);
rows            = modd(1:num_labels, size(colors1, 1));
this_colororder = [colors1(rows,:); colors2(rows,:); colors1(rows,:)];
fig_hand = general_difference_plot(description, time, time_two, scale*data, scale*data_two, ...
    'Elements', names, 'Units', units, 'TimeUnits', time_units, 'LegendScale', 'unity', 'StartDate', start_date, ...
    'RmsXmin', rms_xmin, 'RmsXmax', rms_xmax, 'DispXmin', disp_xmin, 'DispXmax', disp_xmax, ...
    'FigVisible', show_plot, 'MakeSubplots', sub_plots, 'SingleLines', single_line, 'ColorOrder', this_colororder, ...
    'UseMean', use_mean, 'PlotZero', show_zero, 'ShowRms', show_rms, 'ShowExtra', show_extra, ...
    'SecondYScale', second_y_scale, ...
    'TruthName', truth_name, 'TruthTime', truth_time, 'TruthData', scale*truth_data);

% create figure controls
figmenu;

% setup plots
setup_plots(fig_hand, OPTS, 'time');