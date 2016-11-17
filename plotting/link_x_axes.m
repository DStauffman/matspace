function [] = link_x_axes(fig_hand)

% LINK_X_AXES  links the x axis of the specified figure handles.
%
% Summary:
%     This function loops through the specified figure handles, gets all the current
%     axes handles, and then links them using the built-in linkaxes command.
%
% Input:
%     fig_hand : (1xN) list of figure handles [num]
%
% Output:
%     None
%
% Prototype:
%     f1 = figure;
%     plot(0:5, zeros(1,6), 'b.');
%     f2 = figure;
%     plot(2:7, ones(1,6), 'r.');
%     link_x_axes([f1 f2]);
%
% See Also:
%     linkaxes
%
% Notes:
%     1.  This function only applies to the current axes in each figure.  If a figure
%         has multiple subplots, then not all of them will be linked.  If the subplots
%         are already linked to each other, then this function should work fine.
%
% Change Log:
%     1.  Written by David Stauffer in Aug 2011.
%     2.  Incorporated by David C. Stauffer into DStauffman library in Nov 2016.

% get total number of figures
n = length(fig_hand);

% return if not at least two plots
if n < 2
    return
end

% loop through figures and gather current axes
ax = zeros(1, n);
for i = 1:n
    ax(i) = get(fig_hand(i), 'CurrentAxes');
end

% link axes
linkaxes(ax, 'x');