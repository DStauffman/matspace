function [] = plot_board(handles,position)

% PLOT_BOARD  is the main pentago function, which plots the game board.
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
%     position                : (6x6) board position [num]
%
% Output:
%     None - plots board on the GUI
%
% Prototype:
%     [game,handles] = pentago;
%     plot_board(handles);
%
% Written by David Stauffer in Jan 2010.

% get static globals
[COLOR,PLAYER,RADIUS] = get_static_globals({'COLOR','PLAYER','RADIUS'});

% plot current move
move = calc_cur_move;
plot_cur_move(handles,move);

% draw turn arrow
draw_turn_arrows(handles);

% make the board the current axis
set(handles.pentago_figure,'CurrentAxes',handles.board);
set(handles.pentago_figure,'NextPlot','add');
set(handles.board,'NextPlot','add');
set(handles.board,'YDir','reverse');

% delete any existing children
h = allchild(handles.board);
delete(h);

% set button click behavior
set(handles.pentago_figure,'WindowButtonDownFcn',{@place_piece,handles});

% set closing behavior
set(handles.pentago_figure,'CloseRequestFcn','close_function;');

% get axes limits
[n,m] = size(position);
s     = RADIUS.square;
xmin  = 1 - s;
xmax  = n + s;
ymin  = 1 - s;
ymax  = m + s;

% fill blank board
fill([xmin,xmax,xmax,xmin,xmin],[ymin,ymin,ymax,ymax,ymin],COLOR.board,...
    'EdgeColor',COLOR.maj_edge,'HitTest','off');
% adjust axes
axis([xmin xmax ymin ymax]);
axis equal;
axis off;
% set view to flip X & Y axes to fit MATLAB columnwise standard
set(handles.board,'View',[-90 -90]);

% draw minor horizontal lines
plot([2-s 2-s],[ymin ymax],'Color',COLOR.min_edge);
plot([3-s 3-s],[ymin ymax],'Color',COLOR.min_edge);
plot([5-s 5-s],[ymin ymax],'Color',COLOR.min_edge);
plot([6-s 6-s],[ymin ymax],'Color',COLOR.min_edge);
% draw minor vertical lines
plot([xmin xmax],[2-s 2-s],'Color',COLOR.min_edge);
plot([xmin xmax],[3-s 3-s],'Color',COLOR.min_edge);
plot([xmin xmax],[5-s 5-s],'Color',COLOR.min_edge);
plot([xmin xmax],[6-s 6-s],'Color',COLOR.min_edge);
% draw major quadrant lines
plot([4-s 4-s],[ymin ymax],'Color',COLOR.maj_edge,'LineWidth',2);
plot([xmin xmax],[4-s 4-s],'Color',COLOR.maj_edge,'LineWidth',2);

% loop through and place marbles
for i=1:n
    for j=1:m
        if position(i,j) == PLAYER.none;
            % nop
        elseif position(i,j) == PLAYER.white;
            plot_piece(i,j,RADIUS.piece,COLOR.white);
        elseif position(i,j) == PLAYER.black;
            plot_piece(i,j,RADIUS.piece,COLOR.black);
        else
            error('Bad board position');
        end
    end
end

% check for win
winner = check_for_win(position);

% display relevant controls
display_controls(handles);

% plot possible winning moves
if true && winner == PLAYER.none;
    moves = find_moves(position);
    plot_possible_win(handles,moves);
end

% update game stats on gui
update_game_stats(handles);