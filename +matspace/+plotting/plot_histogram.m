function [fig_hand] = plot_histogram(data, edges, OPTS, varargin)

% PLOT_HISTOGRAM  plots the histogram of the given data with the given edges
%
% Prototype:
%     data = randn(10000, 1);
%     edges = [-3 -2 -1 -0.5 0 0.25, 0.5 0.75, 1.0, 1.5, 2.0, 3.0, 5.0];
%     OPTS = matspace.plotting.Opts();
%     matspace.plotting.plot_histogram(data, edges, OPTS, 'Description', 'Example Histogram');

%% Imports
import matspace.plotting.figmenu
import matspace.plotting.plot_second_yunits
import matspace.plotting.setup_plots

%% Parser
% Argument parser
p = inputParser;
addParameter(p, 'Description', '', @ischar);
addParameter(p, 'XLabel', 'Bins', @ischar);
parse(p, varargin{:});
description = p.Results.Description;
xlab = p.Results.XLabel;

%% Calculations
% histogram
N = histcounts(data, edges);
if OPTS.show_plot
    fig_visible = 'on';
else
    fig_visible = 'off';
end

%% Plot
fig_hand = figure('Name', description, 'Visible', fig_visible);
ax = axes(fig_hand);
hold(ax, 'on');
for i = 1:length(N)
    patch(ax, 'Faces', [1 2 3 4], 'Vertices', [edges(i) 0; edges(i+1) 0; edges(i+1) N(i); edges(i) N(i)], ...
        'FaceColor', [0.000 0.447 0.741], 'EdgeColor', 'k');
end
title(ax, description, 'Interpreter', 'None');
xlabel(ax, xlab);
ylabel(ax, 'Number');
plot_second_yunits(ax, 'Distribution [%]', 100 / sum(N));
grid(ax, 'on');
hold(ax, 'off');

%% Format plots
setup_plots(fig_hand, OPTS, 'dist_no_y_scale');
if OPTS.show_plot
    figmenu;
else
    close(fig_hand);
    fig_hand = [];
end