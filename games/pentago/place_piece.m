function []=place_piece(hObject, eventdata, handles) %#ok<INUSL>

% PLACE_PIECE  places a piece on the board.
%
% Input:
%     hObject                 : (scalar) handle to the graphics object that called this function [num]
%     eventdata               : (scalar) unused empty structure for future MATLAB expansion
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
%     global cur_game : (scalar) current game number [num]
%     global position : (6x6) current board position of all pieces
%     global gamestat : (Nx2) winning stats where row is game number, col 1 is who went first,
%                       and column two is who won [num]
%     global move_ok_ : (true/false) flag for if the move is valid [bool]
%     global move_pos : (1x2) vector of x & y positions for the potential move [enum]
%     global move_cir : (scalar) handle to the plotted piece of the potential move [num]
%
% Output:
%     global move_ok_ : (true/false) updated boolean for whether move is valid [bool]
%     global move_pos : (scalar) empty variable showing that move has been executed [n/a]
%     global move_cir : (scalar) handle to next move piece that was plotted [num]
%
% Prototype:
%     only intended for calling by the mouse click within the GUI
%
% Written by David Stauffer in Jan 2010.

% declare globals
global cur_game
global position
global gamestat
global move_ok_
global move_pos
global move_cir

% get static globals
[COLOR,PLAYER,RADIUS] = get_static_globals({'COLOR','PLAYER','RADIUS'});

% test for a game that has already been concluded
if gamestat(cur_game,2) ~= PLAYER.none;
    move_ok_ = false;
    move_pos = [];
    return
end

% test for left mouse click, and if not, ignore
if ~strcmp(get(handles.pentago_figure,'SelectionType'),'normal')
    move_ok_ = false;
    move_pos = [];
    return
else
    % get mouse position
    location = get(handles.board,'CurrentPoint');
    x = round(location(1,1));
    y = round(location(1,2));
    % check if not on game board
    if abs(x) >6 || abs(y) > 6
        move_ok_ = false;
        move_pos = [];
        return
    end
    if position(x,y) == PLAYER.none
        % check for previous good move
        if move_ok_
            delete(move_cir);
        end
        move_ok_ = true;
        move_pos = [x y];
        set(handles.pentago_figure,'CurrentAxes',handles.board);
        switch calc_cur_move
            case PLAYER.white
                move_cir = plot_piece(x,y,RADIUS.piece,COLOR.next_wht);
            case PLAYER.black
                move_cir = plot_piece(x,y,RADIUS.piece,COLOR.next_blk);
            otherwise
                error('dstauffman:pentago:BadNextMove', 'Unexpected player to move next.');
        end
    else
        % delete a previously placed piece
        if move_ok_
            delete(move_cir);
        end
        move_ok_ = false;
        move_pos = [];
    end
end