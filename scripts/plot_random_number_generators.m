% Script to plot random number generators of different types.
%
% Notes:
%     1.  Written by David C. Stauffer in March 2023.

%% Overall Configuration
num = [50000, 1];
use_toolbox = false;
minmax = [];
%minmax = [2, 4];

%% None
distribution = 'None';
coeffs = 5;
values = matspace.utils.get_random_value(distribution, num, coeffs, minmax, use_toolbox=use_toolbox);
fig1 = makeplot(distribution, values, use_toolbox);

%% Uniform
distribution = 'Uniform';
coeffs = [0, 10];
values = matspace.utils.get_random_value(distribution, num, coeffs, minmax, use_toolbox=use_toolbox);
fig2 = makeplot(distribution, values, use_toolbox);

%% Normal
distribution = 'Normal';
coeffs = [5, 3];
values = matspace.utils.get_random_value(distribution, num, coeffs, minmax, use_toolbox=use_toolbox);
fig3 = makeplot(distribution, values, use_toolbox);

%% Beta
distribution = 'Beta';
coeffs = [2, 3];
values = 10 * matspace.utils.get_random_value(distribution, num, coeffs, minmax, use_toolbox=use_toolbox);
fig4 = makeplot(distribution, values, use_toolbox);

%% Gamma
distribution = 'Gamma';
coeffs = [1, 2];
values = matspace.utils.get_random_value(distribution, num, coeffs, minmax, use_toolbox=use_toolbox);
fig5 = makeplot(distribution, values, use_toolbox);

%% Triagular
distribution = 'Triangular';
coeffs = [0, 4, 10];
values = matspace.utils.get_random_value(distribution, num, coeffs, minmax, use_toolbox=use_toolbox);
fig6 = makeplot(distribution, values, use_toolbox);

%% Plotting Niceties
matspace.plotting.figmenu;

%% Support
function [c1, c2, c3, c4, c5, c6, c7] = get_default_colors()
    colors = colororder();
    c1 = colors(1, :);
    c2 = colors(2, :);
    c3 = colors(3, :);
    c4 = colors(4, :);
    c5 = colors(5, :);
    c6 = colors(6, :);
    c7 = colors(7, :);
end

function [fig] = makeplot(distribution, values, use_toolbox)
    edges = 0:0.2:10;
    [c1, ~, ~, c4] = get_default_colors();
    if use_toolbox
        this_title = [distribution,' (Toolbox)'];
        this_color = c1;
    else
        this_title = [distribution,' (No toolbox)'];
        this_color = c4;
    end
    fig = figure('Name', this_title);
    ax = axes(fig);
    histogram(ax, values, edges, 'EdgeColor', 'none', 'FaceColor', this_color);
    title(ax, this_title);
end