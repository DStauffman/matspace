function [fig_hand] = plot_correlation_matrix(data,labels,OPTS,varargin)

% PLOT_CORRELATION_MATRIX  visually plots a correlation matrix.
%
% Input:
%     data ...... : (NxN) correlation matrix [any]
%     labels .... : {Nx1} of char labels to put on plot
%     OPTS ...... : (class) optional plotting commands, see Opts.m for more information
%     varargin .. : (char, value) pairs for other options, from:
%                       'CMin'        : minimum numeric value for the colormap, default is 0
%                       'CMax'        : maximum numeric value for the colormap, default is 1
%                       'LowerOnly'   : plot below diag lower triangle of symmetric matrix, default is true
%                       'ColorMap'    : colormap to use on plot, default is 'cool'
%                       'MatrixName'  : name of the matrix to put on the title, default is 'Correlation Matrix'
%                       'PlotBorder'  : whether to plot a border on each box, default is true
%                       'LabelValues' : whether to label the numeric values on the boxes, default is false
%
% Output:
%     fig_hand .. : (scalar) figure handles [num]
%
% Prototype:
%     data   = rand(10,10);
%     labels = {'a','b','c','d','e','f','g','h','i','j'};
%     data   = bsxfun(@rdivide,data,realsqrt(sum(data.^2,1)));
%     f1     = plot_correlation_matrix(data,labels);
%
%     data   = [0.1 -0.2 0.3; -0.6 -0.5 0];
%     labels = {{'X1','X2','X3'},{'Y1','Y2'}};
%     f2     = plot_correlation_matrix(data,labels);
%
%     f3     = plot_correlation_matrix(data,{},[],'MatrixName','Covariance Matrix');
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
%     2.  This function is designed to run outside of the DStauffman library by not requiring
%         Opts.m, setup_plots.m, or figmenu.m to exist.
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2014.
%     2.  Updated to accept varargin for lots of other options in March 2016.

%% Hard-coded defaults
box_size        = 1;
cmin            = 0;
cmax            = 1;
precision       = 1e-12;
plot_lower_only = true;
color_map       = 'cool';
matrix_name     = 'Correlation Matrix';
plot_borders    = true;
label_values    = false;

%% Check for optional inputs
n = nargin;
switch n
    case 0
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
    case 1
        labels = {};
        try
            OPTS = Opts();
        catch %#ok<CTCH>
            OPTS = [];
        end
    case 2
        try
            OPTS = Opts();
        catch %#ok<CTCH>
            OPTS = [];
        end
    otherwise
        % nop
end

%% Parse varargin
if n > 3
    if mod(n, 2) ~= 1
        error('dstauffman:UnexpectedNameValuePair', 'Expecting an even set of Name-Value pairs.');
    end
    for i=1:2:length(varargin)
        this_name  = varargin{i};
        this_value = varargin{i+1};
        switch lower(this_name)
            case 'cmin'
                cmin            = this_value;
            case 'cmax'
                cmax            = this_value;
            case 'loweronly'
                plot_lower_only = this_value;
            case 'colormap'
                color_map       = this_value;
            case 'matrixname'
                matrix_name     = this_value;
            case 'plotborder'
                plot_borders    = this_value;
            case 'labelvalues'
                label_values    = this_value;
            otherwise
                error('dstauffman:UnexpectedNameValuePair', 'Unexpected Name of "%s".', this_name);
        end
    end
end

%% Process data
% get sizes
[n,m] = size(data);

%% Check labels
if isempty(labels)
    xlab = num2cell(1:m);
    ylab = num2cell(1:n);
else
    if iscell(labels{1})
        xlab = labels{1};
        ylab = labels{2};
    else
        xlab = labels;
        ylab = labels;
    end
end
% check lengths
if length(xlab) ~= m || length(ylab) ~= n
    error('dstauffman:BadLabelSize', 'Incorrecly sized labels.');
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
% create figure;
fig_hand = figure('name', matrix_name);
% get handle to axes for use later
ax = axes('color', 'none');
% set title
title(get(fig_hand, 'name'));
% set hold on, since doing lots of patches
hold on;
% get border color
if plot_borders
    border_color = 'k';
else
    border_color = 'none';
end
% loop through and plot each element with a corresponding color
for i = 1:m
    for j = 1:n
        if ~plot_lower_only || i <= j
            patch(i+box_size*[-1 -1 0 0], j+box_size*[-1 0 0 -1], data(j,i), 'edgecolor', border_color);
        end
        if label_values
            text(box_size*i - box_size/2, box_size*j - box_size/2, num2str(data(j,i),'%.2g'), ...
                'Units', 'data', 'HorizontalAlignment', 'center', 'FontSize', 12, 'interpreter', 'none');
        end
    end
end
% set color limits and colormap and display colorbar
caxis([cmin cmax]);
colormap(color_map);
colorbar('location', 'EastOutside');
% make square
axis equal;
% set limits and tick labels
xlim([0 m]);
ylim([0 n]);
set(ax, 'XTick', (1:m)-box_size/2);
set(ax, 'YTick', (1:n)-box_size/2);
set(ax, 'TickLabelInterpreter', 'none');
set(ax, 'XTickLabel', xlab);
set(ax, 'YTickLabel', ylab);
set(ax, 'YDir', 'reverse');
% rotate x tick labels
a = get(ax, 'XTickLabel');
set(ax, 'XTickLabel', []);
b = get(ax, 'XTick');
text(b, repmat(n+1/5*box_size, length(b), 1), a, 'HorizontalAlignment', 'left', 'rotation', -90, ...
    'interpreter', 'none');

%% Setup plots
% Make this step optional, so that this function can exist outside the whole dstauffman library
if exist('setup_plots', 'file') && isa(OPTS, 'Opts')
    setup_plots(fig_hand,OPTS,'dist');
end
if exist('figmenu', 'file')
    figmenu;
end