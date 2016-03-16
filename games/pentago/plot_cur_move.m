function []=plot_cur_move(handles,move)

% PLOT_CUR_MOVE  plots the player whose move is next.
%
% Input:
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
%     move                    : (scalar) current move, from {1=white, -1=black} [enum]
%
% Output:
%     None - plots the current move on the GUI
%
% Prototype:
%     [game,handles] = pentago;
%     plot_cur_move(handles);
%
% Written by David Stauffer in Jan 2010.

% get static globals
[COLOR,PLAYER,RADIUS] = get_static_globals({'COLOR','PLAYER','RADIUS'});

% make axis active
set(handles.pentago_figure,'CurrentAxes',handles.move);
set(handles.move,'NextPlot','add');

% axis bounds
xmin = -RADIUS.square;
xmax =  RADIUS.square;
ymin = -RADIUS.square;
ymax =  RADIUS.square;

% fill background
fill([xmin,xmax,xmax,xmin,xmin],[ymin,ymin,ymax,ymax,ymin],COLOR.board,'EdgeColor',COLOR.maj_edge);
axis([xmin xmax ymin ymax]);
axis equal;
axis off;

% draw piece
switch move
    case PLAYER.white
        plot_piece(0,0,RADIUS.piece,COLOR.white);
    case PLAYER.black
        plot_piece(0,0,RADIUS.piece,COLOR.black);
    case PLAYER.none
        % nop
    otherwise
        error('dstauffman:pentago:BadPlayer', 'Unexpected value for player.');
end