function [fig] = plot_population_pyramid(age_bins, male_per, fmal_per, varargin)

% PLOT_POPULATION_PYRAMID  plots the standard population pyramid.
%
% Input:
%     age_bins . : (1xN+1) Age boundaries to plot
%     male_per . : (1xN) Male population percentage in each bin
%     fmal_per . : (1xN) Female population percentage in each bin
%     varargin . : (char, value) pairs for other options, from:
%         Opts . : (class) optional plotting commands, see Opts.m for more information
%         Title  :
%         Name1  : (1xA) time points for series two, default is empty
%         Name2  : (BxA) data points for series two, default is empty
%         Color1 : (char) text to put on the plot titles, default is empty string
%         Color2 : (char) type of data to use when converting axis scale, default is 'unity'
%
% Output:
%     fig : figure handle
%
% Prototype:
%     age_bins = [  0,   5,  10,  15,  20, 1000];
%     male_per = [500, 400, 300, 200, 100] / 3000;
%     fmal_per = [450, 375, 325, 225, 125] / 3000;
%     fig_hand = matspace.plotting.plot_population_pyramid(age_bins, male_per, fmal_per);
%
%     % Close plot
%     close(fig_hand);
%
% References:
%     1.  https://en.wikipedia.org/wiki/Population_pyramid
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2017.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

%% Imports
import matspace.latex.bins_to_str_ranges
import matspace.plotting.Opts
import matspace.plotting.private.fun_is_bool
import matspace.plotting.private.fun_is_colormap
import matspace.plotting.private.fun_is_opts
import matspace.plotting.private.fun_is_text
import matspace.plotting.setup_plots
import matspace.utils.ifelse

%% hard-coded values
scale = 100;

%% Parse Inputs
% create parser
p = inputParser;
% set options
addParameter(p, 'Opts', Opts(), @fun_is_opts);
addParameter(p, 'Title', 'Population Pyramid', @fun_is_text);
addParameter(p, 'Name1', 'Male', @fun_is_text);
addParameter(p, 'Name2', 'Female', @fun_is_text);
addParameter(p, 'Color1', 'b', @fun_is_color);
addParameter(p, 'Color2', 'r', @fun_is_color);
addParameter(p, 'FigVisible', true, @fun_is_bool);
addParameter(p, 'FigTheme', 'light', @fun_is_text);
% do parse
parse(p, varargin{:});
% create some convenient aliases
title_ = p.Results.Title;
name1  = p.Results.Name1;
name2  = p.Results.Name2;
color1 = p.Results.Color1;
color2 = p.Results.Color2;
fig_visible = ifelse(p.Results.FigVisible, 'on', 'off');
fig_theme = p.Results.FigTheme;

%% Process inputs
if isempty(p.Results.Opts)
    opts = Opts();
else
    opts = p.Results.Opts;
end
if ~opts.show_plot && ismember('FigVisible', p.UsingDefaults)
    fig_visible = 'off';
end

%% Plot data
% convert data to percentages
num_pts   = length(age_bins) - 1;
y_values  = 1:num_pts;
y_labels  = bins_to_str_ranges(age_bins, 1, 200);

% create the figure and axis and set the title
fig = figure(Name=title_, Visible=fig_visible, Theme=fig_theme);
ax = axes(fig);

% set hold on
hold(ax, 'on');

% plot bars
barh(ax, y_values, -scale*male_per, 0.95, FaceColor=color1, DisplayName=name1);
barh(ax, y_values,  scale*fmal_per, 0.95, FaceColor=color2, DisplayName=name2);

% make sure plot is symmetric about zero
max_xlim = max(abs(xlim));
xlim(ax, [-max_xlim, max_xlim]);

% add labels
xlabel(ax, 'Population [%]')
ylabel(ax, 'Age [years]')
title(ax, title_)
yticks(ax, y_values);
yticklabels(ax, y_labels);
legend(ax, 'show');

%% setup plots
setup_plots(fig, opts);