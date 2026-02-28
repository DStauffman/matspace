% Script to demonstrate how to plot on custom subplots using the fig_ax argument.
%
% Notes:
%     1.  Written by David C. Stauffer in January 2022.
%     2.  Translated into Matlab by David C. Stauffer in January 2026.

%% Imports
import matspace.plotting.fig_ax_factory
import matspace.plotting.make_connected_sets
import matspace.plotting.Opts
import matspace.plotting.plot_correlation_matrix
import matspace.plotting.plot_histogram
import matspace.plotting.plot_time_history
import matspace.utils.unit

%% Settings
comb_plots = true; %#ok<*UNRCH>

%% Example 1
% create data
description = 'Focal Plane Sightings';
points = 2 * rand(2, 1000) - 1.0;
innovs = 0.1 * randn(size(points));
ix = points(1, :) < 0;
innovs(:, ix) = innovs(:, ix) - 0.1;
ix = points(2, :) > 0;
innovs(:, ix) = innovs(:, ix) + 0.2;

% build the figures and axes combinations to use
fig_ax = fig_ax_factory(NumAxes=[2, 2], Layout='colwise', ShareX=true, PassThrough=~comb_plots);

% populate the plots
fig1 = make_connected_sets(description, points, [], UseDatashader=false, FigAx=fig_ax(1), ...
    HideInnovs=true, ColorBy='none');
fig2 = make_connected_sets(description, points, innovs, UseDatashader=false, FigAx=fig_ax(2), ...
    HideInnovs=false, ColorBy='none');
fig3 = make_connected_sets(description, points, innovs, UseDatashader=false, FigAx=fig_ax(3), ...
    HideInnovs=true, ColorBy='direction');
fig4 = make_connected_sets(description, points, innovs, UseDatashader=false, FigAx=fig_ax(4), ...
    HideInnovs=true, ColorBy='magnitude');

if comb_plots
    fig = fig_ax{1}{1};
    assert(fig1 == fig2 && fig1 == fig3 && fig1 == fig4 && fig1 == fig, "All figures should be identical.");
else
    assert(fig1 ~= fig2);
    assert(fig1 ~= fig3);
    assert(fig1 ~= fig4);
end

%% Example 2
fig_ax2 = fig_ax_factory(NumAxes=2, Layout='cols', ShareX=false, SupTitle='Combined Plots', PassThrough=~comb_plots);
% histogram
description = 'Histogram';
data = [0.5, 3.3, 1.0, 1.5, 1.5, 1.75, 2.5, 2.5];
bins = [0.0, 1.0, 2.0, 3.0, 5.0, 7.0];
plot_histogram(description, data, bins, FigAx=fig_ax2(1), SkipSetupPlots=comb_plots);
% correlation matrix
data = unit(rand(10, 10), 1);
labels = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
units = 'm';
% opts = Opts(CaseName='Test');
opts = Opts();
opts.case_name = 'Test';
matrix_name = 'Correlation Matrix';
cmin = 0;
cmax = 1;
x_label = '';
y_label = '';
plot_lower_only = true;
label_values = true;
x_lab_rot = 90;
colormap = cool(256);
plot_border = true;
legend_scale = 'centi';
fig_ex2 = plot_correlation_matrix(...
    data, ...
    labels, ...
    units, ...
    Opts=opts, ...
    MatrixName=matrix_name, ...
    CMin=cmin, ...
    CMax=cmax, ...
    XLabel=x_label, ...
    YLabel=y_label, ...
    PlotLowerOnly=plot_lower_only, ...
    LabelValues=label_values, ...
    XLabRot=x_lab_rot, ...
    ColorMap=colormap, ...
    PlotBorder=plot_border, ...
    LegendScale=legend_scale, ...
    FigAx=fig_ax2(2), ...
    SkipSetupPlots=false);

%% Example 3
fig_ax3 = fig_ax_factory(NumFigs=1, NumAxes=[2, 2], Layout="rowwise", ShareX=true, SupTitle="Vector Plots", PassThrough=~comb_plots);
time = 1:30;
plot_time_history('1st', time, ones(1, 30), units='one', figax=fig_ax3(1), SkipSetupPlots=comb_plots);
plot_time_history('2nd', time, [10; 11] + ones(2, 30), units='two', FigAx=repmat(fig_ax3(2), [1 2]), ...
    SkipSetupPlots=comb_plots);
plot_time_history('3rd', time, [100; 110; 120] + ones(3, 30), units='three', ...
    FigAx=repmat(fig_ax3(3), [1 3]), SkipSetupPlots=comb_plots);
fig_ex3 = plot_time_history('4th', time, [1000; 1100; 1200; 1300] + ones(4, 30), Units='Four', ...
    FigAx=repmat(fig_ax3(4), [1 4]), SkipSetupPlots=false);
