function [] = plot_possible_win(handles,moves)

% PLOT_POSSIBLE_WIN  plots the possible wins on the board.
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
%     moves         : (struct) potential moves
%         .white    : (struct) possible white moves
%             .x    : (1xN) vector of x locations on board [enum]
%             .y    : (1xN) vector of y locations on board [enum]
%             .quad : (1xN) vector of quadrants to rotate [enum]
%             .dir  : (1xN) vector of directions to spin [enum]
%             .pwr  : (1xN) vector of move power [num]
%         .black    : (struct) possible black moves
%             .x    : (1xN) vector of x locations on board [enum]
%             .y    : (1xN) vector of y locations on board [enum]
%             .quad : (1xN) vector of quadrants to rotate [enum]
%             .dir  : (1xN) vector of directions to spin [enum]
%             .pwr  : (1xN) vector of move power [num]
%
% Output:
%     None - plots possible winning moves to the GUI
%
% Prototype:
%     [game,handles] = pentago;
%     position = reshape([0 0 0 0 0 0 0 1 0 1 1 1 zeros(1,24)],6,6);
%     moves    = find_moves(position);
%     plot_possible_win(handles,moves);
%
% Written by David Stauffer in Feb 2010.

% load static globals
PLAYER = get_static_globals({'PLAYER'});

% find overlapping pieces
pos_white = moves.white.x + 6*(moves.white.y-1);
pos_black = moves.black.x + 6*(moves.black.y-1);

% find overlapping quadrant rotations
rot_white = moves.white.quad + 4*moves.white.dir;
rot_black = moves.black.quad + 4*moves.black.dir;

% if it's white's turn, then draw the white wins last, so they show on top of black wins
% and draw last moves as half pieces if they overlap
cur_move = calc_cur_move;
if cur_move == PLAYER.white
    order = [2 1];
    half_piece_white = ismember(pos_white,pos_black);
    half_piece_black = false(size(moves.black.x));
    half_arrow_white = -ismember(rot_white,rot_black);
    half_arrow_black = ismember(rot_black,rot_white);
else
    order = [1 2];
    half_piece_white = false(size(moves.white.x));
    half_piece_black = ismember(pos_black,pos_white);
    half_arrow_white = ismember(rot_white,rot_black);
    half_arrow_black = -ismember(rot_black,rot_white);
end

% loop through and plot possible wins
for i=1:length(order)
    switch order(i)
        case 1
            plot_pos_win(handles,moves.white.x,moves.white.y,moves.white.quad,moves.white.dir,...
                moves.white.pwr,PLAYER.white,half_piece_white,half_arrow_white);
        case 2
            plot_pos_win(handles,moves.black.x,moves.black.y,moves.black.quad,moves.black.dir,...
                moves.black.pwr,PLAYER.black,half_piece_black,half_arrow_black);
    end
end


%% Subfunction 1
function [] = plot_pos_win(handles,x,y,quad,dir,pwr,player,half_piece,half_arrow)

% PLOT_POSSIBLE_WIN  plots the possible wins on the board

% get static globals
[COLOR,RADIUS,PLAYER] = get_static_globals({'COLOR','RADIUS','PLAYER'});

% get the appropriate player color
switch player
    case PLAYER.white
        color   = COLOR.win_wht;
        rot_col = repmat(COLOR.rot_wht,length(x),1);
    case PLAYER.black
        color   = COLOR.win_blk;
        rot_col = repmat(COLOR.rot_blk,length(x),1);
    otherwise
        error('Unexpected value for player');
end
tie_col = COLOR.win_tie;
tie_ix  = find(isnan(pwr));
rot_col(tie_ix,:) = repmat(tie_col,length(tie_ix),1);

% plot the winning moves in backwards order, so wins replace ties
set(handles.pentago_figure,'CurrentAxes',handles.board);
for i = length(x):-1:1
    if pwr(i) >= 5
        plot_piece(x(i),y(i),RADIUS.win,color,half_piece(i));
    elseif isnan(pwr(i))
        plot_piece(x(i),y(i),RADIUS.win,COLOR.win_tie,half_piece(i));
    end
end

% plot the winning rotations
[rot_win,rot_ix] = unique(quad+4*dir,'last');
for i = 1:length(rot_win)
    switch rot_win(i)
        case 1 % quad 1, dir 0
            plot_rot_color(handles.button_1L,rot_col(rot_ix(i),:),half_arrow(rot_ix(i)));
        case 2 % quad 2, dir 0
            plot_rot_color(handles.button_2L,rot_col(rot_ix(i),:),half_arrow(rot_ix(i)));
        case 3 % quad 3, dir 0
            plot_rot_color(handles.button_3L,rot_col(rot_ix(i),:),half_arrow(rot_ix(i)));
        case 4 % quad 4, dir 0
            plot_rot_color(handles.button_4L,rot_col(rot_ix(i),:),half_arrow(rot_ix(i)));
        case 5 % quad 1, dir 1
            plot_rot_color(handles.button_1R,rot_col(rot_ix(i),:),half_arrow(rot_ix(i)));
        case 6 % quad 2, dir 1
            plot_rot_color(handles.button_2R,rot_col(rot_ix(i),:),half_arrow(rot_ix(i)));
        case 7 % quad 3, dir 1
            plot_rot_color(handles.button_3R,rot_col(rot_ix(i),:),half_arrow(rot_ix(i)));
        case 8 % quad 4, dir 1
            plot_rot_color(handles.button_4R,rot_col(rot_ix(i),:),half_arrow(rot_ix(i)));
        otherwise
            error('Unexpected value for rotation');
    end
end


%% Subfunction 2
function [] = plot_rot_color(rot_hand,color,half)

% PLOT_ROT_COLOR  plots the rotation arrow in the specified color

% get static globals
COLOR = get_static_globals({'COLOR'});
% get current color scheme
cdata = get(rot_hand,'CData');
[x1,x2,x3] = size(cdata);
% find values in old scheme that match the specified background color
temp(1,1,:) = round(COLOR.button*255);
temp = repmat(temp,x1,x2);
map_log = all(cdata == temp,3);
switch half
    case 0
        % nop
    case 1
        % cut out the left half
        map_log(:,1:ceil(x1/2))   = false;
    case -1
        % cut out the right half
        map_log(:,ceil(x1/2):end) = false;
    otherwise
        error('Unexpected value for half');
end
% convert logical array to index numbers
map = find(map_log);
% initialize new color scheme
color_rep = cdata;
for i=1:x3
    color_rep(map+(x1*x2*(i-1))) = round(255*color(i));
end
% limit values for saturation
color_rep(color_rep > 255) = 255;
color_rep(color_rep < 0)   = 0;
% cast result back to uint8 for appriate scaling
color_rep = cast(color_rep,'uint8');
% update button
set(rot_hand,'CData',color_rep);