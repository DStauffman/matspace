function [fig_hand] = plot_multiline_history(time, data, varargin)

% PLOT_MULTILINE_HISTORY  plots multiple metrics over time.
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
%     fig_hand = plot_multiline_history(time, data, [], 'Description', 'Random Data');
%
%     % clean up
%     close(fig_hand);
%
% See Also:
%     figmenu, setup_dir, plot_rms_lines
%
% Change Log:
%     1.  Written by David C. Stauffer in September 2017.

%% hard-coded values
leg_format  = '%3.3f';
colors      = [0 0 1; 0 0.8 0; 1 0 0; 0 0.8 0.8; 0.8 0 0.8; 0.8 0.8 0; 0 1 1; 1 0 1; ...
    1 0.8 0; 0.375 0.375 0.5];
truth_color = [0 0 0];

%% Parse Inputs
% create parser
p = inputParser;
% create some validation functions
fun_is_opts = @(x) isa(x, 'Opts') || isempty(x);
fun_is_time = @(x) isnumeric(x) && (isempty(x) || isvector(x));
fun_is_cell_char = @(x) iscell(x) && all(cellfun(@ischar, x));
fun_is_num_or_cell = @(x) isnumeric(x) || iscell(x);
% set options
addRequired(p, 'Time', fun_is_time);
addRequired(p, 'Data', @isnumeric);
addOptional(p, 'OPTS', Opts, fun_is_opts);
addParameter(p, 'Description', '', @ischar);
addParameter(p, 'Type', 'unity', @ischar);
addParameter(p, 'Names', {}, fun_is_cell_char);
addParameter(p, 'TruthTime', [], fun_is_time);
addParameter(p, 'TruthData', [], @isnumeric);
addParameter(p, 'TruthName', 'Truth', @ischar);
addParameter(p, 'SecondYScale', nan, fun_is_num_or_cell);
% do parse
parse(p, time, data, varargin{:});
% create some convenient aliases
type        = p.Results.Type;
description = p.Results.Description;
names       = p.Results.Names;
truth_name  = p.Results.TruthName;
second_y_scale = p.Results.SecondYScale;
% create data channel aliases
truth_time  = p.Results.TruthTime;
truth_data  = p.Results.TruthData;

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
show_rms   = OPTS.show_rms;
time_units = OPTS.time_base;
rms_xmin   = OPTS.rms_xmin;
rms_xmax   = OPTS.rms_xmax;
disp_xmin  = OPTS.disp_xmin;
disp_xmax  = OPTS.disp_xmax;

%% calculate RMS indices
if show_rms
    ix_rms_xmin = find(time >= rms_xmin,1,'first');
    if isempty(ix_rms_xmin)
        ix_rms_xmin = 1;
    end
    ix_rms_xmax = find(time <= rms_xmax,1,'last');
    if isempty(ix_rms_xmax)
        ix_rms_xmax = length(time1);
    end
end

%% Plot data
% create figure
fig_hand = figure('name', [description,' vs. Time']);

% set colororder
set(fig_hand(1), 'DefaultAxesColorOrder', colors);

% get axes
ax = axes;

% set hold on
hold on;

% plot data
h1 = plot(ax, time, scale*data, '.-');
% calculate RMS for legend
if show_rms
    rms_data = scale*nanrms(data(:,ix_rms_xmin:ix_rms_xmax), 2);
end

% label plot
title(get(fig_hand, 'name'), 'interpreter', 'none');
xlabel(['Time [',time_units,']']);
ylabel([description,' [',units,']']);

% set display limits
xl = xlim;
if isfinite(disp_xmin)
    xl(1) = max([xl(1), OP.disp_xmin]);
end
if isfinite(disp_xmax)
    xl(2) = min([xl(2), disp_xmax]);
end
xlim(xl);

% optionally plot truth
if ~isempty(truth_time) && ~isempty(truth_data) && ~all(all(isnan(truth_data)))
    h2 = plot(truth_time, scale*truth_data, '.-', 'Color', truth_color, 'MarkerFaceColor', ...
        truth_color, 'LineWidth', 2);
else
    h2 = [];
end

% turn on grid/legend
grid on;
plot_handles = [h1(:); h2(:)]';
if show_rms
    legend_names = cellfun(@(x,y) [x,' (RMS: ',num2str(y,leg_format),')'], names,...
        num2cell(rms_data(:)'),'UniformOutput',false);
else
    legend_names = names;
end
if ~isempty(h2)
    legend_names = [legend_names, truth_name];
end
legend(plot_handles, legend_names, 'interpreter', 'none');

% create second Y axis
if iscell(second_y_scale)
    plot_second_yunits(ax, second_y_scale{1}, second_y_scale{2});
elseif ~isnan(second_y_scale) && second_y_scale ~= 0
    if strcmp(type, 'population')
        new_y_label = 'Actual Population [#]';
    else
        new_y_label = '';
    end
    plot_second_yunits(ax, new_y_label, second_y_scale);
end

% plot RMS lines
if show_rms
    plot_rms_lines(time([ix_rms_xmin ix_rms_xmax]), ylim);
end

% create figure controls
figmenu;

% setup plots
setup_plots(fig_hand, OPTS, 'time');