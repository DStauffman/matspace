function [varargout] = get_static_globals(list)

% GLOBALS  is a function that establishes all the static globals in MATLAB's way.
%
% Input:
%     list : {1xN} list of variable names to return, from {'COLOR','PLAYER','RADIUS','WIN'}
%
% Output:
%     COLOR         : color enumeration, each is a 1x3 RGB triplet
%         .board    : board color
%         .win      : winning piece color
%         .white    : white piece color
%         .black    : black piece color
%         .maj_edge : major quadrant edge color
%         .min_edge : minor quadrant edge color
%         .button   : button background color
%         .gui_bkgd : gui background color
%         .next_wht : white piece next move color
%         .next_blk : black piece next move color
%         .redo     : redo piece and button color
%     PLAYER        : player enumeration, each is a scalar
%         .white    : white player
%         .black    : black player
%         .none     : no player (blank square)
%         .draw     : both players (tied game)
%     RADIUS        : size information about pieces and game squares, each is a scalar
%         .piece    : size of normal (white/black) piece
%         .win      : size of winning piece
%         .square   : size of square
%     WIN           : (36x32) array of all possible winning combinations [bool]
%
% Prototype:
%     [PLAYER,WIN] = get_static_globals({'PLAYER','WIN'});
%
% Written by David Stauffer in Jan 2010.

% The dynamic globals are:
% global cur_move
% global cur_game
% global movelist
% global position
% global gamestat
% global move_ok_
% global move_pos
% global move_cir

%% Definitions
% color definitions
COLOR.board    = [1 1 0];
COLOR.win      = [1 0 0];
COLOR.white    = [1 1 1];
COLOR.black    = [0 0 0];
COLOR.maj_edge = [0 0 0];
COLOR.min_edge = [0 0 1];
COLOR.button   = [1 1 0.75];
COLOR.gui_bkgd = [225 224 228]/255;
COLOR.next_wht = [0.6 0.6 1.0]; % [0.8 0.8 0.8]
COLOR.next_blk = [0.0 0.0 0.4]; % [0.4 0.4 0.4]
COLOR.redo     = [1.0 0.0 1.0];
COLOR.win_wht  = [1.0 0.9 0.9]; % [1.0 0.9 0.9]
COLOR.win_blk  = [0.2 0.0 0.0]; % [0.6 0.0 0.0]
COLOR.win_tie  = [1.0 0.0 0.6];
COLOR.rot_wht  = [0.0 1.0 1.0]; % COLOR.next_wht
COLOR.rot_blk  = [0.0 0.0 0.5]; % COLOR.next_blk
COLOR.rot_grey = [0.6 0.6 0.6];
COLOR.rot_move = [0.0 0.0 1.0];
COLOR.rot_undo = [0.6 0.6 1.0];

% player enumerations
PLAYER.white = 1;
PLAYER.black = -1;
PLAYER.none  = 0;
PLAYER.draw  = 2;

% sizes of the different pieces and squares
RADIUS.piece  = 0.45;
RADIUS.next   = 0.35;
RADIUS.move   = 0.30;
RADIUS.win    = 0.25;
RADIUS.square = 0.5;

% all possible winning combinations
WIN = logical([...
    1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0;...
    1 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0;...
    1 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;...
    1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;...
    1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0;...
    0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0;...
    ...
    0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0;...
    0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 1 0 0 0 0 0 0;...
    0 1 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0;...
    0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0;...
    0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 1 1 0 0 0 0;...
    0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 1;...
    ...
    0 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0;...
    0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 1 1 0 0 0 0 1 0;...
    0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 1 0 1 0 0;...
    0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1;...
    0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0;...
    ...
    0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 1 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0;...
    0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 1 1 0 0 0;...
    0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 1 1 0 0 0 0 0 1;...
    0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0;...
    0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0;...
    ...
    0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0;...
    0 0 0 0 1 0 0 0 0 0 1 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 1 1 0 0 0 0;...
    0 0 0 0 1 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1;...
    0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0;...
    0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 1 1 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0;...
    ...
    0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0;...
    0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1;...
    0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0;...
]);

%% Output
switch nargin
    case 0
        assignin('base','COLOR',COLOR);
        assignin('base','PLAYER',PLAYER);
        assignin('base','RADIUS',RADIUS);
        assignin('base','WIN',WIN);
    case 1
        for i=1:length(list)
            switch list{i}
                case 'COLOR'
                    varargout{i} = COLOR;
                case 'PLAYER'
                    varargout{i} = PLAYER;
                case 'RADIUS'
                    varargout{i} = RADIUS;
                case 'WIN'
                    varargout{i} = WIN;
                otherwise
                    error(['Unexpected value of ''',list{i},'''to return']);
            end
        end
    otherwise
        error('Unexpected number of inputs');
end