function [winner] = check_for_win(position)

% CHECK_FOR_WIN  checks for a win and plots it on the board.
%
% Input:
%     position : (6x6) current board position of all pieces
%     global cur_game : (scalar) current game number [num]
%     global gamestat : (Nx2) winning stats where row is game number, col 1 is who went first,
%                             and column two is who won [num]
%
% Output:
%     winner          : (scalar) winner, from {-1:2} = {black,none,white,draw} [enum]
%     global gamestat : (Nx2) updated winning stats [num]
%
% Prototype:
%     position = reshape([1 1 1 1 1 0 zeros(1,30)],6,6);
%     check_for_win(position);
%
% Written by David Stauffer in Jan 2010.
% Updated by David Stauffer in Mar 2010 to check for a full game board tie position.

% declare globals
global cur_game
global gamestat

% get static globals
[PLAYER,WIN] = get_static_globals({'PLAYER','WIN'});

% repeat position matrix to match all possible winning combinations
pos_big = repmat(position(:),1,size(WIN,2));

% cross reference two matrices with element-wise multiplication
test = pos_big .* WIN;

% find white and black wins
white = find(sum(test,1) ==  5);
black = find(sum(test,1) == -5);

% determine winner
if isempty(white)
    if isempty(black)
        winner = PLAYER.none;
    else
        winner = PLAYER.black;
    end
else
    if isempty(black)
        winner = PLAYER.white;
    else
        winner = PLAYER.draw;
    end
end

% check for a full game board after determining no other win was found
if winner == PLAYER.none && ~any(any(position == PLAYER.none))
    winner = PLAYER.draw;
end

% find winning pieces on the board
if winner == PLAYER.none
    win_pos = false(6,6);
else
    win_pos = logical(reshape(sum(WIN(:,white),2)+sum(WIN(:,black),2),6,6));
end

% plot win and update statistics
gamestat(cur_game,2) = winner;
plot_win(win_pos);