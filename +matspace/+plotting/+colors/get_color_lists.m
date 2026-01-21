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
%     color_lists = matspace.plotting.colors.get_color_lists();
%     assert(isfield(color_lists, 'vec'));
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

% Imports
import matspace.paths.get_root_dir
import matspace.plotting.colors.get_xkcd_colors

% get the XKCD colors
filename = fullfile(get_root_dir(), 'data', 'xkcd_rgb_colors.txt');
colors = get_xkcd_colors(filename);

% build the lists
color_lists           = [];
% single colors
color_lists.same      = [ 27 158 119] / 255;
color_lists.same_old  = [ 31 119 180] / 255;
color_lists.single    = [ 31 119 180] / 255;
color_lists.sing_off  = [174 199 232] / 255;
% doubles
color_lists.double    = [colors.red; colors.blue];
color_lists.dbl_off   = [colors.fuchsia; colors.cyan];
% triples
color_lists.vec       = [colors.red; colors.green; colors.blue];
color_lists.vec_off   = [colors.fuchsia; colors.lightgreen; colors.cyan];
% quads
color_lists.quat      = [colors.red; colors.green; colors.blue; colors.chocolate];
color_lists.quat_off  = [colors.fuchsia; colors.lightgreen; colors.cyan; colors.brown];
% single combinations
color_lists.sing_diff   = [color_lists.sing_off; color_lists.single];
color_lists.sing_diff_r = [color_lists.single; color_lists.sing_off];
color_lists.sing_comp   = [colors.red; colors.green; colors.blue];  % Note: this intentionally breaks the pattern
color_lists.sing_comp_r = [colors.blue; colors.green; colors.red];  % Note: this intentionally breaks the pattern
% double combinations
color_lists.dbl_diff    = [color_lists.dbl_off; color_lists.double];
color_lists.dbl_diff_r  = [color_lists.double; color_lists.dbl_off];
color_lists.dbl_comp    = [color_lists.dbl_diff; color_lists.double];
color_lists.dbl_comp_r  = [color_lists.dbl_diff_r; color_lists.double];
% triple combinations
color_lists.vec_diff    = [color_lists.vec_off; color_lists.vec];
color_lists.vec_diff_r  = [color_lists.vec; color_lists.vec_off];
color_lists.vec_comp    = [color_lists.vec_diff; color_lists.vec];
color_lists.vec_comp_r  = [color_lists.vec_diff_r; color_lists.vec];
% quad combinations
color_lists.quat_diff   = [color_lists.quat_off; color_lists.quat];
color_lists.quat_diff_r = [color_lists.quat; color_lists.quat_off];
color_lists.quat_comp   = [color_lists.quat_diff; color_lists.quat];
color_lists.quat_comp_r = [color_lists.quat_diff_r; color_lists.quat];
% Matlab's newer default color list
color_lists.default     = [[0.000 0.447 0.741]; [0.850 0.325 0.098]; [0.929 0.694 0.125]; ...
    [0.494 0.184 0.556]; [0.466 0.674 0.188]; [0.301 0.745 0.933]; [0.635 0.078 0.184]];
% Matlab's older default color list
color_lists.previous    = [[0.000 0.000 1.000]; [0.000 0.500 0.000]; [1.000 0.000 0.000]; ...
    [0.000 0.750 0.750]; [0.750 0.000 0.750]; [0.750 0.750 0.000]; [0.250 0.250 0.250]];