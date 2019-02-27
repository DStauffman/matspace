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
%     show_zero_ylim(ax);
%
% See Also:
%     ylim
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2019.

% force to show zero
ylims = ylim(ax);
if ylims(1) > 0
    ylim([0 ylims(2)]);
end
if ylims(2) < 0
    ylim([ylims(1) 0]);
end