function varargout = pentago(varargin)

% PENTAGO  is M-file for pentago.fig, and runs the pentago game.
%
% Input:
%     (used for internal calling only)
%
% Output:
%     game          : structure of full game state
%         (where N = number of games, M = number of moves in game)
%         .cur_move : (scalar) current move number [num]
%         .cur_game : (scalar) current game number [num]
%         .movelist : {1xN} of (Mx4) where the cell number is the game number, and the four
%                     columns are [row position, col position, quad to spin, dir to spin (1=R,0=L)]
%         .position : (6x6) current board position of all pieces
%         .gamestat : (Nx2) winning stats where row is game number, col 1 is who went first,
%                     and column two is who won [num]
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
%
% Prototype:
%     [game,handles] = pentago;
%
% Written by David Stauffer in Jan 2010 based on the existing board game Pentago.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct(...
    'gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @pentago_OpeningFcn, ...
    'gui_OutputFcn',  @pentago_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%% Main Function
function pentago_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% --- Executes just before pentago is made visible.

% declare dynamic globals
global cur_move
global cur_game
global movelist
global position
global gamestat
% declare and check for leftover temporary globals
global move_ok_
global move_pos
global move_cir
move_ok_ = false;
move_pos = [];
move_cir = [];
% declare static globals
[PLAYER] = get_static_globals({'PLAYER'});
% load options or if not found, create defaults
if exist('options.mat','file')
    load('options.mat','OPTIONS');
else
    OPTIONS = create_options;
end
% draw turn arrows
draw_turn_arrows(handles);
% ask to load saved game
if exist('saved_game.mat','file')
    switch OPTIONS.load_previous_game
        case 'Yes'
            load_previous = true;
        case 'No'
            load_previous = false;
        case 'Ask'
            % choose to load previous game
            choice = questdlg('Do you want to resume the last game?', ...
                'Resume Previous Game', ...
                'Yes','No','No');
            % Handle response
            switch choice
                case 'Yes'
                    load_previous = true;
                case 'No'
                    load_previous = false;
            end
        otherwise
            error('Unexpected value for of ''"%s"'' for ''OPTIONS.load_previous_game''',OPTIONS.load_previous_game);
    end
else
    load_previous = false;
end
% load previous game or create a new one
if load_previous
    load('saved_game.mat','game');
    cur_move = game.cur_move;
    cur_game = game.cur_game;
    movelist = game.movelist;
    position = game.position;
    gamestat = game.gamestat;
else
    cur_move = 1;
    cur_game = 1;
    movelist = {};
    movelist{cur_game} = zeros(0,4);
    position = zeros(6,6);
    gamestat = [PLAYER.white, PLAYER.none];
end
% plot board
plot_board(handles,position);
% display playing status
disp('Playing PENTAGO.');
% update gui
guidata(hObject, handles);


%% Output
function varargout = pentago_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% --- Outputs from this function are returned to the command line.
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
varargout{1}  = game;
varargout{2}  = handles;


%% Rotation Buttons
function button_1R_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% --- Executes on button press in button_1R.
execute_move(handles,1,1);
guidata(hObject, handles);

function button_2R_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% --- Executes on button press in button_2R.
execute_move(handles,2,1);
guidata(hObject, handles);

function button_3R_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% --- Executes on button press in button_3R.
execute_move(handles,3,1);
% update gui
guidata(hObject, handles);

function button_4R_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% --- Executes on button press in button_4R.
execute_move(handles,4,1);
guidata(hObject, handles);

function button_1L_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% --- Executes on button press in button_1L.
execute_move(handles,1,0);
guidata(hObject, handles);

function button_2L_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% --- Executes on button press in button_2L.
execute_move(handles,2,0);
guidata(hObject, handles);

function button_3L_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% --- Executes on button press in button_3L.
execute_move(handles,3,0);
guidata(hObject, handles);

function button_4L_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% --- Executes on button press in button_4L.
execute_move(handles,4,0);
guidata(hObject, handles);


%% Push Buttons
function button_undo_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% --- Executes on button press in button_undo.

% declare globals
global cur_move
global cur_game
global movelist
global position
% get static globals
PLAYER = get_static_globals({'PLAYER'});
% get last move
last_move = movelist{cur_game}(cur_move-1,:);
% undo rotation
dir      = mod(last_move(4)+1,2);
position = rotate_board(position,last_move(3),dir);
% delete piece
position(last_move(1),last_move(2)) = PLAYER.none;
% update current move
cur_move = cur_move - 1;
% plot board
plot_board(handles,position);
% update gui
guidata(hObject, handles);


function button_redo_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% --- Executes on button press in button_redo.

% declare globals
global cur_move
global cur_game
global movelist
global position
% get next move
redo_move = movelist{cur_game}(cur_move,:);
% place piece
position(redo_move(1),redo_move(2)) = calc_cur_move;
% redo rotation
position = rotate_board(position,redo_move(3),redo_move(4));
% update current move
cur_move = cur_move + 1;
% plot board
plot_board(handles,position);
% update gui
guidata(hObject, handles);


function button_newgame_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% --- Executes on button press in button_newgame.

% declare globals
global cur_move
global cur_game
global gamestat
global movelist
global position
% get static globals
PLAYER = get_static_globals({'PLAYER'});
% update values
last_lead = gamestat(cur_game,1);
next_lead = mod(last_lead+1,2);
cur_game = cur_game + 1;
cur_move = 1;
gamestat(cur_game,:) = [next_lead PLAYER.none];
movelist{cur_game} = zeros(0,4);
position = zeros(6,6);
% plot board
plot_board(handles,position);
% update gui
guidata(hObject, handles);
