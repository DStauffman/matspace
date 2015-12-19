function [] = close_function()

% CLOSE_FUNCTION  executes when the GUI is closed.
%
% Input:
%     global cur_move : (scalar) current move number [num]
%     global cur_game : (scalar) current game number [num]
%     global movelist : {1xN} of (Mx4) where the cell number is the game number, and the four
%                       columns are [row position, col position, quad to spin, dir to spin (1=R,0=L)]
%     global position : (6x6) current board position of all pieces
%     global gamestat : (Nx2) winning stats where row is game number, col 1 is who went first,
%                       and column two is who won [num]
%
% Output:
%     None - saves 'game' to disk to 'saved_game.mat' in current directory
%
% Prototype:
%     close_function;
%
% Written by David Stauffer in Jan 2010.

% declare globals
global cur_move
global cur_game
global movelist
global position
global gamestat

game.cur_move = cur_move;
game.cur_game = cur_game;
game.movelist = movelist;
game.position = position;
game.gamestat = gamestat;

if true
    assignin('base','game',game);
end

% save game
try
    save('saved_game.mat','game');
catch
    disp('Game could not be saved.');
end

% display closing message
disp('Quiting PENTAGO.');

% close GUI
closereq;