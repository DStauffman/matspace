function [fig] = plot_histogram(description, data, bins, varargin)
% Creates a histogram plot of the given data and bins.
%
% Parameters
% ----------
% description : str
%     Name to label on the plots
% data : (N, ) ndarray
%     data to bin into buckets
% bins : (A, ) ndarray
%     boundaries of the bins to use for the histogram
% counts : (A, ) ndarray, optional
%     If specified, use this already processed counts instead of data
% opts : class Opts, optional
%     plotting options
% color : str or RGB or RGBA code, optional
%     Name of color to use
% xlabel : str, optional
%     Name to put on x-axis
% ylabel : str, optional
%     Name to put on y-axis
% second_ylabel : str, optional
%     Name to put on second y-axis
% xlim : tuple[float, float], optional
%     X-limits to override those calculated automatically
% units : str, optional
%     Units to label on the x-axis
% formatter : str, optional
%     Formatter to use in the legend for CDF calculations
% normalize_spacing : bool, optional, default is False
%     Whether to normalize all the bins to the same horizontal size
% use_exact_counts : bool, optional, default is False
%     Whether to bin things based only on exactly equal values
% show_cdf : bool, optional, default is False
%     Whether to draw the CDF result
% cdf_x : scalar or (B, ) ndarray
%     X values to draw lines at CDF
% cdf_y : scalar or (C, ) ndarray
%     Y values to draw lines at CDF
% cdf_colormap : str or matplotlib.colors.Colormap, optional
%     Colors/colormap to use for CDF lines
% cdf_same_axis : bool, optional, default is False
%     Whether to use the same axis for the CDF, or to create a secondary one
% cdf_round_to_bin : bool, optional, default is False
%     Whether to round the CDF crossings to bin edges
% fig_ax : (fig, ax) tuple, optional
%     Figure and axis to use, otherwise create new ones
% skip_setup_plots : bool, optional, default is False
%     Whether to skip the setup_plots step, in case you are manually adding to an existing axis
% **kwargs : dict
%     Additional plotting arguments to override Opts, from {"legend_loc"}
%
% Returns
% -------
% fig : class matplotlib.figure.Figure
%     Figure handle
%
% Notes
% -----
% #.  Written by David C. Stauffer in February 2021.
%
% Examples
% --------
% >>> description = 'Histogram'
% >>> data = [0.5, 3.3, 1.0, 1.5, 1.5, 1.75, 2.5, 2.5];
% >>> bins = [0.0, 1.0, 2.0, 3.0, 5.0, 7.0];
% >>> fig = matspace.plotting.plot_histogram(description, data, bins);
%
% With CDF
% >>> fig2 = matspace.plotting.plot_histogram(description, data, bins, ShowCdf=true, CdfY=0.5);
%
% Close plot
% >>> close(fig);
% >>> close(fig2);

%% Imports
import matspace.plotting.get_factors
import matspace.plotting.plot_rms_lines
import matspace.plotting.plot_second_yunits
import matspace.plotting.private.fun_is_colormap
import matspace.plotting.private.fun_is_opts
import matspace.plotting.show_zero_ylim
import matspace.plotting.whitten
import matspace.stats.intersect2
import matspace.utils.nanmean
import matspace.utils.nanrms

%% Parser
% Validation functions
fun_is_empty_or_len2 = @(x) (isempty(x) || length(x) == 2);
% Argument parser
p = inputParser;
addParameter(p, 'Counts', [], @isnumeric);
addParameter(p, 'OPTS', Opts, @fun_is_opts);
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
addParameter(p, 'FigAx', fun_is_empty_or_len2);
addParameter(p, 'SkipSetupPlots', false, @islogical);
addParameter(p, 'LegendLoc', '', @ischar);

parse(p, varargin{:});
counts            = p.Results.Counts;
opts              = p.Results.OPTS;
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
rects = [Rectangle((plotting_bins[i], 0), plotting_bins[i + 1] - plotting_bins[i], counts[i]) for i in range(num - 1)]
if missing > 0:
    rects.append(Rectangle((plotting_bins[-1], 0), 1, missing))
coll = PatchCollection(rects, facecolor=color, edgecolor="k", zorder=6)
% create plot
if fig_ax is None
    fig = plt.figure()
    ax = fig.add_subplot(1, 1, 1)
else
    (fig, ax) = fig_ax
end
if (sup := fig._suptitle) is None
    fig.canvas.manager.set_window_title(description)
else
    fig.canvas.manager.set_window_title(sup.get_text())
end
ax.set_title(description)
ax.add_collection(coll)
ax.grid(True)
ax.set_xlabel(f"{xlabel} [{units}]" if units else xlabel)
ax.set_ylabel(ylabel)
if xlim is None
    if missing > 0
        ax.set_xlim((np.min(plotting_bins), np.max(plotting_bins) + 1))
    else
        ax.set_xlim((np.min(plotting_bins), np.max(plotting_bins)))
    end
else
    ax.set_xlim(xlim)
end
if cdf_same_axis
    ax.set_ylim((0, data_size))
else
    ax.set_ylim((0, 1.05 * np.max(counts)))
end
if normalize_spacing
    ax.set_xticks(plotting_bins)
    ax.set_xticklabels(xlab)
elseif use_exact_counts
    if missing > 0
        ax.set_xticks(plotting_bins + 0.5)
    else
        ax.set_xticks(plotting_bins[:-1] + 0.5)
    end
    ax.set_xticklabels(xlab)
end
plot_second_yunits(ax, ylab=second_ylabel, multiplier=100 / data_size);
% Optionally add CDF information
color_ix = 0;
if using_cdf
    % prepare the colormap
    if isempty(cdf_colormap)
        cdf_colormap = colors.ListedColormap(("xkcd:grass green",) * num_cdf + ("xkcd:red",) * num_cdf_x + ("xkcd:hot magenta",) * num_cdf_y)  # fmt: skip
    end
    cm = ColorMap(colormap=cdf_colormap, num_colors=num_cdf + num_cdf_x + num_cdf_y);
    % create fake items to add to legend
    p = Rectangle((0, 0), 1, 1, facecolor=color, linewidth=0, edgecolor="none");
    % create a transform with X in data units and Y in axes units
    trans = transforms.blended_transform_factory(ax.transData, ax.transAxes);
    % create the CDF
    if cdf_round_to_bin
        cdf = np.hstack([0.0, np.cumsum(counts)]) / data_size;
        cdf_bin = plotting_bins;
    else
        cdf = np.hstack([np.arange(data_size) / data_size, 1.0]);
        cdf_bin = np.hstack([0.0, np.sort(data)]);
    end
end
if show_cdf
    % plot the CDF
    if ~cdf_same_axis
        ax3 = ax.twinx();
        ax3.set_ylim(0, 100);
        ax3.spines.right.set_position("axes", 1.06);
        ax3.yaxis.label.set_color(cm.get_color(color_ix));
        ax3.set_ylabel("CDF Distribution [%]");
        ax3.tick_params(axis="y", colors=cm.get_color(color_ix));
    end
    % Note: plot on transformed axes instead of ax3 to maintain constant pan/zoom
    if normalize_spacing
        temp = np_digitize(cdf_bin, bins);
        bins_temp = np.array([bins[t] for t in temp])
        bins_plus = np.array([bins[t + 1] for t in temp])
        cdf_scaled = temp + (cdf_bin - bins_temp) / (bins_plus - bins_temp);
        ax.step(cdf_scaled, cdf, color=cm.get_color(color_ix), label="CDF", zorder=8, transform=trans);
    else
        ax.step(cdf_bin, cdf, color=cm.get_color(color_ix), label="CDF", zorder=8, transform=trans);
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
        ax.plot(...
            [0, 1], ...
            [this_cdf, this_cdf], ...
            color=cm.get_color(color_ix), ...
            label=this_label, ...
            zorder=9, ...
            transform=ax.transAxes, ...
        );
        ax.plot(...
            this_bin, ...
            this_cdf, ...
            marker="o", ...
            markeredgecolor=cm.get_color(color_ix), ...
            markerfacecolor="none", ...
            label="", ...
            zorder=10, ...
            transform=trans, ...
        );
        color_ix = color_ix + 1;
    end
end
if ~isempty(cdf_y)
    for i = 1:length(cdf_y)
        this_cdf = cdf_y(i);
        this_ix = np.argmax(cdf >= this_cdf);
        this_label = format(100 * this_cdf, formatter) + "%=" + format(cdf_bin[this_ix], formatter) + unit_pad + units;
        this_bin = cdf_scaled[this_ix] if normalize_spacing else cdf_bin[this_ix];
        ax.axvline(this_bin, label=this_label, color=cm.get_color(color_ix), zorder=9);
        ax.plot(this_bin, cdf[this_ix], marker="x", color=cm.get_color(color_ix), label="", zorder=10, transform=trans);
        color_ix = color_ix + 1;
    end
end
if using_cdf
    % Add a legend now, since there is something to display
    [handles, labels] = ax.get_legend_handles_labels();
    handles.insert(0, p);
    labels.insert(0, "PDF");
    ax.legend(handles, labels, loc=legend_loc);
end
if ~skip_setup_plots
    setup_plots(fig, OPTS=opts);
end