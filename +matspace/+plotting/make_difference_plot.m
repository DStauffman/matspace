function [fig_hand, err] = make_difference_plot(description, time_one, data_one, time_two, data_two, varargin)

% Generic difference comparison plot for use in other wrapper functions.
% 
% Plots two vector histories over time, along with a difference from one another.
% 
% Output:
%     fig_hand .. : (1xN) figure handles [num]
%     err ....... : (struct) Differences
% 
% Change Log:
%     1.  Written by David C. Stauffer in MATLAB in October 2011, updated in 2018.
%     2.  Ported to Python by David C. Stauffer in March 2019.
%     3.  Made fully functional by David C. Stauffer in April 2020.
%     4.  Wrapped to the generic do everything version by David C. Stauffer in March 2021.
% 
% Prototype:
%     description      = 'example';
%     time_one         = 0:10;
%     data_one         = 50e-6 * rand(2, 11);
%     time_two         = 2:12;
%     data_two         = data_one[:, [3, 4, 5, 6, 7, 8, 9, 10, 11, 1, 2]] - 1e-6 * rand(2, 11);
%     name_one         = 'test1';
%     name_two         = 'test2';
%     elements         = ["x", "y"];
%     units            = 'rad';
%     time_units       = 'sec';
%     start_date       = [', t0 = ',char(datetime('now'))];
%     rms_xmin         = 1;
%     rms_xmax         = 10;
%     disp_xmin        = -2;
%     disp_xmax        = inf;
%     make_subplots    = true;
%     single_lines     = false;
%     color_map        = get_nondeg_colorlists(2);
%     use_mean         = false;
%     plot_zero        = false;
%     show_rms         = true;
%     legend_loc       = 'best';
%     show_extra       = true;
%     second_units     = {'µrad', 1e6};
%     legend_scale     = [];
%     y_label          = '';
%     data_as_rows     = true;
%     tolerance        = 0;
%     use_zoh          = false;
%     label_vert_lines = true;
%     extra_plotter    = [];
%     use_datashader   = false;
%     fig_ax           = [];
%     diff_type        = 'comp';
%     fig_hand = make_difference_plot(description, time_one, data_one, time_two, data_two, ...
%         NameOne=name_one, NameTwo=name_two, Elements=elements, Units=units, ...
%         StartDate=start_date, RmsXmin=rms_xmin, RmsXmax=rms_xmax, DispXmin=disp_xmin, ...
%         TimeUnits=time_units, DispXmax=disp_xmax, MakeSubplots=make_subplots, ...
%         SingleLines=single_lines, ColorMap=color_map, UseMean=use_mean, PlotZero=plot_zero, ...
%         ShowRms=show_rms, LegendLoc=legend_loc, ShowExtra=show_extra, ...
%         SecondUnits=second_units, LegendScale=legend_scale, YLabel=y_label, DataAsRows=data_as_rows, ...
%         Tolerance=tolerance, UseZoh=use_zoh, ...
%         LabelVertLines=label_vert_lines, ExtraPlotter=extra_plotter, ...
%         UseDatashader=use_datashader, FigAx=fig_ax, DiffType=diff_type);
% 
%     % Close plots
%     close(fig_hand);

%% Imports
import matspace.plotting.ignore_plot_data
import matspace.plotting.plot_second_units_wrapper
import matspace.plotting.private.build_diff_indices
import matspace.plotting.private.build_indices
import matspace.plotting.private.calc_rms
import matspace.plotting.private.create_figure
import matspace.plotting.private.draw_lines
import matspace.plotting.private.fun_is_2nd_units
import matspace.plotting.private.fun_is_bool
import matspace.plotting.private.fun_is_bound
import matspace.plotting.private.fun_is_colormap
import matspace.plotting.private.fun_is_data
import matspace.plotting.private.fun_is_dt
import matspace.plotting.private.fun_is_extra_plotter
import matspace.plotting.private.fun_is_fig_ax
import matspace.plotting.private.fun_is_log_level
import matspace.plotting.private.fun_is_quat
import matspace.plotting.private.fun_is_text
import matspace.plotting.private.fun_is_time
import matspace.plotting.private.get_units
import matspace.plotting.private.get_ylabels
import matspace.plotting.private.label_x
import matspace.plotting.private.make_time_and_data_lists
import matspace.plotting.private.plot_linear
import matspace.plotting.private.plot_zoh
import matspace.plotting.plot_vert_lines
import matspace.plotting.show_zero_ylim
import matspace.plotting.zoom_ylim
import matspace.quaternions.quat_angle_diff
import matspace.stats.intersect2
import matspace.utils.ifelse

%% Hard-coded values
LEG_FORMAT  = '%1.3f';

%% Parser
% Argument parser
p = inputParser;
addRequired(p, 'Description', @fun_is_text);
addRequired(p, 'TimeOne', @fun_is_time);
addRequired(p, 'DataOne', @fun_is_data);
addRequired(p, 'TimeTwo', @fun_is_time);
addRequired(p, 'DataTwo', @fun_is_data);
addParameter(p, 'NameOne', '', @fun_is_text);
addParameter(p, 'NameTwo', '', @fun_is_text);
addParameter(p, 'Elements', strings(0), @isstring);
addParameter(p, 'Units', '', @fun_is_text);
addParameter(p, 'TimeUnits', 'sec', @fun_is_text);
addParameter(p, 'StartDate', '', @fun_is_text);
addParameter(p, 'RmsXmin', -inf, @fun_is_bound);
addParameter(p, 'RmsXmax', inf, @fun_is_bound);
addParameter(p, 'DispXmin', -inf, @fun_is_bound);
addParameter(p, 'DispXmax', inf, @fun_is_bound);
addParameter(p, 'MakeSubplots', true, @fun_is_bool);
addParameter(p, 'SingleLines', false, @(x) islogical(x) & isvector(x));  % Can be more than one boolean
addParameter(p, 'FigVisible', true, @fun_is_bool);
addParameter(p, 'ColorMap', parula(8), @fun_is_colormap);
addParameter(p, 'UseMean', false, @fun_is_bool);
addParameter(p, 'PlotZero', false, @fun_is_bool);
addParameter(p, 'ShowRms', true, @fun_is_bool);
addParameter(p, 'LegendLoc', 'Best', @fun_is_text);
addParameter(p, 'ShowExtra', true, @fun_is_bool);
addParameter(p, 'SecondUnits', nan, @fun_is_2nd_units);
addParameter(p, 'LegendScale', 'unity', @fun_is_2nd_units);
addParameter(p, 'YLabel', '', @fun_is_text);
addParameter(p, 'YLims', [], @fun_is_lim);
addParameter(p, 'DataAsRows', true, @fun_is_bool);
addParameter(p, 'ExtraPlotter', [], @fun_is_extra_plotter);
addParameter(p, 'Tolerance', 0, @fun_is_dt);
addParameter(p, 'UseZoh', false, @fun_is_bool);
addParameter(p, 'LabelVertLines', true, @fun_is_bool);
addParameter(p, 'UseDatashader', false, @fun_is_bool);
addParameter(p, 'FigAx', [], @fun_is_fig_ax);
addParameter(p, 'DiffType', 'comp', @(x) (ischar(x) || (isstring(x) && isscalar(x))) && any(x == ["comp", "quat_comp", "quat_mag", "quat_all"]));
addParameter(p, 'LogLevel', 10, @fun_is_log_level);
% do parse
parse(p, description, time_one, data_one, time_two, data_two, varargin{:});
% create some convenient aliases
name_one         = p.Results.NameOne;
name_two         = p.Results.NameTwo;
elements         = p.Results.Elements;
units            = p.Results.Units;
time_units       = p.Results.TimeUnits;
start_date       = p.Results.StartDate;
rms_xmin         = p.Results.RmsXmin;
rms_xmax         = p.Results.RmsXmax;
disp_xmin        = p.Results.DispXmin;
disp_xmax        = p.Results.DispXmax;
make_subplots    = p.Results.MakeSubplots;
single_lines     = p.Results.SingleLines;
color_map        = p.Results.ColorMap;
use_mean         = p.Results.UseMean;
plot_zero        = p.Results.PlotZero;
show_rms         = p.Results.ShowRms;
legend_loc       = p.Results.LegendLoc;
show_extra       = p.Results.ShowExtra;
second_units     = p.Results.SecondUnits;
legend_scale     = p.Results.LegendScale;
y_label          = p.Results.YLabel;
ylims            = p.Results.YLims;
data_as_rows     = p.Results.DataAsRows;
extra_plotter    = p.Results.ExtraPlotter;
tolerance        = p.Results.Tolerance;
use_zoh          = p.Results.UseZoh;
label_vert_lines = p.Results.LabelVertLines;
use_datashader   = p.Results.UseDatashader;
fig_ax           = p.Results.FigAx;
diff_type        = p.Results.DiffType;
log_level        = p.Results.LogLevel;
fig_visible      = ifelse(p.Results.FigVisible, 'on', 'off');

% check if doing quaternion diffs
is_quat_diff = startsWith(diff_type, "quat");
if is_quat_diff
    if ~fun_is_quat(data_one)
        error('quat_one is not a valid quaternion.');
    end
    if ~fun_is_quat(data_two)
        error('quat_two is not a valid quaternion.');
    end
end

% build lists of time and data
[times1, datum1] = make_time_and_data_lists(time_one, data_one, DataAsRows=data_as_rows);
[times2, datum2] = make_time_and_data_lists(time_two, data_two, DataAsRows=data_as_rows);
have_data_one = ~isempty(times1);
have_data_two = ~isempty(times2);
have_both = have_data_one && have_data_two;
if have_data_one
    time_is_date = isdatetime(times1{1});
    if have_data_two
        assert(isdatetime(times2{1}) == time_is_date, "Both time vectors must be dates if either is.");
    end
elseif have_data_two
    time_is_date = isdatetime(times2{1});
else
    time_is_date = false;
end

% check for valid data
if ~have_data_one && ~have_data_two
    data_type = ifelse(is_quat_diff, 'quaternions', 'differences');
    if log_level >= 5
        fprintf(1, 'No %s data was provided, so no plot was generated for "%s".', data_type, description);
    end
    fig_hand = gobjects(1, 0);
    err = struct(one=[], two=[], diff=[]);
    return
end
% check sizing information
num_channels = ifelse(have_data_one, length(times1), length(times2));
if have_both && length(times1) ~= length(times2)
    error('The given elements need to match the data sizes, got %i and %i.', length(times1), length(times2));
end
if is_quat_diff
    assert(num_channels == 4, 'Quaternions must have 4 channels, not %i.', num_channels);
end
switch diff_type
    case 'quat_mag'
        ix_diff = 4;
        zorders = 5;
    case 'quat_comp'
        ix_diff = [1, 2, 3];
        zorders = [8, 6, 5];
    case 'quat_all'
        ix_diff = [1, 2, 3, 4];
        zorders = [8, 6, 5, 4];
    otherwise
        ix_diff = 1:num_channels;
        zorders = repmat(5, [1 num_channels]);
end

% optional inputs
if isempty(elements)
    assert(~is_quat_diff, 'Quaternion diffs should be explicitly specified outside this function.');
    elements = "Channel " + string(1:num_channels);
end
if length(elements) ~= num_channels
    error('The given elements need to match the data sizes, got %i and %i.', num_channels, length(elements));
end

% build RMS indices
if have_both
    dt_same = ifelse(time_is_date, seconds(1e-12), 1e-12);  % TODO: is this possible?  How accurate are datetimes?
    have_unique_t1 = isscalar(unique(cellfun(@length, times1))) && all(cellfun(@(x) max(abs(x - times1{1})), times1) < dt_same);
    have_unique_t2 = isscalar(unique(cellfun(@length, times2))) && all(cellfun(@(x) max(abs(x - times2{1})), times2) < dt_same);
    if have_unique_t1 && have_unique_t2
        % find overlapping times
        [time_overlap_single, d1_diff_ix, d2_diff_ix] = intersect2(times1{1}, times2{1}, tolerance);
        % find differences
        d1_miss_ix = setxor(1:length(times1{1}), d1_diff_ix);
        d2_miss_ix = setxor(1:length(times2{1}), d2_diff_ix);
        time_overlap = repmat({time_overlap_single}, [1 num_channels]);
        if is_quat_diff
            [nondeg_angle, nondeg_error] = quat_angle_diff(data_one(:, d1_diff_ix), data_two(:, d2_diff_ix));
            diffs = {nondeg_error(1, :), nondeg_error(2, :), nondeg_error(3, :), nondeg_angle};
        else
            diffs = cellfun(@(d1, d2) d2(d2_diff_ix) - d1(d1_diff_ix), datum1, datum2, UniformOutput=false);
        end
    else
        error('Non-same time vectors are not implemented for diff plots yet.');  % TODO: implement this
    end
else
    time_overlap = [];
end
ix = build_diff_indices(times1, times2, time_overlap, RmsXmin=rms_xmin, RmsXmax=rms_xmax);

% create a colormap
cm = color_map;  % ColorMap(color_map, num_colors=3 * num_channels);

% calculate the rms (or mean) values
if show_rms || nargout > 1
    if have_data_one
        [data_func, func_name] = calc_rms(datum1, ix.one, UseMean=use_mean);
    else
        data_func = repmat({nan}, 1, num_channels);
    end
    if have_data_two
        [data2_func, func_name] = calc_rms(datum2, ix.two, UseMean=use_mean);
    else
        data2_func = repmat({nan}, 1, num_channels);
    end
    if have_both && any(cellfun(@length, ix.overlap) > 0)
        nondeg_func = calc_rms(diffs, ix.overlap, UseMean=use_mean);
    else
        nondeg_func = repmat({nan}, 1, num_channels);
    end
    % output errors
    if is_quat_diff
        err = struct(one=[data_func{:}], two=[data2_func{:}], diff=[nondeg_func{1:3}], mag=horzcat(nondeg_func(3:end)));
    else
        err = struct(one=[data_func{:}], two=[data2_func{:}], diff=[nondeg_func{:}]);
    end
end

% unit conversion value
[new_units, unit_conv, leg_units, leg_conv] = get_units(units, second_units, legend_scale);

% plotting options
plot_func = ifelse(use_zoh, @plot_zoh, @plot_linear);

if isscalar(single_lines)
    single_lines1 = single_lines;
    single_lines2 = single_lines;
else
    single_lines1 = single_lines(1);
    single_lines2 = single_lines(2);
end
ylabels = get_ylabels(num_channels, y_label, Elements=elements, SingleLines=single_lines1, Description=description, Units=units);
if have_both
    symbol_one = '^-';
    symbol_two = 'v:';
else
    symbol_one = '.-';
    symbol_two = '.-';
end

if isempty(fig_ax)
    % get the number of figures and axes to make
    if have_both
        if make_subplots
            if single_lines1
                if single_lines2
                    fig_ax = create_figure(1, num_channels, 2, Description=description, Visible=fig_visible);
                else
                    fig_ax = cell(1, 2 * num_channels);
                    fig = figure(Visible=fig_visible);
                    ax = gobjects(1, 2 * num_channels);
                    for i = 1:num_channels
                        ax(i) = subplot(num_channels, 2, i);
                    end
                    ax2 = subplot(num_channels, 2, num_channels + 1);
                    error('Not yet implemented.');
                    % gs = fig.add_gridspec(num_channels, 2)
                    % ax = [fig.add_subplot(gs[0, 0])]
                    % for i = 2:num_channels
                    %     ax.append(fig.add_subplot(gs[i, 0], sharex=ax[0]))
                    % end
                    % ax2 = fig.add_subplot(gs[:, 1], sharex=ax[0])
                    % fig_ax = tuple((fig, this_ax) for this_ax in ax) + num_channels * ((fig, ax2),)
                end
            elseif single_lines2
                fig = figure(Visible=fig_visible);
                ax = gobjects(1, 2 * num_channels);
                error('Not yet implemnted.');
                %fig = plt.figure(constrained_layout=True)
                %gs = fig.add_gridspec(num_channels, 2)
                %ax1 = fig.add_subplot(gs[:, 0])
                %ax = [fig.add_subplot(gs[i, 1], sharex=ax1) for i in range(num_channels)]
                %fig_ax = num_channels * ((fig, ax1),) + tuple((fig, this_ax) for this_ax in ax)
            else
                temp_fig_ax = create_figure(1, 2, 1, Description=description, Visible=fig_visible);
                fig_ax = cell(1, num_channels * length(temp_fig_ax));
                for f = 1:length(temp_fig_ax)
                    n = num_channels * f;
                    fig_ax(n + 1 - num_channels:n) = repmat({temp_fig_ax{f}}, 1, num_channels);
                end
            end
        elseif single_lines1
            if single_lines2
                fig_ax = [create_figure(1, num_channels, 1, Description=description, Visible=fig_visible), ...
                    create_figure(1, num_channels, 1, Description=[description,' Difference'], Visible=fig_visible)];
            else
                fig_ax = [create_figure(1, num_channels, 1, Description=description, Visible=fig_visible), ...
                    repmat(create_figure(1, 1, 1, Description=[description,' Difference']), 1, num_channels, Visible=fig_visible)];
            end
        elseif single_lines2
            fig_ax = [repmat(create_figure(1, 1, 1, Description=description, Visible=fig_visible), 1, num_channels), ...
                create_figure(1, num_channels, 1, Description=[description,' Difference'], Visible=fig_visible)];
        else
            fig_ax = [repmat(create_figure(1, 1, 1, Description=description, Visible=fig_visible), 1, num_channels), ...
                repmat(create_figure(1, 1, 1, Description=[description,' Difference'], Visible=fig_visible), 1, num_channels)];
        end
    else
        num_rows = ifelse(single_lines1, num_channels, 1);
        fig_ax = create_figure(1, num_rows, 1, Description=description, Visible=fig_visible);
        if ~single_lines1
            temp_fig_ax = fig_ax;
            fig_ax = cell(1, num_channels * length(temp_fig_ax));
            for f = 1:length(temp_fig_ax)
                n = num_channels * f;
                fig_ax(n + 1 - num_channels:n) = repmat({temp_fig_ax{f}}, 1, num_channels);
            end
        end
    end
end
expected_axes = ifelse(have_both, 2 * num_channels, num_channels);
assert(length(fig_ax) == expected_axes, "Mismatch in the number of figures and axes.");

% Get main figures and axes
fig_hand = [];
axes = dictionary();
id_figs = [];
for f = 1:length(fig_ax)
    this_fig = fig_ax{f}{1};
    this_axes = fig_ax{f}{2};
    this_fig_id = this_fig.Number;
    if ~ismember(this_fig_id, id_figs)
        fig_hand = [fig_hand, this_fig]; %#ok<AGROW>
        id_figs = union(id_figs, this_fig_id);
        axes{this_fig_id} = this_axes;
    else
        axes{this_fig_id} = union(axes{this_fig_id}, this_axes);
    end
end

% Primary plot
color_offset = length(times1);
datashaders = [];
this_zorder =ifelse(is_quat_diff, 3, 4);
for i = 1:num_channels
    this_fig = fig_ax{i}{1};
    this_axes = fig_ax{i}{2};
    this_ylabel = ylabels{i};
    if ~isempty(name_one)
        this_label = [char(name_one),' ',elements{i}];
    else
        this_label = elements{i};
    end
    if have_data_one
        this_time = times1{i};
        this_data = datum1{i};
        if show_rms
            value = num2str(leg_conv * data_func{i}, LEG_FORMAT);
            if ~isempty(leg_units)
                this_label = [this_label,' (',func_name,': ',value,' ',leg_units,')'];
            else
                this_label = [this_label,' (',func_name,': ',value,')'];
            end
        end
        draw_lines(datashaders, this_time, this_data, plot_func, this_axes, Symbol=symbol_one, MarkerSize=4, ...
            Color=cm(i, :), Label=this_label, ZOrder=this_zorder, UseDatashader=use_datashader);  % TODO: cm.get_color(i)
    end
    if ~isempty(name_two)
        this_label = [char(name_two),' ',elements{i}];
    else
        this_label = elements{i};
    end
    if have_data_two
        this_time2 = times2{i};
        this_data2 = datum2{i};
        if show_rms
            value = num2str(leg_conv * data2_func{i}, LEG_FORMAT);
            if ~isempty(leg_units)
                this_label = [this_label,' (',func_name,': ',value,' ',leg_units,')'];
            else
                this_label = [this_label,' (',func_name,': ',value,')'];
            end
        end
        draw_lines(datashaders, this_time2, this_data2, plot_func, this_axes, Symbol=symbol_two, MarkerSize=4, ...
            Color=cm(i + color_offset, :), Label=this_label, ZOrder=this_zorder + 1, UseDatashader=use_datashader);  % TODO: cm.get_color(i + color_offset)
    end
    xlims = label_x(this_axes, disp_xmin, disp_xmax, time_is_date, time_units, start_date);
    zoom_ylim(this_axes, [], [], t_start=xlims(1), t_final=xlims(2));
    if plot_zero
        show_zero_ylim(this_axes)
    end
    if ~isempty(ylims)
        ylim(this_axes, ylims);
    end
    if i == 1
        if is_quat_diff
            title(this_axes, [description,' Components']);
        else
            title(this_axes, description);
        end
    end
    if ~isempty(this_ylabel)
        ylabel(this_axes, this_ylabel);
        grid(this_axes, 'on');
        % optionally add second Y axis
        plot_second_units_wrapper(this_axes, {new_units, unit_conv});
        % plot RMS lines
        if show_rms
            if ~use_mean
                vert_labels = strings(1, 0);
            else
                vert_labels = ["Mean Start Time", "Mean Stop Time"];
            end
            plot_vert_lines(this_axes, ix.pts, ShowInLegend=label_vert_lines, Labels=vert_labels);
        end
    end
end

% Difference plots
if have_both
    assert(~isempty(time_overlap));
    color_offset = length(times1) + length(times2);
    diff_elems = ifelse(is_quat_diff, ["X", "Y", "Z", "Magnitude"], elements);
    y_labels2 = get_ylabels(length(ix_diff), y_label, Elements=diff_elems, SingleLines=single_lines2, Description=description, Units=units);
    for t = 1:length(ix_diff)
        i = ix_diff(t);
        this_ylabel = y_labels2{t};
        this_zorder = zorders(t);
        this_fig = fig_ax{i + num_channels}{1};
        this_axes = fig_ax{i + num_channels}{2};
        this_label = char(diff_elems{i});
        if show_rms
            value = num2str(leg_conv * nondeg_func{i}, LEG_FORMAT);
            if leg_units
                this_label = [this_label,' (',func_name,': ',value,' ',leg_units,')'];
            else
                this_label = [this_label,' (',func_name,': ',value,')'];
            end
        end
        lines = draw_lines(datashaders, time_overlap{i}, diffs{i}, plot_func, this_axes, Symbol=".-", MarkerSize=4, ...
            Color=cm(i + color_offset, :), Label=this_label, ZOrder=this_zorder, UseDatashader=use_datashader);  % cm.get_color(i + color_offset)
        if ~isempty(datashaders) && ~isempty(lines)
            lines(1).set_linestyle("none");
        end
        if show_extra && i == ix_diff(end)
            if ~isempty(d1_miss_ix)
                plot(this_axes, ...
                    this_time(d1_miss_ix), ...
                    zeros(1, length(d1_miss_ix)), ...
                    'kx', ...
                    MarkerSize=8, ...
                    ...MarkerEdgeWidth=2, ...
                    MarkerFaceColor='none', ...
                    DisplayName=name_one + " Extra");
            end
            if ~isempty(d2_miss_ix)
                plot(this_axes, ...
                    times2{1}(d2_miss_ix), ...
                    zeros(1, length(d2_miss_ix)), ...
                    'go', ...
                    MarkerSize=8, ...
                    ...MarkerEdgeWidth=2, ...
                    MarkerFaceColor='none', ...
                    DisplayName=name_two + " Extra");
            end
        end
        xlims = label_x(this_axes, disp_xmin, disp_xmax, time_is_date, time_units, start_date);
        if ~ignore_plot_data(diffs{i}, true)
            zoom_ylim(this_axes, [], [], t_start=xlims(1), t_final=xlims(2));
        end
        if plot_zero
            show_zero_ylim(this_axes)
        end
        if ~isempty(ylims)
            this_axes.set_ylim(ylims);
        end
        if i == ix_diff(1)
            title(this_axes, [description,' Difference']);
        end
        if ~isempty(this_ylabel) || single_lines2
            ylabel(this_axes, this_ylabel);
            grid(this_axes, 'on');
            % optionally add second Y axis
            plot_second_units_wrapper(this_axes, {new_units, unit_conv});
            % plot RMS lines
            if show_rms
                vert_labels = ifelse(~use_mean, strings(1, 0), ["Mean Start Time", "Mean Stop Time"]);
                plot_vert_lines(this_axes, ix.pts, ShowInLegend=label_vert_lines, Labels=vert_labels);
            end
        end
    end
end

if single_lines1 || single_lines2
    fig_hand(1).supylabel(description)
end

% plot any extra information through a generic callable
if ~isempty(extra_plotter)
    for f = 1:length(fig_hand)
        fig = fig_hand{f};
        ax = findall(fig, type='axes');
        ax = ax(ismember(ax, axes{fig.Number}));
        extra_plotter(fig, ax);
    end
end

% overlay the datashaders (with appropriate time units information)
if ~isempty(datashaders)
    error('Datashader not yet implemented in Matlab');
%     for i = 1:length(datashaders)
%         this_ds = datashaders(i);
%         this_ds.time_units = time_units;
%     end
%     add_datashaders(datashaders)
end

% add legend at the very end once everything has been done
if ~strcmpi(legend_loc, 'none')
    for f = 1:length(fig_hand)
        fig = fig_hand(f);
        all_axes = findall(fig, type='Axes');
        for a = 1:length(all_axes)
            this_axes = all_axes(a);
            if ismember(this_axes, axes{fig.Number})
                legend(this_axes, 'show', Location=legend_loc);
            end
        end
    end
end
