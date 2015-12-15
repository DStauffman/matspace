%% Compile as much as possible

%% Setup
mex_dir        = get_mex_dir();
max_board_size = 50;
rmpath(get_mex_dir());

%% Example variables
board          = coder.typeof(PIECE_.null,[max_board_size max_board_size],[1 1]);
move           = 0;
transports     = coder.typeof(0, [1 2], [0 1]);
start_pos      = 0;
pos            = 0;
board_size     = [0 0];
costs          = coder.typeof(0,[max_board_size max_board_size],[1 1]);

%% Compile functions
function_name = 'get_new_position';
args_ex       = {board_size, pos, move, transports};
compile_a_file(mex_dir, function_name, args_ex);

%%
function_name = 'classify_move';
args_ex       = {board, move, transports, start_pos, board_size};
compile_a_file(mex_dir, function_name, args_ex);

%%
function_name = 'get_move_inverse';
args_ex       = {move};
compile_a_file(mex_dir, function_name, args_ex);

%%
function_name = 'update_board';
args_ex       = {board, move, costs, transports, start_pos, board_size};
compile_a_file(mex_dir, function_name, args_ex);

%%
function_name = 'initialize_data';
args_ex = {board};
%compile_a_file(mex_dir, function_name, args_ex);

function_name  = 'solve_min_puzzle';
args_ex        = {board};
%compile_a_file(mex_dir, function_name, args_ex);