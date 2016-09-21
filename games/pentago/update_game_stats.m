function [] = update_game_stats(handles)

% UPDATE_GAME_STATS  updates the game stats on the left of the GUI.
%
%     handles                 : handles structure for GUI
%         .pentago_figure     : handle to pentago GUI
%         .button_newgame     : handle to newgame button
%         .button_redo        : handle to redo button
%         .button_undo        : handle to undo button
%         .text_tied_num      : handle to text field for games tied number
%         .text_black_win_num : handle to text field for black wins number
%         .text_white_win_num : handle to text field for white wins number
%         .text_tied          : handle to static text field for games tied
%         .text_black_wins    : handle to static text field for black wins
%         .text_white_wins    : handle to static text field for white wins
%         .button_4L          : handle to quadrant 4, left spin
%         .button_1L          : handle to quadrant 1, left spin
%         .button_4R          : handle to quadrant 4, right spin
%         .button_3R          : handle to quadrant 3, right spin
%         .button_2L          : handle to quadrant 2, left spin
%         .button_3L          : handle to quadrant 3, left spin
%         .button_2R          : handle to quadrant 2, right spin
%         .button_1R          : handle to quadrant 1, right spin
%         .move               : handle to next move piece
%         .text_move          : handle to static text for next move
%         .text_score         : handle to static text for score
%         .text_pentago       : handle to static text for Pentago
%         .board              : handle to board
%     global gamestat         : (Nx2) winning stats where row is game number, col 1 is who went first,
%                               and column two is who won [num]
%
% Output:
%     None - updates strings on the GUI
%
% Prototype:
%     [game,handles] = pentago;
%     update_game_stats(handles);
%
% Written by David Stauffer in Jan 2010.

global gamestat

% get static globals
[PLAYER] = get_static_globals({'PLAYER'});

results    = gamestat(:,2);
white_wins = nnz(results == PLAYER.white);
black_wins = nnz(results == PLAYER.black);
tied_games = nnz(results == PLAYER.draw);

set(handles.text_white_win_num,'String',num2str(white_wins,'%i'));
set(handles.text_black_win_num,'String',num2str(black_wins,'%i'));
set(handles.text_tied_num,     'String',num2str(tied_games,'%i'));