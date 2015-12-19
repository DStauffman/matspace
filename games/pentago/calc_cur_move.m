function [move] = calc_cur_move()

% CALC_CUR_MOVE  calculates whose move it is based on the turn and game number.
%
% Input:
%     global cur_move : (scalar) current move number [num]
%     global cur_game : (scalar) current game number [num]
%
% Output:
%     move : (scalar) current move, from {1=white, -1=black} [enum]
%
% Prototype:
%     move = calc_cur_move;
%
% Written by David Stauffer in Jan 2010.

% declare globals
global cur_move
global cur_game
% get static globals
PLAYER = get_static_globals({'PLAYER'});

% determine whose move it is
if mod(mod(cur_move,2)+mod(cur_game,2),2);
    move = PLAYER.black;
else
    move = PLAYER.white;
end