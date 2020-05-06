function [] = plot_phases(ax, times, colors, labels)

% PLOT_PHASES  plots some labeled phases as semi-transparent patchs on the given axis.
%
% Input:
%     ax : (Axes) Figure axes
%     times : (1xN) or (2xN) list of times, if it has two rows, then the second are the end points
%         otherwise assume the sections are continuous.
%     colors : {1xN} of (1x3) RGB colors, or any valid color names [numeric]
%     labels : (1xN) string array of labels [char]
%
% Output:
%     (None)
%
% Prototype:
%     % method 1
%     fig = figure('name', 'Sine Wave');
%     ax = subplot(1, 1, 1);
%     time = 0:100;
%     data = cos(time/10);
%     plot(ax, time, data, '.-', 'DisplayName', 'Waves');
%     times = [5 20 30 50; 10 30 35 70];
%     labels = ["Part 1", "Phase 2", "Watch Out", "Final"];
%     colorlists = matspace.plotting.get_color_lists();
%     colors = colorlists.quat;
%     matspace.plotting.plot_phases(ax, times, colors, labels);
%
%     % method 2
%     times2 = [60 80 90; 70 85 100];
%     matspace.plotting.plot_phases(ax, times2, colorlists.default{1}, 'Monitor');
%     legend(ax, 'show');
%     
%
% Change Log:
%     1.  Written by David C. Stauffer in July 2019.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.
%     3.  Updated by David C. Stauffer in May 2020 to be able to plot multiple segments with the
%         same color and name.

% hard-coded values
transparency = 0.2; % 1 = opaque;

% check for optional arguments
switch nargin
    case 2
        import matspace.plotting.get_color_lists % Note: delayed import as you might not need it
        colorlists = get_color_lists();
        colors = colorlists.quat;
        labels = {};
    case 3
        labels = {};
    case 4
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% determine if using a single label
if ischar(labels) || length(labels) == 1
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
        this_color = colors{i};
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