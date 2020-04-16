function [] = show_zero_ylim(ax)

% SHOW_ZERO_YLIM  forces a plot to always show the value of zero within the limits.
%
% Input:
%     ax : (struct) axis handle
%
% Output:
%     (None)
%
% Prototype:
%     % create figure and plot data that doesn't show the origin
%     fig = figure;
%     ax = axes;
%     plot(ax, 0:10, rand(3, 11) + 5);
%     % call the function to show the origin
%     matspace.plotting.show_zero_ylim(ax);
%
% See Also:
%     ylim
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2019.
%     2.  Updated by David C. Stauffer in April 2020 to fully specify which axes it is operating on.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.

% force to show zero
ylims = ylim(ax);
if ylims(1) > 0
    ylim(ax, [0 ylims(2)]);
end
if ylims(2) < 0
    ylim(ax, [ylims(1) 0]);
end