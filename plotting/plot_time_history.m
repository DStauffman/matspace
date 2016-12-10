function [fig_hand] = plot_time_history(time1, data1, varargin)

% PLOT_TIME_HISTORY  acts as a convenient wrapper to plotting a time history of some data.
%
% Summary:
%     This function can take in one or two time histories, with an optional description and unit
%     type associated with them.  If given two histories, it will find the overlapping points and
%     plot a difference between them.
%
% Input:
%     time1 ..... : (1xN) time points [years]
%     data1 ..... : (MxN) data points [num]
%     OPTS ...... : (class) optional plotting commands, see Opts.m for more information
%     varargin .. : (char, value) pairs for other options, from:
%         'Time2'       : (1xA) time points for series two, default is empty
%         'Data2'       : (BxA) data points for series two, default is empty
%         'Description' : (char) text to put on the plot titles, default is empty string
%         'Type'        : (char) type of data to use when converting axis scale, default is 'unity'
%         'TruthTime'   : (1xC) time points for truth data, default is empty
%         'TruthData'   : (DxC) data points for truth data, default is empty
%         'TruthName'   : (char) or {Dx1} of (char) name for truth data on the legend, if empty
%                              don't include, default is 'Truth'
%         'ShowRMS'     : (bool) flag for showing RMS on plot and in legend, default is true
%
% Output:
%     fig_hand .. : (scalar) figure handles [num]
%
% Prototype:
%     time     = 1:10;
%     data     = rand(5,length(time));
%     fig_hand = plot_time_history(time, data, [], 'Description', 'Random Data');
%
%     % clean up
%     close(fig_hand);
%
% See Also:
%     figmenu, setup_dir, plot_rms_lines
%
% Notes:
%     1.  If OPTS.name_one is a cell array, then you can name all the individual channels in data1, 
%         and similarily for OPTS.name_two and data2.  Likewise, if TruthName is a cell array, you
%         can name multiple truth channels for the rows in TruthData.
%
% Change Log:
%     1.  Written by David C. Stauffer in May 2016.
%     2.  Updated by David C. Stauffer in Aug 2016 to include optional Truth name and enable/disable
%         the RMS calculations.
%     3.  Updated by David C. Stauffer in Sep 2016 to use the built-in MATLAB inputParser.

%% hard-coded values
std_flag    = 1;
data_dim    = 1;
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
% set options
addRequired(p, 'Time1', fun_is_time);
addRequired(p, 'Data1', @isnumeric);
addOptional(p, 'OPTS', Opts, fun_is_opts);
addParameter(p, 'Time2', [], fun_is_time);
addParameter(p, 'Data2', [], @isnumeric);
addParameter(p, 'Description', '', @ischar);
addParameter(p, 'Type', 'unity', @ischar);
addParameter(p, 'TruthTime', [], fun_is_time);
addParameter(p, 'TruthData', [], @isnumeric);
addParameter(p, 'TruthName', 'Truth', @ischar);
addParameter(p, 'ShowRms', true, @islogical);
% do parse
parse(p, time1, data1, varargin{:});
% create some convenient aliases
type        = p.Results.Type;
description = p.Results.Description;
truth_name  = p.Results.TruthName;
show_rms    = p.Results.ShowRms;
% create data channel aliases
time2       = p.Results.Time2;
data2       = p.Results.Data2;
truth_time  = p.Results.TruthTime;
truth_data  = p.Results.TruthData;

%% Process inputs
if ~iscell(truth_name)
    truth_name = {truth_name};
end
if isempty(p.Results.OPTS)
    OPTS = Opts();
else
    OPTS = p.Results.OPTS;
end

%% determine units based on type of data
% TODO: functionalize this?
switch type
    case 'unity'
        scale = 1;
        units = '';
    case 'population'
        scale = 1;
        units = '#';
    case 'percentage'
        scale = 100;
        units = '%';
    case 'per 100K'
        scale = 100000;
        units = 'per 100,000';
    case 'cost'
        scale = 1e-3;
        units = '$K''s';
    otherwise
        error('hesat:badPlottingType', 'Unknown data type for plot: "%s".', type);
end

%% Process for comparisons and alias OPTS information
% check for multiple comparisons mode and alias some OPTS information
name1 = OPTS.name_one;
name2 = OPTS.name_two;
if iscell(OPTS.name_one)
    mult_comp_mode = true;
else
    mult_comp_mode = false;
    if ~isempty(name1)
        name1 = [name1,': '];
    end
    if ~isempty(name2)
        name2 = [name2,': '];
    end
end
% determine if creating a difference plot and/or using subplots
non_deg       = ~isempty(data1) && ~isempty(data2);
use_sub_plots = OPTS.sub_plots && non_deg;

%% calculate RMS indices
if show_rms
    ix_rms_xmin1 = find(time1 >= OPTS.rms_xmin,1,'first');
    if isempty(ix_rms_xmin1)
        ix_rms_xmin1 = 1;
    end
    ix_rms_xmax1 = find(time1 <= OPTS.rms_xmax,1,'last');
    if isempty(ix_rms_xmax1)
        ix_rms_xmax1 = length(time1);
    end
    ix_rms_xmin2 = find(time2 >= OPTS.rms_xmin,1,'first');
    if isempty(ix_rms_xmin2)
        ix_rms_xmin2 = 1;
    end
    ix_rms_xmax2 = find(time2 <= OPTS.rms_xmax,1,'last');
    if isempty(ix_rms_xmax2)
        ix_rms_xmax2 = length(time2);
    end
end

%% process non-deg data before trying to create any plots
if non_deg
    [nondeg_time,ix1,ix2]  = intersect(time1,time2);
    nondeg_data            = mean(data2(:,ix2),1) - mean(data1(:,ix1),1);
    ix_rms_xmin_nondeg     = find(nondeg_time >= OPTS.rms_xmin,1,'first');
    if isempty(ix_rms_xmin_nondeg)
        ix_rms_xmin_nondeg = 1;
    end
    ix_rms_xmax_nondeg     = find(nondeg_time <= OPTS.rms_xmax,1,'last');
    if isempty(ix_rms_xmax_nondeg)
        ix_rms_xmax_nondeg = length(nondeg_time);
    end
    nondeg_rms             = scale*rms(nondeg_data(:,ix_rms_xmin_nondeg:ix_rms_xmax_nondeg));
    if use_sub_plots
        fig_hand           = 0;
    else
        fig_hand           = [0 0];
    end
else
    fig_hand               = 0;
end

%% Plot data
% create figure
fig_hand(1) = figure('name', [description,' vs. Time']);

% set colororder
set(fig_hand(1), 'DefaultAxesColorOrder', colors);

% get axes
if use_sub_plots
    ax1 = subplot(2, 1, 1);
else
    ax1 = axes;
end

% set hold on
hold on;

% plot data
if size(data1, data_dim) == 1
    % plot data
    h1        = plot(ax1, time1, scale*data1, 'b.-');
    % calculate RMS for legend
    if show_rms
        rms_data1 = scale*rms(data1(:,ix_rms_xmin1:ix_rms_xmax1));
    end
else
    if ~mult_comp_mode
        % plot different cycles
        plot(ax1, time1, scale*data1, '-', 'Color', [0.7 0.7 0.7]);
        % plot the error bars
        temp      = scale*mean(data1, data_dim);
        errorbar(ax1, time1, temp, scale*std(data1, std_flag, data_dim), 'c.-');
        % plot the mean results
        h1        = plot(ax1, time1, temp, 'b.-', 'LineWidth', 2);
        % calculate RMS for legend
        if show_rms
            rms_data1 = rms(temp);
        end
    else
        h1        = plot(ax1, time1, scale*data1, '.-');
        % calculate RMS for legend
        if show_rms
            rms_data1 = rms(scale*data1, 2);
        end
    end
end
% plot second channel
if size(data2, data_dim) == 1
    h2        = plot(ax1, time2, scale*data2, '.-', 'Color', [0 0.8 0]);
    if show_rms
        rms_data2 = scale*rms(data2(:,ix_rms_xmin2:ix_rms_xmax2));
    end
else
    plot(ax1, time2, scale*data2, '-', 'Color', [0.7 0.7 0.7]);
    temp      = scale*mean(data2, data_dim);
    errorbar(time2, temp, scale*std(data2, std_flag, data_dim), 'g.-');
    h2        = plot(ax1, time2, temp, '.-', 'Color', [0 0.8 0], 'LineWidth', 2);
    if show_rms
        rms_data2 = rms(temp);
    end
end

% label plot
title(get(fig_hand(1), 'name'));
xlabel('Time [year]');
ylabel([description,' [',units,']']);

% set display limits
xl = xlim;
if isfinite(OPTS.disp_xmin)
    xl(1) = max([xl(1), OPTS.disp_xmin]);
end
if isfinite(OPTS.disp_xmax)
    xl(2) = min([xl(2), OPTS.disp_xmax]);
end
xlim(xl);

% optionally plot truth for HIV prevalence
if ~isempty(truth_time) && ~isempty(truth_data) && ~all(all(isnan(truth_data)))
    h3 = plot(truth_time, scale*truth_data, '.-', 'Color', truth_color, 'MarkerFaceColor', ...
        truth_color, 'LineWidth', 2);
else
    h3 = [];
end

% turn on grid/legend
grid on;
if ~mult_comp_mode
    plot_handles = [h1(:); h2(:); h3(:)]';
    if show_rms
        legend_names = [{[name1,description,' (RMS: ',num2str(rms_data1,leg_format),')'],...
            [name2,description,' (RMS: ',num2str(rms_data2,leg_format),')']},truth_name];
    else
        legend_names = [{[name1,description], [name2,description]}, truth_name];
    end
    used_ix = logical([ones(1,length(h1)), zeros(1, isempty(h1)), ones(1,length(h2)), ...
        zeros(1, isempty(h2)), ones(1, min(length(h3), length(truth_name))), zeros(1, isempty(h3))]);
else
    plot_handles = [h1(:); h3(:)]';
    used_ix = logical([ones(1,length(h1)), zeros(1, isempty(h1)), ones(1, min(length(h3), ...
        length(truth_name))), zeros(1, isempty(h3))]);
    if show_rms
        legend_names = [cellfun(@(x,y) [x,' (RMS: ',num2str(y,leg_format),')'], OPTS.name_one,...
            num2cell(rms_data1(:)'),'UniformOutput',false), truth_name];
    else
        legend_names = [OPTS.name_one, truth_name];
    end
end
legend(plot_handles, legend_names(used_ix), 'interpreter', 'none');

% plot RMS lines
if show_rms
    plot_rms_lines(time1([ix_rms_xmin1 ix_rms_xmax1]), ylim);
end

% create differences plot
if non_deg
    title_name = [description,' Differences vs. Time'];
    if use_sub_plots
        ax2 = subplot(2, 1, 2);
        hold on;
        title(title_name);
    else
        fig_hand(2) = figure('name', title_name);
        ax2 = axes;
        hold on;
        title(title_name);
    end
    h3 = plot(ax2, nondeg_time, scale*nondeg_data, 'r.-');

    % label plot
    xlabel('Time [year]');
    ylabel([description,' [',units,']']);

    % turn on grid/legend
    if show_rms
        legend(h3, [description,' Difference (RMS: ',num2str(nondeg_rms,leg_format),')']);
    else
        legend(h3, description);
    end
    grid on;

    % plot RMS lines
    if show_rms
        plot_rms_lines(time1([ix_rms_xmin1 ix_rms_xmax1]), ylim);
    end

    % link to earlier plot
    linkaxes([ax1 ax2],'x');
end

% create figure controls
figmenu;

% setup plots
setup_plots(fig_hand, OPTS, 'time');