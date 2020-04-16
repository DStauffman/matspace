function [fig_hand] = plot_monte_carlo(time_one, data_one, varargin)

% PLOT_MONTE_CARLO  acts as a convenient wrapper to plotting a time history of some data.
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
%         'TruthName'   : (string 1xD) name for truth data channel on the legend, if empty
%                              don't include, default is "Truth"
%         'SecondYScale' : (scalar) Multiplication scale factor to use to display on a secondary Y axis
%
% Output:
%     fig_hand .. : (scalar) figure handles [num]
%
% Prototype:
%     time     = 1:10;
%     data     = rand(5,length(time));
%     fig_hand = matspace.plotting.plot_monte_carlo(time, data, [], 'Description', 'Random Data');
%
%     % clean up
%     close(fig_hand);
%
% See Also:
%     matspace.plotting.figmenu, matspace.plotting.setup_dir, matspace.plotting.plot_rms_lines
%
% Change Log:
%     1.  Written by David C. Stauffer in May 2016.
%     2.  Updated by David C. Stauffer in Aug 2016 to include optional Truth name and enable/disable
%         the RMS calculations.
%     3.  Updated by David C. Stauffer in Sep 2016 to use the built-in MATLAB inputParser.
%     4.  Updated by David C. Stauffer in Jan 2018 to better set legends and use string arrays for names.
%     5.  Updated by David C. Stauffer in April 2020 to put into a package.

%% Imports
import matspace.plotting.convert_time_to_date
import matspace.plotting.figmenu
import matspace.plotting.get_scale_and_units
import matspace.plotting.get_start_date
import matspace.plotting.Opts
import matspace.plotting.plot_rms_lines
import matspace.plotting.plot_second_yunits
import matspace.plotting.setup_plots
import matspace.utils.nanmean
import matspace.utils.nanrms

%% hard-coded values
std_flag      = 1;
data_dim      = 1;
leg_format    = '%3.3f';
colors        = [0 0 1; 0 0.8 0; 1 0 0; 0 0.8 0.8; 0.8 0 0.8; 0.8 0.8 0; 0 1 1; 1 0 1; ...
    1 0.8 0; 0.375 0.375 0.5];
truth_color   = [0 0 0];
truth_color2  = [0.4 0.4 0.4];
modes         = struct('single', 1, 'nondeg', 2, 'multi', 3);
leg_rms_lines = false;

%% Parse Inputs
% create parser
p = inputParser;
% create some validation functions
fun_is_opts = @(x) isa(x, 'matspace.plotting.Opts') || isempty(x);
fun_is_time = @(x) (isnumeric(x) || isdatetime(x)) && (isempty(x) || isvector(x));
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
addParameter(p, 'TruthName', "Truth", @isstring);
addParameter(p, 'SecondYScale', nan, @isnumeric);
addParameter(p, 'PlotSigmas', 1, @isnumeric);
% do parse
parse(p, time_one, data_one, varargin{:});
% create some convenient aliases
type           = p.Results.Type;
description    = p.Results.Description;
truth_name     = p.Results.TruthName;
second_y_scale = p.Results.SecondYScale;
plot_sigmas    = p.Results.PlotSigmas;
% create data channel aliases
time_two    = p.Results.Time2;
data_two    = p.Results.Data2;
truth_time  = p.Results.TruthTime;
truth_data  = p.Results.TruthData;

%% Process OPTS
if isempty(p.Results.OPTS)
    OPTS = Opts();
else
    OPTS = p.Results.OPTS;
end

%% determine units based on type of data
[scale, units] = get_scale_and_units(type);
time_units = OPTS.time_base;

%% Process for comparisons and alias OPTS information
% check for multiple comparisons mode and alias some OPTS information
names = OPTS.names;
if length(names) > 1
    if length(names) == 2
        comp_mode = modes.nondeg;
        assert(~isempty(data_one) && ~isempty(data_two));
    else
        comp_mode = modes.multi;
        assert(size(data_one, 1) == length(names), 'Badly sized data.');
    end
else
    comp_mode = modes.single;
end
% determine if creating a difference plot and/or using subplots
use_sub_plots = OPTS.sub_plots && comp_mode == modes.nondeg;
show_rms      = OPTS.show_rms;
name1         = '';
name2         = '';
if length(names) >= 1 && ~isempty(names{1})
    name1 = [names{1}, ': '];
end
if length(names) >= 2 && ~isempty(names{2})
    name2 = [names{2}, ': '];
end
rms_xmin    = OPTS.rms_xmin;
rms_xmax    = OPTS.rms_xmax;
disp_xmin   = OPTS.disp_xmin;
disp_xmax   = OPTS.disp_xmax;
start_date  = get_start_date(OPTS.date_zero);

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

%% calculate RMS indices
if show_rms
    ix_rms_xmin1 = finde(time_one >= rms_xmin,1,'first');
    ix_rms_xmax1 = finde(time_one <= rms_xmax,1,'last');
    ix_rms_xmin2 = finde(time_two >= rms_xmin,1,'first');
    ix_rms_xmax2 = finde(time_two <= rms_xmax,1,'last');
end

%% process non-deg data before trying to create any plots
if comp_mode == modes.nondeg
    [nondeg_time,ix1,ix2]  = intersect(time_one, time_two);
    nondeg_data            = mean(data_two(:,ix2),1) - mean(data_one(:,ix1),1);
    ix_rms_xmin_nondeg     = finde(nondeg_time >= rms_xmin,1,'first');
    ix_rms_xmax_nondeg     = finde(nondeg_time <= rms_xmax,1,'last');
    nondeg_rms             = scale*nanrms(nondeg_data(:,ix_rms_xmin_nondeg:ix_rms_xmax_nondeg));
    if use_sub_plots
        fig_hand           = gobjects(1);
    else
        fig_hand           = gobjects(1, 2);
    end
else
    fig_hand               = gobjects(1);
end

%% Plot data
% determine if using datetimes
use_datetime = isdatetime(time_one) || isdatetime(time_two) || isdatetime(truth_time);
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
if comp_mode ~= modes.multi
    % if only one cycle, then just plot it
    if size(data_one, data_dim) == 1
        % calculate RMS for legend
        if show_rms
            rms_data1 = scale*nanrms(data_one(:,ix_rms_xmin1:ix_rms_xmax1));
            this_name = [name1,'Mean (RMS: ',num2str(rms_data1,leg_format),')'];
        else
            this_name = [name1,'Mean'];
        end
        % plot data
        plot(ax1, time_one, scale*data_one, 'b.-', 'DisplayName', this_name);
    else
        % plot different cycles
        p1 = plot(ax1, time_one, scale*data_one, '-', 'Color', [0.7 0.7 0.8]);
        indiv_group = hggroup('DisplayName', [name1, 'Individual Runs']);
        set(p1, 'Parent', indiv_group);
        set(get(get(indiv_group, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'on');
        % create the mean result
        temp_mean = scale*mean(data_one, data_dim, 'omitnan');
        % plot the sigmas
        if ~isnan(plot_sigmas) && plot_sigmas > 0
            temp_std = std(data_one, std_flag, data_dim, 'omitnan');
            p2 = plot(ax1, time_one, temp_mean + scale*temp_std, 'c.-');
            p3 = plot(ax1, time_one, temp_mean - scale*temp_std, 'c.-');
            sigmas_group = hggroup('DisplayName', [name1, '\pm', num2str(plot_sigmas), '\sigma']);
            set([p2 p3], 'Parent', sigmas_group);
            set(get(get(sigmas_group,'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'on');
        end
        % plot the mean results
        if show_rms
            rms_data1 = nanrms(temp_mean);
            this_name = [name1,'Mean (RMS: ',num2str(rms_data1,leg_format),')'];
        else
            this_name = [name1,'Mean'];
        end
        plot(ax1, time_one, temp_mean, 'b.-', 'LineWidth', 2, 'DisplayName', this_name);
    end
else
    % In multi-mode, calculate RMS if necessary
    if show_rms
        rms_data1 = nanrms(scale*data_one, 2);
    end
    % plot all the channels
    p1 = plot(ax1, time_one, scale*data_one, '.-');
    for i = 1:length(p1)
        if show_rms
            set(p1(i), 'DisplayName', [names{i}, ' (RMS: ', num2str(rms_data1(i))]);
        else
            set(p1(i), 'DisplayName', names{i});
        end
    end
end
% plot second channel
if comp_mode == modes.nondeg
    if size(data_two, data_dim) == 1
        if show_rms
            rms_data2 = scale*nanrms(data_two(:,ix_rms_xmin2:ix_rms_xmax2));
            this_name = [name2,'Mean (RMS: ',num2str(rms_data2,leg_format),')'];
        else
            this_name = [name2,'Mean'];
        end
        plot(ax1, time_two, scale*data_two, '.-', 'Color', [0 0.8 0], 'DisplayName', this_name);
    else
        p1 = plot(ax1, time_two, scale*data_two, '-', 'Color', [0.7 0.8 0.7]);
        indiv_group = hggroup('DisplayName', [name2, 'Individual Runs']);
        set(p1, 'Parent', indiv_group);
        set(get(get(indiv_group, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'on');
        temp_mean = scale*mean(data_two, data_dim, 'omitnan');
        if ~isnan(plot_sigmas) && plot_sigmas > 0
            temp_std = std(data_two, std_flag, data_dim, 'omitnan');
            p2 = plot(ax1, time_two, temp_mean + scale*temp_std, 'g.-');
            p3 = plot(ax1, time_two, temp_mean - scale*temp_std, 'g.-');
            sigmas_group = hggroup('DisplayName', [name2, '\pm', num2str(plot_sigmas), '\sigma']);
            set([p2 p3], 'Parent', sigmas_group);
            set(get(get(sigmas_group, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'on');
        end
        if show_rms
            rms_data2 = nanrms(temp_mean);
            this_name = [name2,'Mean (RMS: ',num2str(rms_data2,leg_format),')'];
        else
            this_name = [name2,'Mean'];
        end
        plot(ax1, time_two, temp_mean, '.-', 'Color', [0 0.8 0], 'LineWidth', 2, 'DisplayName', this_name);
    end
end

% label plot
title(get(fig_hand(1), 'name'), 'interpreter', 'none');
if use_datetime
    xlabel('Time');
else
    xlabel(['Time [',time_units,']',start_date]);
end
ylabel([description,' [',units,']']);

% set display limits
xl = xlim;
if isfinite(disp_xmin)
    xl(1) = max([xl(1), disp_xmin]);
end
if isfinite(disp_xmax)
    xl(2) = min([xl(2), disp_xmax]);
end
xlim(xl);

% optionally plot truth
if ~isempty(truth_time) && ~isempty(truth_data) && ~all(all(isnan(truth_data)))
    p4 = plot(truth_time, scale*truth_data, '.-', 'Color', truth_color, 'MarkerFaceColor', ...
        truth_color, 'LineWidth', 2);
    if length(truth_name) > 1
        for i = 1:length(p4)
            set(p4(i), 'DisplayName', truth_name{i});
        end
    else
        truth_group = hggroup('DisplayName', truth_name{1});
        set(p4, 'Parent', truth_group);
        set(get(get(truth_group,'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
        for i = 2:length(p4)
            set(p4(i), 'Color', truth_color2);
        end
    end
end

% plot RMS lines
if show_rms
    plot_rms_lines(ax1, time_one([ix_rms_xmin1 ix_rms_xmax1]), ylim, leg_rms_lines);
end

% turn on grid/legend
grid on;
lg = legend('show');
set(lg, 'Location', 'best');

% create second Y axis
if ~isnan(second_y_scale) && second_y_scale ~= 0
    if strcmp(type, 'population')
        new_y_label = 'Actual Population [#]';
    else
        new_y_label = '';
    end
    plot_second_yunits(ax1, new_y_label, second_y_scale);
end

% create differences plot
if comp_mode == modes.nondeg
    title_name = [description,' Differences vs. Time'];
    if use_sub_plots
        ax2 = subplot(2, 1, 2);
        hold on;
        title(title_name, 'interpreter', 'none');
    else
        fig_hand(2) = figure('name', title_name);
        ax2 = axes;
        hold on;
        title(title_name, 'interpreter', 'none');
    end
    p5 = plot(ax2, nondeg_time, scale*nondeg_data, 'r.-');

    % label plot
    title(get(fig_hand(1), 'name'), 'interpreter', 'none');
    if use_datetime
        xlabel('Time');
    else
        xlabel(['Time [',time_units,']',start_date]);
    end
    ylabel([description,' [',units,']']);

    % turn on grid/legend
    if show_rms
        lg = legend(p5, [description,' Difference (RMS: ',num2str(nondeg_rms,leg_format),')']);
    else
        lg = legend(p5, description);
    end
    set(lg, 'Location', 'best');
    grid on;

    % plot RMS lines
    if show_rms
        plot_rms_lines(ax2, time_one([ix_rms_xmin1 ix_rms_xmax1]), ylim, leg_rms_lines);
    end

    % Second Y axis
    if ~use_sub_plots && ~isnan(second_y_scale) && second_y_scale ~= 0
        if strcmp(type, 'population')
            new_y_label = 'Actual Population [#]';
        else
            new_y_label = '';
        end
        plot_second_yunits(ax2, new_y_label, second_y_scale);
    end

    % link to earlier plot
    linkaxes([ax1 ax2],'x');
end

% create figure controls
figmenu;

% setup plots
setup_plots(fig_hand, OPTS, 'time');


%% Subfunctions
function [ix] = finde(x, n, direction)

% FINDE  calls the built-in find function, but always returns a value when find would otherwise be
%        empty.  This value is the first or last element of the array depending on the given
%        direction.

ix = find(x, n, direction);

if isempty(ix)
    switch direction
        case 'first'
            ix = 1;
        case 'last'
            ix = length(x);
        otherwise
            % Should be impossible to get here, as it should have errored in the find function call
            error('matspace:UnexpectedDirection', 'Unexpected direction for find function: "%s"', direction);
    end
end