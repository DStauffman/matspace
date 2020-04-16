function compile_a_file(mex_dir,function_name,args_ex)

% COMPILE_A_FILE  compiles the specified file with example arguments.
%
% Summary:
%     This function compiles the specified function into the given folder, with example arguments
%     passed in.  Additionally, it displays progress updates and deletes the compiled file if it
%     previously existed.
%
% Input:
%     mex_dir ..... : (1xA) string specifying output folder location [char]
%     function_name : (1xB) string name of function [char]
%     args_ex ..... : {1xC} input parameters to given function
%
% Output:
%     (NONE)
%
% Prototype:
%     mex_dir       = matspace.paths.get_mex_dir();
%     function_name = 'get_move_inverse';
%     move          = 1;
%     args_ex       = {move};
%     % matspace.utils.compile_a_file(mex_dir, function_name, args_ex);
%
% Change Log:
%     1.  Originally designed by Tom Trankle for use in GARSE.
%     2.  Added to matspace library in August 2013.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.

% Start timer
start = tic;

% Create full file name without the file extension (compiler adds it for you)
mex_file_path      = fullfile(mex_dir,function_name);

% use 'mexext' to determine the file name (mexw32 on 32 bit windows, mexw64 on 64 bit windows)
full_mex_file_name = fullfile(mex_dir,[function_name,'.',mexext]);

% Display status
disp(['Compiling function "',function_name,'" to "',full_mex_file_name,'"']);

% Check if the file already exists and delete it
if exist(full_mex_file_name,'file')
    disp(['deleting old file "',full_mex_file_name,'"']);
    delete(full_mex_file_name);
end

% Set mex settings as a configuration object
mex_config_obj = coder.config('mex');
mex_config_obj.DynamicMemoryAllocation = 'AllVariableSizeArrays';

% Turn off parallelization warning for our compiler
warning('off','Coder:reportGen:noCompilerOpenMPSupport');

% Generate the compiled code
codegen(...
    function_name            ,...
    '-o', mex_file_path      ,...
    '-args', args_ex         ,...
    '-config',mex_config_obj ,...
    '-report');
disp(['Finished compiling file "',function_name,'"']);

% Display elapsed time.
toc(start);