function [color_lists] = get_color_lists()

% GET_COLOR_LISTS  returns colors that are useful for plotting two-element, three-element and
%                  four-element vector time histories and doing differences between them.
%
% Input:
%     (None)
%
% Output:
%     color_lists : (struct) Color Lists
%         .null      : (empty) Null color list
%         .one       : {1x1} of (1x3) Color list for plotting a single line
%         .two       : {2x1} of (1x3) Color list for plotting two lines
%         .vec       : {3x1} of (1x3) Color list for plotting three vector components
%         .quat      : {4x1} of (1x3) Color list for plotting four components, like a quaternion
%         .dbl_diff  : {4x1} of (1x3) Color list for comparing two 2D vectors
%         .vec_diff  : {6x1} of (1x3) Color list for comparing two 3D vectors
%         .quat_diff : {8x1} of (1x3) Color list for comparing two 4D vectors, like quaternions
%
% Prototype:
%     color_lists = get_color_lists();
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2018.

% get the XKCD colors
filename = fullfile(get_root_dir(), 'data', 'xkcd_rgb_colors.txt');
colors = get_xkcd_colors(filename);

% build the lists
color_lists           = [];
color_lists.null      = {};
color_lists.one       = {colors.red};
color_lists.two       = {colors.red; colors.blue};
color_lists.vec       = {colors.red; colors.green; colors.blue};
color_lists.quat      = {colors.red; colors.green; colors.blue; colors.chocolate};
color_lists.dbl_diff  = {colors.fuchsia; colors.cyan; colors.red; colors.blue};
color_lists.vec_diff  = {colors.fuchsia; colors.lightgreen; colors.cyan; colors.red; colors.green; colors.blue};
color_lists.quat_diff = {colors.fuchsia; colors.lightgreen; colors.cyan; colors.brown;...
    colors.red; colors.green; colors.blue; colors.chocolate};