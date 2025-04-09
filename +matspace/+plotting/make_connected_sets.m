function [fig] = make_connected_sets(description, points, innovs, varargin)
    
% MAKE_CONNECTED_SETS  Plots two sets of X-Y pairs, with lines drawn between them.
%
% Summary:
%     TBD
%
% Input:
%     description : (row) Plot description [char]
%     points .... : (2, N) Focal plane sightings
%     innovs .... : (2, N) Innovations (implied to be in focal plane frame)
%     varargin .. : (char, value) pairs for other options, from:
%         'HideInnovs'   : (scalar) true/false flag to hide the innovations and only show the sightings [bool]
%         'ColorBy'      : (row) How to color the innovations, 'none' for same calor, 'magnitude' to
%                          color by innovation magnitude, or 'direction' to color by polar direction
%         'CenterOrigin' : Whether to center the origin in the plot
%         'LegendLoc'    : Location of the legend in the plot, default is 'best'
%         'FigVisible'   : (row) setting value for whether figure is visible, from {'on','off'} [char]
%         'Units'        : Units to label on the plot
%         'MagRatio'     : Percentage highest innovation magnitude to use, typically 0.95-1.0, but lets
%                          you exclude outliers that otherwise make the colorbar less useful
%         'LegScale'     : Amount to scale the colorbar legend, default is 'micro'
%         'Colormap'     : Name to use instead of the default colormaps, which depend on the mode
%         'AddQuiver'    : Whether to add matplotlib quiver lines to the plot, default is false [bool]
%         'QuiverScale'  : quiver line scale factor
%
% Output:
%     fig_hand : (scalar) list of figure handles [num]
%
% Prototype:
%     description = 'Focal Plane Sightings';
%     points = [0.1 0.6 0.7; 1.1 1.6 1.7];
%     innovs = 5*[0.01 0.02 0.03; -0.01 -0.015 -0.01];
%     fig = matspace.plotting.make_connected_sets(description, points, innovs);
%
%     points2 = 2 * rand(2, 100) - 1;
%     innovs2 = 0.1 * randn(size(points2));
%     fig2 = matspace.plotting.make_connected_sets(description, points2, innovs2, 'ColorBy', 'direction');
%
%     fig3 = make_connected_sets(description, points2, innovs2, 'ColorBy', 'magnitude', ...
%             'LegScale', 'milli', 'Units', 'm');
%
%     close(fig);
%     close(fig2);
%     close(fig3);

%% Imports
import matspace.paths.get_root_dir
import matspace.plotting.get_factors
import matspace.plotting.get_unit_conversion
import matspace.plotting.get_xkcd_colors

%% Hard-coded values
filename = fullfile(get_root_dir(), 'data', 'xkcd_rgb_colors.txt');
colors = get_xkcd_colors(filename);
colors_meas = colors.black;
RAD2DEG = 180/pi;
DEGREE_SIGN = char(176);

%% Parser
% Validation functions
fun_is_colormap = @(x) ischar(x) || isempty(x) || isnumeric(x);  % or is Colormap?
% Argument parser
p = inputParser;
addParameter(p, 'ColorBy', 'none', @ischar);
addParameter(p, 'HideInnovs', false, @islogical);
addParameter(p, 'CenterOrigin', false, @islogical);
addParameter(p, 'LegendLoc', 'best', @ischar);
addParameter(p, 'FigVisible', true, @islogical);
addParameter(p, 'Units', '', @ischar);
addParameter(p, 'MagRatio', [], @isnumeric);
addParameter(p, 'LegScale', 'unity', @ischar);
addParameter(p, 'ColorMap', [], fun_is_colormap);
addParameter(p, 'AddQuiver', false, @islogical);
addParameter(p, 'QuiverScale', [], @isnumeric);
parse(p, varargin{:});
color_by        = p.Results.ColorBy;
hide_innovs     = p.Results.HideInnovs;
center_origin   = p.Results.CenterOrigin;
legend_loc      = p.Results.LegendLoc;
units           = p.Results.Units;
mag_ratio       = p.Results.MagRatio;
leg_scale       = p.Results.LegScale;
color_map       = p.Results.ColorMap;
add_quiver      = p.Results.AddQuiver;
quiver_scale    = p.Results.QuiverScale;
if p.Results.FigVisible
    fig_visible = 'on';
else
    fig_visible = 'off';
end

% calculations
if isempty(innovs)
    assert(strcmpi(color_by, 'none'), 'If no innovations are given, then you must color by "none", not "%s".', color_by);
    plot_innovs = false;
elseif hide_innovs
    plot_innovs = false;
else
    plot_innovs = true;
    predicts = points - innovs;
end

% color options
if strcmpi(color_by, 'none')
    colors_line = colors.red;
    if isempty(color_map)
        colors_pred = colors.blue;
    else
        colors_pred = color_map;
    end
    extra_text  = '';
elseif strcmpi(color_by, 'direction')
    polar_ang   = RAD2DEG * atan2(innovs(2, :), innovs(1, :));
    cmin        = -180;
    cmax        = 180;
    if isempty(color_map)
        innov_cmap = hsv(256);
    else
        innov_cmap = color_map;
    end
    rows_ix     = ceil(255 * (polar_ang + 180) / 360);
    colors_line = innov_cmap(rows_ix, :);
    colors_pred = colors_line;
    extra_text  = ' (Colored by Direction)';
elseif strcmpi(color_by, 'magnitude')
    [new_units, unit_conv] = get_unit_conversion(leg_scale, units);
    innov_mags = unit_conv * realsqrt(sum(innovs .^ 2, 1));
    if isempty(mag_ratio)
        max_innov = max(innov_mags);
    else
        sorted_innovs = sort(innov_mags);
        max_innov = sorted_innovs(int64(ceil(mag_ratio * numel(innov_mags))));
    end
    cmin = 0;
    cmax = max_innov;
    if isempty(color_map)
        temp = autumn(256);
        innov_cmap = temp(end:-1:1, :);
    else
        innov_cmap = color_map;
    end
    rows_ix = ceil(255 * min(innov_mags / max_innov, 1)) + 1;
    colors_line = innov_cmap(rows_ix, :);
    colors_pred = colors_line;
    extra_text  = ' (Colored by Magnitude)';
else
    error('Unexpected value for color_by of "%s"', color_by);
end

% create figure and axes (needs to be done before building datashader information)
fig = figure('name', [description, extra_text], 'Visible', fig_visible);
ax = axes(fig);
hold(ax, 'on');

% populate the normal plot, potentially with a subset of points
if plot_innovs
    plot(ax, points(1, :), points(2, :), '.', 'Color', colors_meas, 'DisplayName', 'Sighting');
    scatter(ax, predicts(1, :)', predicts(2, :)', [], colors_pred, 'Marker', '.', 'DisplayName', 'Predicted');
    % create fake line to add to legend
    if ischar(colors_line) || size(colors_line, 1) == 1
        % create segments
        segments = [points, predicts, nan(size(points))];
        plot(ax, segments(1, :), segments(2, :), 'Color', colors_line);
    else
        plot(ax, nan, nan, '-', 'Color', colors.black, 'DisplayName', 'Innov');
        line_group = hggroup('DisplayName', 'Innov Group');
        set(get(get(line_group,'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
        for i = 1:size(points, 2)
            h = line(ax, [points(1, i); predicts(1, i)], [points(2, i); predicts(2, i)], 'Color', colors_line(i, :), 'DisplayName', '');
            set(h, 'Parent', line_group);
        end
    end
else
    scatter(ax, points(1, :), points(2, :), [], colors_pred, 'Marker', '.', 'DisplayName', 'Sighting');
end
if add_quiver
    quiver(ax, points(1, :), points(2, :), innovs(1, :), innovs(2, :), 'Color', colors.black, 'Units', 'x', 'Scale', quiver_scale);
end
if ~strcmpi(color_by, 'none')
    clim([cmin cmax]);
    colormap(innov_cmap);
    cb = colorbar('location', 'EastOutside');
    if strcmpi(color_by, 'direction')
        cbar_units = DEGREE_SIGN;
    else
        cbar_units = new_units;
    end
    ylabel(cb, ['Innovation ', upper(color_by(1)), color_by(2:end), ' [', cbar_units, ']']);
end
title(ax, [description, extra_text]);
xlabel(ax, ['FP X Loc [', units, ']']);  % TODO: pass in X,Y labels
ylabel(ax, ['FP Y Loc [', units, ']']);
grid(ax, 'on');
if center_origin
    xlims = max(abs(xlim(ax)));
    ylims = max(abs(ylim(ax)));
    xlim(ax, [-xlims, xlims]);
    ylim(ax, [-ylims, ylims]);
end
axis(ax, 'equal');

if ~strcmpi(legend_loc, 'none')
    legend(ax, 'show', 'Location', legend_loc);
end
hold(ax, 'off');