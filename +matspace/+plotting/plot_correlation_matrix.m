function [fig_hand] = plot_correlation_matrix(data, labels, units, kwargs)

% PLOT_CORRELATION_MATRIX  visually plots a correlation matrix.
%
% Input:
%     data ...... : (NxN) correlation matrix [any]
%     labels .... : {Nx1} of char labels to put on plot
%     OPTS ...... : (class) optional plotting commands, see Opts.m for more information
%     varargin .. : (char, value) pairs for other options, from:
%         'CMin'        : minimum numeric value for the colormap, default is 0
%         'CMax'        : maximum numeric value for the colormap, default is 1
%         'LowerOnly'   : plot below diag lower triangle of symmetric matrix, default is true
%         'ColorMap'    : colormap to use on plot, default is 'cool'
%         'MatrixName'  : name of the matrix to put on the title, default is 'Correlation Matrix'
%         'PlotBorder'  : whether to plot a border on each box, default is true
%         'LabelValues' : whether to label the numeric values on the boxes, default is false
%
% Output:
%     fig_hand .. : (scalar) figure handles [num]
%
% Prototype:
%     data   = rand(10,10);
%     labels = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
%     data   = bsxfun(@rdivide,data,realsqrt(sum(data.^2,1)));
%     f1     = matspace.plotting.plot_correlation_matrix(data, labels);
%
%     data   = [0.1 -0.2 0.3; -0.6 -0.5 0];
%     labels = {{'X1','X2','X3'},{'Y1','Y2'}};
%     f2     = matspace.plotting.plot_correlation_matrix(data, labels);
%
%     f3     = matspace.plotting.plot_correlation_matrix(data, MatrixName='Covariance Matrix');
%
%     % clean up
%     close([f1 f2 f3]);
%
% See Also:
%     (None)
%
% Notes:
%     1.  For square symmetric matrices, only the lower half of diagonal is plotted, depending on
%         the current settings.
%     2.  This function is designed to run outside of the matspace library by not requiring
%         Opts.m, setup_plots.m, or figmenu.m to exist.
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2014.
%     2.  Updated to accept varargin for lots of other options in March 2016.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.

%% Arguments
arguments
    data (:, :) double
    labels (1, :) {mustBeLabels} = strings(1, 0)
    units {mustBeTextScalar} = ''
    kwargs.Opts {mustBeOpts} = Opts()
    kwargs.MatrixName {mustBeTextScalar} = 'Correlation Matrix'
    kwargs.CMin (1, 1) double = 0
    kwargs.CMax (1, 1) double = 1
    kwargs.XLabel {mustBeTextScalar} = ''
    kwargs.YLabel {mustBeTextScalar} = ''
    kwargs.PlotLowerOnly (1, 1) logical = true
    kwargs.LabelValues (1, 1) logical = false
    kwargs.XLabRot (1, 1) double = 90
    kwargs.ColorMap {mustBeColorMap} = []
    kwargs.PlotBorder (1, 1) logical = true
    kwargs.LegendScale {mustBe2ndUnits} = 'unity'
    kwargs.FigAx {mustBeFigAx} = []
    kwargs.SkipSetupPlots (1, 1) logical = false
    kwargs.FigVisible (1, 1) logical = true
end
% Parser
opts             = kwargs.Opts;
matrix_name      = kwargs.MatrixName;
cmin             = kwargs.CMin;
cmax             = kwargs.CMax;
x_label          = kwargs.XLabel;
y_label          = kwargs.YLabel;
plot_lower_only  = kwargs.PlotLowerOnly;
label_values     = kwargs.LabelValues;
x_lab_rot        = kwargs.XLabRot;
color_map        = kwargs.ColorMap;
plot_borders     = kwargs.PlotBorder;
legend_scale     = kwargs.LegendScale;
fig_ax           = kwargs.FigAx;
skip_setup_plots = kwargs.SkipSetupPlots;
if kwargs.FigVisible
    fig_visible  = 'on';
else
    fig_visible  = 'off';
end
if isempty(opts)
    opts = Opts();
end
if isempty(color_map)
    if isempty(opts.colormap)
        color_map = cool();
    else
        color_map = opts.colormap;
    end
end

[new_units, scale] = get_unit_conversion(legend_scale, units);

%% Imports
import matspace.plotting.figmenu
import matspace.plotting.get_unit_conversion
import matspace.plotting.Opts
import matspace.plotting.setup_plots
import matspace.utils.where

%% Hard-coded defaults
box_size        = 1;
precision       = 1e-12;

%% Process data
% get sizes
[n,m] = size(data);

%% Check labels
if isempty(labels)
    xlab = num2cell(1:m);
    ylab = num2cell(1:n);
else
    if iscell(labels)
        xlab = labels{1};
        ylab = labels{2};
    else
        xlab = labels;
        ylab = labels;
    end
end
% check lengths
if length(xlab) ~= m || length(ylab) ~= n
    error('matspace:BadLabelSize', 'Incorrecly sized labels.');
end

%% Determine if symmetric
if m == n && all(all(abs(data - data') < precision))
    is_symmetric = true;
else
    is_symmetric = false;
end
plot_lower_only  = plot_lower_only && is_symmetric;

%% Override color ranges based on data
% test if in -1 to 1 range instead of 0 to 1
if all(all(data >= -1 + precision)) && any(any(data <= -precision)) && cmin == 0 && cmax == 1
    cmin = -1;
end
% test if outside the cmin to cmax range, and if so, adjust range.
temp = min(min(data));
if temp < cmin
    cmin = temp;
end
temp = max(max(data));
if temp > cmax
    cmax = temp;
end

%% Create plots
this_title = [matrix_name,char(where(~isempty(new_units), " [" + new_units + "]", ""))];
if isempty(fig_ax)
    % create figure;
    fig_hand = figure(Name=this_title, Visible=fig_visible);
    % get handle to axes for use later
    ax = axes('color', 'none');
else
    fig_hand = fig_ax{1}{1};
    ax = fig_ax{1}{2};
end
% set title
title(this_title);
% set hold on, since doing lots of patches
hold(ax, 'on');
% get border color
border_color = char(where(plot_borders, "k", "none"));
% loop through and plot each element with a corresponding color
for i = 1:m
    for j = 1:n
        if ~plot_lower_only || i <= j
            patch(i+box_size*[-1 -1 0 0], j+box_size*[-1 0 0 -1], scale * data(j,i), 'edgecolor', border_color);
        end
        if label_values
            text(box_size*i - box_size/2, box_size*j - box_size/2, num2str(scale * data(j,i),'%.2g'), ...
                'Units', 'data', 'HorizontalAlignment', 'center', 'FontSize', 12, 'interpreter', 'none');
        end
    end
end
% set color limits and colormap and display colorbar
clim([cmin cmax]);
colormap(color_map);
colorbar('location', 'EastOutside');
% make square
axis(ax, 'equal');
% set limits and tick labels
xlim([0 m]);
ylim([0 n]);
% reverse the y axis
set(ax, 'YDir', 'reverse');
set(ax, 'XTick', (1:m)-box_size/2);
set(ax, 'YTick', (1:n)-box_size/2);
set(ax, 'TickLabelInterpreter', 'none');
set(ax, 'XTickLabel', xlab);
set(ax, 'YTickLabel', ylab);
% rotate x tick labels
a = get(ax, 'XTickLabel');
set(ax, 'XTickLabel', []);
b = get(ax, 'XTick');
text(b, repmat(n+1/5*box_size, length(b), 1), a, 'HorizontalAlignment', 'left', 'rotation', x_lab_rot, ...
    'interpreter', 'none');
% label axes
xlabel(ax, x_label);
ylabel(ax, y_label);

%% Setup plots
if ~skip_setup_plots
    figmenu;
    setup_plots(fig_hand, opts, 'dist_no_y_scale');
end


%% Subfunctions - mustBeOpts
function mustBeOpts(x)
import matspace.plotting.private.fun_is_opts
if ~fun_is_opts(x)
    throwAsCaller(MException('matspace:plot_cor:BadOpts','Opts must be empty, a struct, or Opts class.'));
end


%% Subfunctions - mustBeColorMap
function mustBeColorMap(x)
import matspace.plotting.private.fun_is_colormap
if ~fun_is_colormap(x)
    throwAsCaller(MException('matspace:plot_cor:BadCM', 'ColorMap must be a valid name or 3xN matrix or ColorMap class.'));
end


%% Subfunctions - mustBeLabels
function mustBeLabels(x)
if ~isstring(x) && (~iscell(x) || length(x) ~= 2)
    throwAsCaller(MException('matspace:plot_cor:BadLabels', 'Labels must be a string array, or a two element cell array of string arrays.'));
end


%% Subfunctions - mustBe2ndUnits
function mustBe2ndUnits(x)
import matspace.plotting.private.fun_is_2nd_units
if ~fun_is_2nd_units(x)
    throwAsCaller(MException('matspace:plot_cor:BadLegScale', 'Legend Scale is not valid.'));
end


%% Subfunctions - mustBeFigAx
function mustBeFigAx(x)
import matspace.plotting.private.fun_is_fig_ax
if ~fun_is_fig_ax(x)
    throwAsCaller(MException('matspace:plot_cor:BadFigAx', 'FigAx input is not valid.'));
end