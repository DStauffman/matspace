function [fig] = plot_population_pyramid(age_bins, male_per, fmal_per, varargin)

% PLOT_POPULATION_PYRAMID  plots the standard population pyramid.
%
% Input:
%     age_bins ... : (1xN+1) Age boundaries to plot
%     male_per ... : (1xN) Male population percentage in each bin
%     fmal_per ... : (1xN) Female population percentage in each bin
%     OPTS ....... : (class) optional plotting commands, see Opts.m for more information
%     varargin ... : (char, value) pairs for other options, from:
%         'Name1'  : (1xA) time points for series two, default is empty
%         'Name2'  : (BxA) data points for series two, default is empty
%         'Color1' : (char) text to put on the plot titles, default is empty string
%         'Color2' : (char) type of data to use when converting axis scale, default is 'unity'
%
% Output:
%     fig : figure handle
%
% Prototype:
%     age_bins = [  0,   5,  10,  15,  20, 1000];
%     male_per = [500, 400, 300, 200, 100] / 3000;
%     fmal_per = [450, 375, 325, 225, 125] / 3000;
%     fig      = matspace.plotting.plot_population_pyramid(age_bins, male_per, fmal_per);
%
% References:
%     1.  https://en.wikipedia.org/wiki/Population_pyramid
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2017.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

%% Imports
import matspace.latex.bins_to_str_ranges
import matspace.plotting.figmenu
import matspace.plotting.Opts
import matspace.plotting.setup_plots

%% hard-coded values
scale = 100;

%% Parse Inputs
% create parser
p = inputParser;
% create some validation functions
fun_is_opts = @(x) isa(x, 'matspace.plotting.Opts') || isempty(x);
fun_is_color = @(x) ischar || (isvector(x) && length(x) == 3);
% set options
addOptional(p, 'OPTS', Opts, fun_is_opts);
addParameter(p, 'Title', 'Population Pyramid', @ischar);
addParameter(p, 'Name1', 'Male', @ischar);
addParameter(p, 'Name2', 'Female', @ischar);
addParameter(p, 'Color1', 'b', fun_is_color);
addParameter(p, 'Color2', 'r', fun_is_color);
% do parse
parse(p, varargin{:});
% create some convenient aliases
title_ = p.Results.Title;
name1  = p.Results.Name1;
name2  = p.Results.Name2;
color1 = p.Results.Color1;
color2 = p.Results.Color2;

%% Process inputs
if isempty(p.Results.OPTS)
    OPTS = Opts();
else
    OPTS = p.Results.OPTS;
end

%% Plot data
% convert data to percentages
num_pts   = length(age_bins) - 1;
y_values  = 1:num_pts;
y_labels  = bins_to_str_ranges(age_bins, 1, 200);

% create the figure and axis and set the title
fig = figure('name', title_);
ax = axes;

% set hold on
hold on;

% plot bars
barh(ax, y_values, -scale*male_per, 0.95, 'FaceColor', color1, 'DisplayName', name1);
barh(ax, y_values,  scale*fmal_per, 0.95, 'FaceColor', color2, 'DisplayName', name2);

% make sure plot is symmetric about zero
max_xlim = max(abs(xlim));
xlim([-max_xlim, max_xlim]);

% add labels
xlabel('Population [%]')
ylabel('Age [years]')
title(title_)
yticks(y_values);
yticklabels(y_labels);
legend('show');

%% create figure controls
figmenu;

%% setup plots
setup_plots(fig, OPTS, 'dist_no_y_scale')