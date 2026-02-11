function [fig] = plot_histogram(description, data, bins, varargin)

% Creates a histogram plot of the given data and bins.
%
% Input:
% description : str
%     Name to label on the plots
% data : (N, ) ndarray
%     data to bin into buckets
% bins : (A, ) ndarray
%     boundaries of the bins to use for the histogram
% counts : (A, ) ndarray, optional
%     If specified, use this already processed counts instead of data
% Opts : class Opts, optional
%     plotting options
% Color : str or RGB or RGBA code, optional
%     Name of color to use
% XLabel : str, optional
%     Name to put on x-axis
% YLabel : str, optional
%     Name to put on y-axis
% SecondYLabel : str, optional
%     Name to put on second y-axis
% XLim : tuple[float, float], optional
%     X-limits to override those calculated automatically
% Units : str, optional
%     Units to label on the x-axis
% Formatter : str, optional
%     Formatter to use in the legend for CDF calculations
% NormalizeSpacing : bool, optional, default is False
%     Whether to normalize all the bins to the same horizontal size
% UseExactCounts : bool, optional, default is False
%     Whether to bin things based only on exactly equal values
% ShowCdf : bool, optional, default is False
%     Whether to draw the CDF result
% CdfX : scalar or (B, ) ndarray
%     X values to draw lines at CDF
% CdfY : scalar or (C, ) ndarray
%     Y values to draw lines at CDF
% CdfColormap : str or matplotlib.colors.Colormap, optional
%     Colors/colormap to use for CDF lines
% CdfSameAxis : bool, optional, default is False
%     Whether to use the same axis for the CDF, or to create a secondary one
% CdfRoundToBin : bool, optional, default is False
%     Whether to round the CDF crossings to bin edges
% FigAx : (fig, ax) tuple, optional
%     Figure and axis to use, otherwise create new ones
% SkipSetupPlots : bool, optional, default is False
%     Whether to skip the setup_plots step, in case you are manually adding to an existing axis
% **kwargs : dict
%     Additional plotting arguments to override Opts, from {"legend_loc"}
%
% Output:
% fig : class matplotlib.figure.Figure
%     Figure handle
%
% Prototype:
%     description = 'Histogram';
%     data = [0.5, 3.3, 1.0, 1.5, 1.5, 1.75, 2.5, 2.5];
%     bins = [0.0, 1.0, 2.0, 3.0, 5.0, 7.0];
%     fig_hand = matspace.plotting.plot_histogram(description, data, bins);
%
%     % With CDF
%     fig2 = matspace.plotting.plot_histogram(description, data, bins, ShowCdf=true, CdfY=0.5);
%
%     % Close plots
%     close(fig_hand);
%     close(fig2);
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2021.
%     2.  Translated into Matlab by David C. Stauffer in 2026.

%% Imports
import matspace.plotting.colors.get_xkcd_colors
import matspace.plotting.figmenu
import matspace.plotting.get_factors
import matspace.plotting.Opts
import matspace.plotting.plot_rms_lines
import matspace.plotting.plot_second_yunits
import matspace.plotting.private.fun_is_colormap
import matspace.plotting.private.fun_is_fig_ax
import matspace.plotting.private.fun_is_opts
import matspace.plotting.setup_plots
import matspace.plotting.show_zero_ylim
import matspace.plotting.whitten
import matspace.stats.intersect2
import matspace.utils.ifelse

%% Parser
% Validation functions
fun_is_empty_or_len2 = @(x) (isempty(x) || length(x) == 2);
% Argument parser
p = inputParser;
addParameter(p, 'Counts', [], @isnumeric);
addParameter(p, 'Opts', Opts, @fun_is_opts);
addParameter(p, 'Color', '#1f77b4', @ischar);
addParameter(p, 'XLabel', 'Data', @ischar);
addParameter(p, 'YLabel', 'Number', @ischar);
addParameter(p, 'SecondYLabel', 'Distribution [%]', @ischar);
addParameter(p, 'XLim', [], fun_is_empty_or_len2);
addParameter(p, 'Units', '', @ischar);
addParameter(p, 'Formatter', '%.3g', @ischar);
addParameter(p, 'NormalizeSpacing', false, @islogical);
addParameter(p, 'UseExactCounts', false, @islogical);
addParameter(p, 'ShowCdf', false, @islogical);
addParameter(p, 'CdfX', [], @isnumeric);
addParameter(p, 'CdfY', [], @isnumeric);
addParameter(p, 'CdfColormap', [], @fun_is_colormap);
addParameter(p, 'CdfSameAxis', false, @islogical);
addParameter(p, 'CdfRoundToBin', false, @islogical);
addParameter(p, 'FigAx', [], @fun_is_fig_ax);
addParameter(p, 'SkipSetupPlots', false, @islogical);
addParameter(p, 'LegendLoc', '', @ischar);

parse(p, varargin{:});
counts            = p.Results.Counts;
opts              = p.Results.Opts;
color             = p.Results.Color;
x_label           = p.Results.XLabel;
y_label           = p.Results.YLabel;
second_y_label    = p.Results.SecondYLabel;
x_lim             = p.Results.XLim;
units             = p.Results.Units;
formatter         = p.Results.Formatter;
normalize_spacing = p.Results.NormalizeSpacing;
use_exact_counts  = p.Results.UseExactCounts;
show_cdf          = p.Results.ShowCdf;
cdf_x             = p.Results.CdfX;
cdf_y             = p.Results.CdfY;
cdf_colormap      = p.Results.CdfColormap;
cdf_same_axis     = p.Results.CdfSameAxis;
cdf_round_to_bin  = p.Results.CdfRoundToBin;
fig_ax            = p.Results.FigAx;
skip_setup_plots  = p.Results.SkipSetupPlots;
legend_loc        = p.Results.LegendLoc;

% data checks (do before any figures are generated)
using_cdf = show_cdf || ~isempty(cdf_x) || ~isempty(cdf_y);
if using_cdf && ~cdf_round_to_bin && ~isempty(data)
    raise ValueError("CDF bins must be rounded to the bin edges if you specified counts instead of data.")
end
% convert inputs
num_cdf_x = length(cdf_x);
num_cdf_y = length(cdf_y);
num_cdf = double(show_cdf);
if ~isempty(units)
    unit_pad = ' ';
else
    unit_pad = '';
end
if isempty(legend_loc)
    legend_loc = opts.leg_spot;
end
if isempty(counts)
    assert(~isempty(data));
    data_size = numel(data);
    if use_exact_counts
        counts = nans(size(bins));
        for i = 1:length(bins)
            this_bin = bins(i);
            counts(i) = nnz(data == this_bin);
        end
    else
        % TODO: optionally allow this to not include 100% of the data by disabling some error
        % checks in np_digitize?
        counts = histcounts(data, bins);  % TODO: check this function name
    end
    missing = data_size - sum(counts, 'All');
else
    assert(isempty(data));
    data_size = sum(counts);
    missing = 0;
end
assert(~isempty(counts), 'counts should always be set from this point forward.');
num = numel(bins);
if normalize_spacing || use_exact_counts
    xlab = cellfun(@num2str, bins, 'UniformOutput', false);
    if use_exact_counts
        num = num + 1;
    end
    if missing > 0
        xlab(end+1) = 'Unbinned Data';
    end
    plotting_bins = 1:num;
else
    plotting_bins = bins;
    ix_pinf = isinf(plotting_bins) & (sign(plotting_bins) > 0);
    ix_ninf = isinf(plotting_bins) & (sign(plotting_bins) < 0);
    if any(ix_pinf)
        if isempty(data)
            plotting_bins(ix_pinf) = 1e10;
        else
            plotting_bins(ix_pinf) = max(data);
        end
    end
    if any(ix_ninf)
        if isempty(data)
            plotting_bins(ix_ninf) = -1e10;
        else
            plotting_bins(ix_ninf) = min(data);
        end
    end
end
% create plot
if isempty(fig_ax)
    fig = figure();
    ax = axes(fig);
else
    fig = fig_ax{1}{1};
    ax = fig_ax{1}{2};
end
sgt_hand = findall(fig, 'Type', 'subplottext');
if isempty(sgt_hand)
    fig.Name = description;
else
    fig.Name = sgt_hand.String;
end
title(ax, description);
for i = 1:num - 1
    verts = [plotting_bins(i) 0; plotting_bins(i+1) 0; plotting_bins(i+1) counts(i); plotting_bins(i) counts(i)];
    patch(ax, Faces=[1 2 3 4], Vertices=verts, FaceColor=color, EdgeColor='k');
end
if missing > 0
    verts = [plotting_bins(end-1) 0; plotting_bins(end) 0; plotting_bins(end) counts(i); plotting_bins(end-1) counts(i)];
    patch(ax, Faces=[1 2 3 4], Vertices=verts, FaceColor=color, EdgeColor='k');
end
grid(ax, 'on');
xlabel(ax, ifelse(~isempty(units), x_label + " [" + units + "]", x_label));
ylabel(ax, y_label);
if isempty(x_lim)
    if missing > 0
        xlim(ax, [min(plotting_bins), max(plotting_bins) + 1]);
    else
        xlim(ax, [min(plotting_bins), max(plotting_bins)]);
    end
else
    xlim(ax, x_lim);
end
if cdf_same_axis
    ylim(ax, [0 data_size]);
else
    ylim(ax, [0 1.05 * max(counts)]);
end
if normalize_spacing
    xticks(ax, plotting_bins);
    xticklabels(ax, xlab);
elseif use_exact_counts
    if missing > 0
        xticks(ax, plotting_bins + 0.5);
    else
        xticks(ax, plotting_bins(1:end-1) + 0.5);
    end
    xticklabels(ax, xlab);
end
plot_second_yunits(ax, second_y_label, 100 / data_size);
% Optionally add CDF information
color_ix = 1;
if using_cdf
    % prepare the colormap
    if isempty(cdf_colormap)
        colors = get_xkcd_colors();
        cdf_colormap = [repmat(colors.grass_green, [num_cdf 1]); repmat(colors.red, [num_cdf_x 1]); repmat(colors.hot_magenta, [num_cdf_y 1])];
    end
    cm = ColorMap(cdf_colormap);
    % create fake items to add to legend
    patch(ax, [0 0 0 0], [0 0 0 0], facecolor=color, linewidth=0, edgecolor='none', DisplayName='PDF');
    % create the CDF
    if cdf_round_to_bin
        cdf = [0, cumsum(counts)] ./ data_size;
        cdf_bin = plotting_bins;
    else
        cdf = (0:data_size) ./ data_size;
        cdf_bin = [0, sort(data)];
    end
end
if show_cdf
    % plot the CDF
    if ~cdf_same_axis
        %yyaxis(ax, 'right');  % TODO: make third axes farther right!
        %ylim(ax, [0 100]);
        %ax3.spines.right.set_position("axes", 1.06);
        %ax3.yaxis.label.set_color(cm.get_color(color_ix));
        %ylabel(ax, 'CDF Distribution [%]');
        %ax3.tick_params(axis="y", colors=cm.get_color(color_ix));
    end
    % Note: plot on transformed axes instead of ax3 to maintain constant pan/zoom
    if normalize_spacing
        temp = discretize_mex(cdf_bin, bins);
        bins_temp = arrayfun(@(x) bins(x), temp, UniformOutput=false);
        bins_plus = arrayfun(@(x) bins(x + 1), temp, UniformOutput=false);  % np.array([bins[t + 1] for t in temp])
        cdf_scaled = temp + (cdf_bin - bins_temp) / (bins_plus - bins_temp);
        step(ax, cdf_scaled, cdf, color=cm.get_color(color_ix), DisplayName='CDF');  % ZOrder=8, Transform=trans
    else
        step(ax, cdf_bin, cdf, color=cm.get_color(color_ix), DisplayName='CDF');  % ZOrder=8, Transform=trans
    end
    color_ix = color_ix + 1;
end
if ~isempty(cdf_x)
    for i = 1:length(cdf_x)
        this_x = cdf_x(i);
        this_ix = np.argmax(cdf_bin >= this_x);
        if normalize_spacing
            this_bin = cdf_scaled(this_ix);
        else
            this_bin = cdf_bin(this_ix);
        end
        this_cdf = cdf(this_ix);
        this_label = format(this_x, formatter) + unit_pad + units + "=" + format(100 * this_cdf, formatter) + "%";
        plot(ax, ...
            [0, 1], ...
            [this_cdf, this_cdf], ...
            color=cm.get_color(color_ix), ...
            label=this_label);
            % zorder=9, ...
            % transform=ax.transAxes, ...
        plot(ax, ...
            this_bin, ...
            this_cdf, ...
            marker='o', ...
            markeredgecolor=cm.get_color(color_ix), ...
            markerfacecolor='none', ...
            label='');
            % zorder=10, ...
            % transform=trans, ...
        color_ix = color_ix + 1;
    end
end
if ~isempty(cdf_y)
    for i = 1:length(cdf_y)
        this_cdf = cdf_y(i);
        this_ix = np.argmax(cdf >= this_cdf);
        this_label = format(100 * this_cdf, formatter) + "%=" + format(cdf_bin(this_ix), formatter) + unit_pad + units;
        this_bin = ifelse(normalize_spacing, cdf_scaled(this_ix), cdf_bin(this_ix));
        yline(ax, this_bin, DisplayName=this_label, Color=cm.get_color(color_ix));  % zorder=9
        plot(ax, this_bin, cdf(this_ix), Marker='x', Color=cm.get_color(color_ix), DisplayName='');  % zorder=10, transform=trans
        color_ix = color_ix + 1;
    end
end
if using_cdf
    % Add a legend now, since there is something to display
    %[handles, labels] = ax.get_legend_handles_labels();
    %handles.insert(0, p);
    %labels.insert(0, 'PDF');
    legend(ax, 'show', Location=legend_loc);
end
if ~skip_setup_plots
    figmenu;
    setup_plots(fig, opts);
end