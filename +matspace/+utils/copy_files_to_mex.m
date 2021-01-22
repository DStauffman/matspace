function [] = copy_files_to_mex(package_root, function_name, output_dir, replacements)

% COPY_FILES_TO_MEX  copies files from within a Matlab package into the given output_dir.  It also
%                    reads the files recursively for any imports, and also copies them into the
%                    folder, while stripping the imports from the source code.  Note that this is
%                    necessary because MATLAB is stupid and hasn't managed to fix this since 2012!!
%
% Input:
%     (TBD)
%
% Output:
%     (TBD)
%
% Prototype:
%     package_root = matspace.paths.get_root_dir();
%     function_name = 'matspace.utils.calculate_bin';
%     output_dir = fullfile(matspace.paths.get_output_dir, 'temp_mex');
%     matspace.utils.setup_dir(output_dir);
%     matspace.utils.copy_files_to_mex(package_root, function_name, output_dir);
%
%     % clean-up
%     matspace.utils.setup_dir(output_dir);
%     delete(output_dir);
%
% See Also:
%     matspace.utils.compile_a_file
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2020.

%% Imports
import matspace.utils.copy_files_to_mex % Note: calls itself recursively
import matspace.utils.read_text_file
import matspace.utils.write_text_file

%% Optional inputs
switch nargin
    case 3
        replacements = strings(0, 2);
    case 4
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

%% Setup information
% TODO: clean-up for Matlab R2019B
temp         = split(function_name, '.');
temp_path    = join("+" + temp(1:end-1), filesep);
temp_name    = temp(end) + ".m";
old_filename = fullfile(package_root, temp_path, temp_name);
new_filename = fullfile(output_dir, temp_name);

% check if the file already exists, and if so don't process it
% (since we call ourselves recursively, we only want to do a file the first time)
if isfile(new_filename)
    return
end

%% Display status
disp(['Processing: ',function_name]);

%% Read data and preallocate variables
old_lines = read_text_file(old_filename);
new_lines = strings(0, 1);
dependencies = strings(0);

%% Loop through and process file lines
for i = 1:length(old_lines)
    this_line = old_lines{i};
    if startsWith(strtrim(this_line), 'import ')
        % this is a dependency
        % drop any comments first
        if contains(this_line, '%')
            ix = strfind(this_line, '%');
            this_line = this_line(1:ix-1);
        end
        names = split(this_line, ' ');
        for j = 2:length(names)
            this_name = names{j};
            if ~isempty(this_name)
                dependencies(end+1) = this_name; %#ok<AGROW>
            end
        end
    else
        for j = 1:size(replacements, 1)
            if startsWith(this_line, replacements{j, 1})
                this_line = strrep(this_line, replacements{j, 1}, replacements{j, 2});
            end
        end
        new_lines(end+1, 1) = this_line; %#ok<AGROW>
    end
end

%% write the new file, minus the import statements
write_text_file(new_filename, new_lines);

%% process dependencies recursively
for i = 1:length(dependencies)
    this_dep = dependencies{i};
    copy_files_to_mex(package_root, this_dep, output_dir, replacements);
end