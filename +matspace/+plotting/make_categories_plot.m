function [fig_hand] = make_categories_plot(description, time, data, cats, varargin)

% Data versus time plotting routine when grouped into categories.
%
% Input:
%     (TBD)
%
% Output:
%     fig_hand .. : (scalar) figure handles [num]
%
% Prototype:
%     description      = 'Values vs Time';
%     time             = -10:0.1:10;
%     data             = [time + cos(time); ones(size(time))];
%     data(2, 60:85)   = 2;
%     MeasStatus       = type("MeasStatus", (object,), {"rejected": 0, "accepted": 1})
%     cats             = np.full(time.shape, MeasStatus.accepted, dtype=int)
%     cats[50:100]     = MeasStatus.rejected
%     cat_names        = {0: "rejected", 1: "accepted"}
%     name             = '';
%     elements         = strings(1, 0);
%     units            = '';
%     time_units       = 'sec';
%     start_date       = '';
%     rms_xmin         = -inf;
%     rms_xmax         = inf;
%     disp_xmin        = -inf;
%     disp_xmax        = inf;
%     make_subplots    = True
%     single_lines     = false;
%     color_map        = matspace.plotting.colors.paired();
%     use_mean         = true;
%     plot_zero        = false;
%     show_rms         = true;
%     legend_loc       = 'best';
%     second_units     = '';
%     legend_scale     = '';
%     y_label          = '';
%     data_as_rows     = true;
%     extra_plotter    = [];
%     use_zoh          = false;
%     label_vert_lines = true;
%     use_datashader   = false;
%     fig_ax           = [];
%     fig_hand = matspace.plotting.make_categories_plot(description, time, data, cats, ...
%         CatNames=cat_names, Name=name, Elements=elements, ...
%         Units=units, TimeUnits=time_units, StartDate=start_date, ...
%         RmsXmin=rms_xmin, RmsXmax=rms_xmax, DispXmin=disp_xmin, DispXmax=disp_xmax, ...
%         MakeSubplots=make_subplots, SingleLines=single_lines, ColorMap=color_map, ...
%         UseMean=use_mean, PlotZero=plot_zero, ShowRms=show_rms, LegendLoc=legend_loc, ...
%         SecondUnits=second_units, LegendScale=legend_scale, YLabel=y_label, DataAsRows=data_as_rows, ...
%         ExtraPlotter=extra_plotter, UseZoh=use_zoh, LabelVertLines=label_vert_lines, ...
%         UseDatashader=use_datashader, FigAx=fig_ax);
%
%     % Close plots
%     close(fig_hand);
%
% Change Log:
%     1.  Written by David C. Stauffer in May 2020.
%     2.  Wrapped to the generic do everything version by David C. Stauffer in March 2021.
%     3.  Translated into Matlab by David C. Stauffer in January 2026.

%% Imports
import matspace.plotting.plot_second_units_wrapper
import matspace.plotting.private.build_indices
import matspace.plotting.private.calc_rms
import matspace.plotting.private.create_figure
import matspace.plotting.private.draw_lines
import matspace.plotting.private.fun_is_2nd_units
import matspace.plotting.private.fun_is_bool
import matspace.plotting.private.fun_is_bound
import matspace.plotting.private.fun_is_colormap
import matspace.plotting.private.fun_is_data
import matspace.plotting.private.fun_is_extra_plotter
import matspace.plotting.private.fun_is_fig_ax
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
import matspace.utils.ifelse

%% Hard-coded values
LEG_FORMAT  = '%1.3f';
datashader_pts = 2000;  % Plot this many points on top of datashader plots, or skip if fewer exist

%% Parser
% Argument parser
p = inputParser;
addRequired(p, 'Description', @fun_is_text);
addRequired(p, 'Time', @fun_is_time);
addRequired(p, 'Data', @fun_is_data);
addRequired(p, 'Cats', @fun_is_data);  % TODO: any further restrictions or let-ups?
addParameter(p, 'CatNames', strings(1, 0), @isstring);
addParameter(p, 'Name', '', @fun_is_text);
addParameter(p, 'Elements', strings(0), @isstring);
addParameter(p, 'Units', '', @fun_is_text);
addParameter(p, 'TimeUnits', 'sec', @fun_is_text);
addParameter(p, 'StartDate', '', @fun_is_text);
addParameter(p, 'RmsXmin', -inf, @fun_is_bound);
addParameter(p, 'RmsXmax', inf, @fun_is_bound);
addParameter(p, 'DispXmin', -inf, @fun_is_bound);
addParameter(p, 'DispXmax', inf, @fun_is_bound);
addParameter(p, 'MakeSubplots', false, @fun_is_bool);
addParameter(p, 'SingleLines', false, @fun_is_bool);
addParameter(p, 'FigVisible', true, @fun_is_bool);
addParameter(p, 'ColorMap', [], @fun_is_colormap);
addParameter(p, 'UseMean', false, @fun_is_bool);
addParameter(p, 'PlotZero', false, @fun_is_bool);
addParameter(p, 'ShowRms', true, @fun_is_bool);
addParameter(p, 'LegendLoc', 'Best', @fun_is_text);
addParameter(p, 'SecondUnits', nan, @fun_is_2nd_units);
addParameter(p, 'LegendScale', 'unity', @fun_is_2nd_units);
addParameter(p, 'YLabel', '', @fun_is_text);
addParameter(p, 'YLims', [], @fun_is_lim);
addParameter(p, 'DataAsRows', true, @fun_is_bool);
addParameter(p, 'ExtraPlotter', [], @fun_is_extra_plotter);
addParameter(p, 'UseZoh', false, @fun_is_bool);
addParameter(p, 'LabelVertLines', false, @fun_is_bool);
addParameter(p, 'UseDatashader', false, @fun_is_bool);
addParameter(p, 'FigAx', [], @fun_is_fig_ax);
% do parse
parse(p, description, time, data, cats, varargin{:});
% create some convenient aliases
cat_names        = p.Results.CatNames;
name             = p.Results.Name;
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
second_units     = p.Results.SecondUnits;
legend_scale     = p.Results.LegendScale;
y_label          = p.Results.YLabel;
ylims            = p.Results.YLims;
data_as_rows     = p.Results.DataAsRows;
extra_plotter    = p.Results.ExtraPlotter;
use_zoh          = p.Results.UseZoh;
label_vert_lines = p.Results.LabelVertLines;
use_datashader   = p.Results.UseDatashader;
fig_ax           = p.Results.FigAx;
fig_visible      = ifelse(p.Results.FigVisible, 'on', 'off');

%% Processing
[times, datum] = make_time_and_data_lists(time, data, DataAsRows=data_as_rows);
num_channels = length(times);
time_is_date = ~isempty(times) && isdatetime(times{1});

% check for valid data
if isempty(datum)
    if log_level >= 5
        fprintf(1, 'No categories data was provided, so no plot was generated for "%s".\n', description);
    end
    return
end

% optional inputs
if isempty(elements)
    elements = arrayfun(@(x) ['Channel ', int2str(x)], 1:num_channels, UniformOutput=false);
end
if length(elements) ~= num_channels
    error('The given elements need to match the data sizes, got %i and %i.', num_channels, length(elements));
end

% build RMS (or mean) indices and calculate the values
if show_rms
    ix = build_indices(times, rms_xmin, rms_xmax);
end

% create a colormap
cm = ColorMap(colormap=colormap);

% Category calculations
unique_cats = unique(cats);
num_cats = length(unique_cats);
% Add any missing dictionary values
for x in unique_cats
    if x not in cat_names
        cat_names[x] = "Status=" + str(x)
    end
end
ordered_cats = [x for x in cat_names if x in unique_cats]
cat_keys = np.array(list(cat_names.keys()), dtype=int)

% calculate the rms (or mean) values
if show_rms
    data_func = {}
    for cat in ordered_cats
        % TODO: handle isinstance(cats, list) case
        ix_cat = cats == cat
        this_datum = [data[ix_cat] for data in datum]
        temp_ix_one = [i[ix_cat] for i in ix["one"]]
        data_func[cat], func_name = _calc_rms(this_datum, temp_ix_one, use_mean=use_mean)
    end
end

% unit conversion value
[new_units, unit_conv, leg_units, leg_conv] = get_units(units, second_units, legend_scale);

% plotting options
if use_zoh
    plot_func = @plot_zoh;
else
    plot_func = @plot_linear;
end

% get labels
y_labels = get_ylabels(num_channels, y_label, Elements=elements, SingleLines=true, Description=description, Units=units);

if isempty(fig_ax)
    % get the figure titles
    if single_lines
        titles = [f"{description} {e} {cat_names[cat]}" for cat in ordered_cats for e in elements]
    else
        titles = [f"{description} {e}" for e in elements]
    end
    % get the number of figures and axes to make
    if make_subplots
        num_figs = 1;
        num_rows = num_channels;
        num_cols = ifelse(single_lines, num_cats, 1);
    else
        num_figs = ifelse(single_lines, num_channels * num_cats, num_channels);
        num_cols = 1;
        num_rows = 1;
    end
    fig_ax = create_figure(num_figs, num_rows, num_cols, Description=description, Visible=fig_visible);
    assert(~isempty(fig_ax));
    if make_subplots
        fig_hand = fig_ax{1}{1};
        axes_hand = cellfun(@(x) x{2}, fig_ax);
    else
        fig_hand = cellfun(@(x) x{1}, fig_ax);
        axes_hand = cellfun(@(x) x{2}, fig_ax);  % [fig.axes[0:1] for fig in figs]
    end
    if ~single_lines
        fig_ax = tuple(item for temp in fig_ax for item in [temp] * num_cats)
    end
    for fig, title in zip(figs, titles):
        fig.canvas.manager.set_window_title(title)
    end
end

% Primary plot
datashaders = [];
for i = 1:min([length(times), length(datum)])
    this_time = times{i};
    this_data = datum{i};
    this_ylabel = ylabels{i};
    this_label = f"{name} {elements[i]}" if name else f"{elements[i]}"
    this_axes = fig_ax[i * num_cats][1]
    % plot the full underlying line once
    if ~use_datashader || numel(this_time) <= datashader_pts
        plot_func(this_axes, this_time, this_data, ':', label='', color="xkcd:slate", linewidth=1, zorder=2)
    end
    % plot the data with this category value
    for j, cat in enumerate(ordered_cats):
        _, sub_axes = fig_ax[i * num_cats + j]
        this_cat_name = cat_names[cat]
        if show_rms
            value = num2str(leg_conv * data_func{cat}{i}, LEG_FORMAT);
            if ~isempty(leg_units)
                cat_label = [this_label,' ',this_cat_name,' (',func_name,': ',num2str(value),' ',leg_units,')'];
            else
                cat_label = [this_label,' ',this_cat_name,' ('func_name,': ',num2str(value),')'];
            end
        else
            cat_label = [this_label,' ',this_cat_name];
        end
        this_cats = cats == cat;
        % Note: Use len(cat_keys) here instead of num_cats so that potentially missing categories
        % won't mess up the color scheme by skipping colors
        this_cat_ix = np.argmax(cat == cat_keys)
        this_color = cm.get_color(i * len(cat_keys) + this_cat_ix)
        lines = draw_lines(datashaders, this_time[this_cats], this_data[this_cats], plot_func, sub_axes, Symbol='.',
            MarkerSize=6, MarkerFaceColor=this_color, Color=this_color, Label=cat_label, ZOrder=3, UseDatashader=use_datashader);
        if ~isempty(lines)
            lines(1).set_linestyle("none" if bool(datashaders) or not single_lines else "-")
        end
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
        title(this_axes, description);
    end
    if ~isempty(this_ylabel) || single_lines
        subs = [fig_ax[i * num_cats + j][1] for j in range(num_cats)] if single_lines else [this_axes]
        for sub in subs:
            ylabel(sub, this_ylabel);
            grid(sub, 'on');
            % optionally add second Y axis
            plot_second_units_wrapper(sub, {new_units, unit_conv});
            % plot RMS lines
            if show_rms
                vert_labels = ifelse(~use_mean, strings(1, 0), ["Mean Start Time", "Mean Stop Time"]);
                plot_vert_lines(sub, ix.pts, ShowInLegend=label_vert_lines, Labels=vert_labels);
        end
    end
end

if single_lines
    figs(1).supylabel(description)
end

% plot any extra information through a generic callable
if ~isempty(extra_plotter)
    for i = 1:length(fig_hand)
        fig = fig_hand(i);
        ax = axes(i);
        extra_plotter(fig, ax);
    end
end

% add legend at the very end once everything has been done
if ~strcmpi(legend_loc, 'none')
    for i = 1:length(ax)
        this_axes = ax(1);
        legend(this_axes, 'show', Location=legend_loc);
    end
end