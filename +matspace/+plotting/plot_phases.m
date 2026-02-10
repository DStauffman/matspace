function [] = plot_phases(ax, times, colors, labels)

% PLOT_PHASES  plots some labeled phases as semi-transparent patchs on the given axis.
%
% Input:
%     ax : (Axes) Figure axes
%     times : (1xN) or (2xN) list of times, if it has two rows, then the second are the end points
%         otherwise assume the sections are continuous.
%     colors : (Nx3) RGB colors, or any valid color names [numeric]
%     labels : (1xN) string array of labels [char]
%
% Output:
%     (None)
%
% Prototype:
%     % method 1
%     fig = figure('name', 'Sine Wave');
%     ax = axes(fig);
%     time = 0:100;
%     data = cos(time/10);
%     plot(ax, time, data, '.-', 'DisplayName', 'Waves');
%     times = [5 20 30 50; 10 30 35 70];
%     labels = ["Part 1", "Phase 2", "Watch Out", "Final"];
%     colorlists = matspace.plotting.colors.get_color_lists();
%     colors = colorlists.quat;
%     matspace.plotting.plot_phases(ax, times, colors, labels);
%
%     % method 2
%     times2 = [60 80 90; 70 85 100];
%     matspace.plotting.plot_phases(ax, times2, colorlists.default(1, :), 'Monitor');
%     legend(ax, 'show');
%
% Change Log:
%     1.  Written by David C. Stauffer in July 2019.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.
%     3.  Updated by David C. Stauffer in May 2020 to be able to plot multiple segments with the
%         same color and name.
%     4.  Updated by David C. Stauffer in January 2026 to use arguments with custom defaults.

arguments
    ax (1,1) matlab.graphics.axis.Axes
    times {mustBeOneOrTwoByN}
    colors = default_colors()
    labels (1, :) {mustBeA(labels, ["char", "cell", "string"])} = strings(1, 0)
end

% hard-coded values
transparency = 0.2; % 1 = opaque;

% determine if using a single label
if ischar(labels) || isscalar(labels)
    use_single_label = true;
    patch_group = hggroup('DisplayName', labels);
    set(get(get(patch_group, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'on');
else
    use_single_label = false;
end

% get the limits of the plot
xlims = xlim(ax);
ylims = ylim(ax);

% create second row of times if not specified (assumes each phase goes all the way to the next one)
if size(times, 1) == 1
    times = [times; times(2:end) max(times(end), xlims(2))];
end

% loop through all the phases
for i = 1:size(times, 2)
    % get the label and color for this phase
    if use_single_label
        this_color = colors;
    else
        this_color = colors(i, :);
    end
    % get the locations for this phase
    x1 = times(1, i);
    x2 = times(2, i);
    y1 = ylims(1);
    y2 = ylims(2);
    % create the shaded box
    p = patch(ax, [x1 x2 x2 x1 x1], [y1 y1 y2 y2 y1], this_color, 'edgecolor', this_color, 'facealpha', transparency);
    % create the label
    if use_single_label
        p.Parent = patch_group;
    elseif ~isempty(labels)
        set(get(get(p, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
        text(x1, y2, labels{i}, ...
            'Units', 'data', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
            'FontSize', 12, 'interpreter', 'none', 'rotation', -90);
    end
end

% reset any limits that might have changed due to the patches
xlim(ax, xlims);
ylim(ax, ylims);


%% Subfunctions - mustBeOneOrTwoByN
function mustBeOneOrTwoByN(x)

if ~ismember(size(x, 1), [1 2])
    throwAsCaller(MException('matspace:plot_phases:BadTimeSize','Input must be exactly one or two rows.'))
end


%% Subfunctions - default_colors
function [colors] = default_colors()

% Get a default colormap based on the quat colorlist.

import matspace.plotting.colors.get_color_lists

colorlists = get_color_lists();
colors = colorlists.quat;