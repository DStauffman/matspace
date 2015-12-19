function execute_move(handles,quad,dir)

% EXECUTE_MOVE  tests and then executes a move.
%
% Input:
%     handles         : handles structure for GUI
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
%     quad            : (scalar) quadrant to rotate [enum]
%     dir             : (scalar) direction to rotate [enum]
%     global cur_move : (scalar) current move number [num]
%     global cur_game : (scalar) current game number [num]
%     global movelist : {1xN} of (Mx4) where the cell number is the game number, and the four
%                       columns are [row position, col position, quad to spin, dir to spin (1=R,0=L)]
%     global position : (6x6) current board position of all pieces
%     global gamestat : (Nx2) winning stats where row is game number, col 1 is who went first,
%                       and column two is who won [num]
%     global move_ok_ : (true/false) flag for if the move is valid [bool]
%     global move_pos : (1x2) vector of x & y positions for the potential move [enum]
%     global move_cir : (scalar) handle to the plotted piece of the potential move [num]
%
% Output:
%     global cur_move : (scalar) updated current move number [num]
%     global movelist : {1xN} of (Mx4) updated movelist history
%     global position : (6x6) updated board position [num]
%     global move_ok_ : (true/false) updated boolean for whether move is valid [bool]
%     global move_pos : (scalar) empty variable showing that move has been executed [n/a]
%
% Prototype:
%     [game,handles] = pentago;
%     execute_move(handles,1,1);
%
% Written by David Stauffer in Jan 2010.

% declare globals
global cur_move
global cur_game
global movelist
global position
global move_ok_
global move_pos
global move_cir

% execute move
if move_ok_
    % delete gray piece
    delete(move_cir);
    % add new piece to position
    position(move_pos(1),move_pos(2)) = calc_cur_move;
    % rotate board
    position = rotate_board(position,quad,dir);
    % increment move list
    movelist{cur_game}(cur_move,:) = [move_pos(1), move_pos(2), quad, dir];
    % check and delete 'redo' moves that no longer applay
    if size(movelist{cur_game},1) > cur_move
        movelist{cur_game}(cur_move+1:end,:) = [];
    end
    % increment current move
    cur_move = cur_move + 1;
    % reset globals for next move
    move_ok_ = false;
    move_pos = [];
    % update board
    plot_board(handles,position)
end