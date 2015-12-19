function [] = display_controls(handles)

% DISPLAY_CONTROLS  determines what controls to display on the GUI.
%
% Input:
%     handles : handles structure for GUI
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
%
% Output:
%     None
%
% Prototype:
%     [game,handles] = pentago;
%     display_controls(handles);

global cur_move
global cur_game
global movelist
global gamestat

% get static globals
PLAYER = get_static_globals({'PLAYER'});

% show/hide New Game Button
if gamestat(cur_game,2) == PLAYER.none;
    set(handles.button_newgame,'Visible','off');
else
    set(handles.button_newgame,'Visible','on');
end

% show/hide Undo Button
if cur_move > 1
    set(handles.button_undo,'Visible','on');
else
    set(handles.button_undo,'Visible','off');
end

% show/hide Redo Button
if size(movelist{cur_game},1) > cur_move - 1
    set(handles.button_redo,'Visible','on');
else
    set(handles.button_redo,'Visible','off');
end