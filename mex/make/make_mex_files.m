% folder information
package_root = matspace.paths.get_root_dir();
library_root = fullfile(package_root, '+matspace');
mex_dir      = matspace.paths.get_mex_dir();
m_copy_dir   = fullfile(mex_dir, 'make');

% find all the codegen files
all_files = dir(fullfile(library_root, '**', '*.m'));
ix = false(size(all_files));
for i = 1:length(all_files)
    this_file = fullfile(all_files(i).folder, all_files(i).name);
    this_text = matspace.utils.read_text_file(this_file);
    if contains(this_text{1}, '%#codegen')
        ix(i) = true;
    end
end
coder_files = all_files(ix);

% copy in the temporary files
len_root = length(package_root) + 2;
for i = 1:length(coder_files)
    this_file = fullfile(coder_files(i).folder, coder_files(i).name);
    this_lib_name = strrep(strrep(this_file(len_root:end-2), '+', ''), filesep, '.');
    matspace.utils.copy_files_to_mex(package_root, this_lib_name, m_copy_dir);
end

% make the mex files
matspace.utils.setup_dir(mex_dir, false, true);
for i = 1:length(coder_files)
    this_file = fullfile(coder_files(i).folder, coder_files(i).name);
    [~, function_name] = fileparts(this_file);
    try
        args_ex = get_args_ex(function_name);
    catch exception
        if strcmp(exception.identifier, 'matspace:mex:unknownFunction')
            fprintf(1, 'Skipping %s\n', function_name);
            continue
        end
        rethrow(exception);
    end
    matspace.utils.compile_a_file(mex_dir, function_name, args_ex);
end

% optionally copy mex files back into library folders
for i = 1:length(coder_files)
    orig_file = fullfile(coder_files(i).folder, coder_files(i).name);
    [~, function_name] = fileparts(orig_file);
    mex_file = fullfile(mex_dir, [function_name,'.',mexext]);
    rep_file = fullfile(mex_dir, [orig_file(length(package_root) + 1:end-1), mexext]);
    rep_folder = fileparts(rep_file);
    if ~isfolder(rep_folder)
        matspace.utils.setup_dir(rep_folder, false, false);
    end
    if isfile(mex_file)
        copyfile(mex_file, rep_file, 'f');
    end
end



%% Subfunctions - get_args_ex
function [args_ex] = get_args_ex(function_name)

arguments
    function_name {mustBeTextScalar}
end

% max_char_size   = 100;
max_vec3_size   = 10000;
max_quat_size   = 10000;
max_vector_size = 10000;
small_vec_size  = 1000;
% large_vec_size  = 1000000;
scalar          = 1;
boolean         = true;
% chr             = coder.typeof('x', [1, max_char_size], [0 1]);
% str             = "text";
row_vector      = coder.typeof(0, [1 max_vector_size], [0 1]);
sm_row_vec      = coder.typeof(0, [1 small_vec_size], [0 1]);
% lg_row_vec      = coder.typeof(0, [1 large_vec_size], [0 1]);
col_vector      = coder.typeof(0, [max_vector_size 1], [1 0]);
% sm_col_vec      = coder.typeof(0, [small_vec_size 1], [1 0]);
% lg_col_vec      = coder.typeof(0, [large_vec_size 1], [1 0]);
% matrix          = coder.typeof(0, [max_vector_size, max_vector_size], [1 1]);
single_vec3     = [0; 0; 0];
single_quat     = [0; 0; 0; 1];
multi_vec3      = coder.typeof(0, [3 max_vec3_size], [0 1]);
multi_quat      = coder.typeof(0, [4 max_quat_size], [0 1]);

switch function_name
    case 'betarnd_mex'
        args_ex = {scalar, scalar, scalar, scalar};
    case 'cat_counts'
        args_ex = {col_vector, sm_row_vec};
    case 'discretize_mex'
        args_ex = {col_vector, sm_row_vec, boolean};
    case 'gamrnd_mex'
        args_ex = {scalar, scalar, scalar, scalar};
    case 'histcounts_mex'
        args_ex = {col_vector, sm_row_vec};
    case 'int2str_mex'
        args_ex = {scalar};
    case 'normrnd_mex'
        args_ex = {scalar, scalar, scalar, scalar};
    case 'drot_matlab'
        args_ex = {scalar, scalar};
    case 'qrot'
        args_ex = {row_vector, row_vector};
    case 'quat_angle_diff'
        args_ex = {multi_quat, multi_quat};
    case 'quat_from_euler'
        args_ex = {multi_vec3, [1 2 3]};
    % case 'quat_interp'
    %     args_ex = {row_vector, multi_quat, row_vector, boolean};  % TODO: need to swap some lines!!
    case 'quat_interp_single'
        args_ex = {zeros(1, 2), zeros(4, 2), scalar};
    case 'quat_inv'
        args_ex = {multi_quat};
    case 'quat_mult'
        args_ex = {multi_quat, multi_quat};
    case 'quat_mult_single'
        args_ex = {single_quat, single_quat};
    case 'quat_norm'
        args_ex = {multi_quat};
    case 'quat_prop'
        args_ex = {single_quat, single_vec3, boolean};
    case 'quat_times_single_vector'
        args_ex = {multi_quat, single_vec3};
    case 'quat_times_vector'
        args_ex = {multi_quat, multi_vec3};
    case 'quat_to_dcm'
        args_ex = {single_quat};
    case 'rot'
        args_ex = {scalar, scalar};
    % case 'intersect2'
    %     args_ex = {row_vector, row_vector, scalar, chr, chr};  % TODO: need to debug
    otherwise
        error('matspace:mex:unknownFunction', 'Unexpected function.');
end
end