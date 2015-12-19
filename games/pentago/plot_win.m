function []=plot_win(position)

% PLOT_WIN  plots the winning pieces in red.
%
% Input:
%     position : (6x6) board position [num]
%
% Output:
%     None - plots any winning pieces
%
% Prototype:
%     position = reshape([1 1 1 1 1 0 zeros(1,30)]);
%     plot_win(position);
%
% Written by David Stauffer in Jan 2010.

% get static globals
[COLOR,RADIUS] = get_static_globals({'COLOR','RADIUS'});

% loop through all squares on the board
[n,m] = size(position);
for i=1:n
    for j=1:m
        % plot the winning pieces
        if position(i,j)
            plot_piece(i,j,RADIUS.win,COLOR.win);
        end
    end
end