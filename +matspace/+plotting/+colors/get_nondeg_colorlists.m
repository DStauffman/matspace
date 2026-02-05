function [clist] = get_nondeg_colorlists(num_channels)

% Get a nice colormap for the given number of channels to plot and use for non-deg comparisons.
%
% Input:
%     num_channels : int
%         Number of channels to plot
%
% Output:
%     clist : matplotlib.colors.ListedColormap
%         Ordered colormap with the given list of colors (times three)
%
% Prototype:
%     num_channels = 2;
%     clist = matspace.plotting.colors.get_nondeg_colorlists(num_channels);
%     colors = matspace.plotting.colors.get_xkcd_colors();
%     assert(all(clist(1, :) == colors.red));
%     assert(all(clist(3, :) == colors.fuchsia));
%
% Notes:
%     1.  This function returns three times the number of colors you need, with the first two sets
%         visually related to each other, and the third as a repeat of the first.
%
% Change Log:
%     1.  Written by David C. Stauffer in March 2021.
%     2.  Translated into Matlab by David C. Stauffer in February 2026.

import matspace.plotting.colors.get_color_lists
import matspace.plotting.colors.get_xkcd_colors
import matspace.plotting.colors.tab20
import matspace.utils.modd

color_lists = get_color_lists();
colors = get_xkcd_colors();

switch num_channels
    case 1
        clist = [color_lists.single; colors.blue; color_lists.single];
    case 2
        clist = color_lists.dbl_comp_r;
    case 3
        clist = color_lists.vec_comp_r;
    case 4
        clist = color_lists.quat_comp_r;
    otherwise
        tab_colors = tab20();
        primary = tab_colors(1:2:end, :);
        secondary = tab_colors(2:2:end, :);
        rows = modd(1:num_channels, 10);
        clist = [primary(rows, :); secondary(rows, :); primary(rows, :)];
end