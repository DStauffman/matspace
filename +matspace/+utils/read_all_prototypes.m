function [counter] = read_all_prototypes(folder, recursive, fid, counter, kwargs)

% READ_ALL_PROTOTYPES  reads all the prototypes from the specified folder
%
% SUMMARY:
%     (TBD)
%
% Input:
%     folder .... : (row) string specifying the folder name [char]
%     recursive . : (scalar) true/false flag for whether processing recursively [bool]
%     fid ....... : (scalar) file identifier [num]
%     counter ... : (scalar) function counter to start from [num]
%     KeyWords .. :
%         verbose : (scalar) true/false flag for whether to print the status to the screen [bool]
%
% Output:
%     counter   : final counter of prototypes found [num]
%     Also writes results to file
%
% Prototype:
%     folder    = matspace.paths.get_root_dir();
%     recursive = true;
%     matspace.utils.read_all_prototypes(folder, recursive, Verbose=true);
%
% Change Log:
%     1.  Written by David C. Stauffer circa 2011.
%     2.  Incorporated by David C. Stauffer into matspace library in Dec 2016.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.
%     4.  Updated by David C. Stauffer in January 2026 to use arguments and have a verbose option.

% Arguments
arguments
    folder {mustBeTextScalar} = pwd
    recursive (1, 1) logical = true
    fid {mustBeScalarOrEmpty} = []
    counter (1, 1) double = 0
    kwargs.Verbose (1, 1) logical = false
end
verbose = kwargs.Verbose;

% Imports
import matspace.utils.read_all_prototypes  % calls itself recursively

% hard-coded inputs
folder_exclusions = ["new", "tests"];
file_exclusions   = ["all_prototypes", "read_all_prototypes"];
ignore_classes    = true;

% open file if not already specified
if isempty(fid)
    filename = fullfile(pwd,'all_prototypes.m');
    if verbose
        fprintf(1, 'Opening %s for writing.\n', filename);
    end
    fid = fopen(filename,'wt');
    if fid == -1
        error('matspace:AllPrototypesWriting','Unable to open "%s" for writing.',filename);
    end
    fprintf(fid,'%s\n','function [] = all_prototypes() %#ok<*DEFNU>');
    fprintf(fid,'%s\n\n','    main()');
end

% list the current folder contents
list = dir(folder);

% loop through contents
for i = 1:length(list)
    if any(list(i).name == [".", ".."])
        continue
    end
    % alias this item
    this_name = fullfile(folder, list(i).name);
    % check if a subfolder
    if list(i).isdir
        % if processing recursively, then call this function on the subfolder, otherwise break out of this iteration
        if recursive && ~any(strcmp(list(i).name, folder_exclusions))
            counter = read_all_prototypes(this_name, recursive, fid, counter, Verbose=verbose);
        else
            continue
        end
    else
        % if this is a file, then check if it's a *.m file
        [~, name, ext] = fileparts(this_name);
        if strcmp(ext, '.m') && ~any(strcmp(name, file_exclusions))
            % read this m file
            if verbose
                fprintf(1, 'Processing file: %s\n', this_name);
            end
            temp_fid = fopen(this_name,'rt');
            if temp_fid == -1
                error('matspace:AllPrototypesReading', 'Unable to open "%s" for reading.', this_name);
            end
            % read file
            lines = textscan(temp_fid, '%s', inf, 'Delimiter', '\n');
            % close file
            fclose(temp_fid);
            % keep contents of first cell from textscan command
            lines = lines{1};
            % check and ignore if this is a class definition
            if ignore_classes && strncmp(lines{1}, 'classdef', 8)
                continue
            end
            ix1 = find_lines(lines, '% Prototype:');
            ix2 = find_lines(lines, ["% See Also:", "% Change Log:", "% References:" "% Notes:"]);
            % throw warning if prototype is not found
            if isempty(ix1) || isempty(ix2)
                warning('utils:findPrototype', 'Prototype not found for <a href="matlab: web(''%s'',''-browser'');">%s</a>', this_name, this_name);
                continue
            end
            if length(ix1) > 1
                warning('utils:findPrototype', 'Multiple Prototype seconds found for <a href="matlab: web(''%s'',''-browser'');">%s</a>', this_name, this_name);
            end
            ix1_first = ix1(1);
            ix2_first = min(ix2(ix2 > ix1_first));
            if isempty(ix2_first) || ix2_first < ix1_first
                error('utils:findPrototype', 'Invalid prototype bounds found for <a href="matlab: web(''%s'',''-browser'');">%s</a>', this_name, this_name);
            end
            % increment counter
            counter = counter + 1;
            % pull out prototype
            this_prototype = cellfun(@(x) x(3:end), lines(ix1_first+1:ix2_first-1), UniformOutput=false);
            % write out prototype
            fprintf(fid, '%s\n', ['%% ',this_name]);
            fprintf(fid, '%s\n', ['function [] = function_',num2str(counter,'%04i'),'()']);
            for j = 1:length(this_prototype)
                fprintf(fid, '%s\n', this_prototype{j});
            end
        end
    end
end

if isscalar(dbstack)
    fprintf(fid, '%s\n', '%% Wrapper function');
    fprintf(fid, '%s\n', 'function [] = main()');
    fprintf(fid, '%s\n', '');
    fprintf(fid, '%s\n', ['for i = 1:',int2str(counter)]);
    fprintf(fid, '%s\n', '    this_name = [''function_'',num2str(i,''%04i'')];');
    fprintf(fid, '%s\n', '    try');
    fprintf(fid, '%s\n', '        eval(this_name);');
    fprintf(fid, '%s\n', '    catch exception');
    fprintf(fid, '%s\n', '        warning(''utils:prototypeFailed'', ''Protoype for "%s" failed.'', this_name);');
    fprintf(fid, '%s\n', '    end');
    fprintf(fid, '%s', 'end');
    fclose(fid);
    edit(filename);
end


%% Subfunctions
function [ix] = find_lines(lines, text)

% FIND_LINES  finds the index to any lines that contain the specified text
%
% SUMMMARY:
%     (TBD)
%
% INPUT:
%     lines : {Ax1} of (row) containing text of the *.m files [char]
%     text  : {1xB} or (row) containing the text strings to look for [char]
%
% OUTPUT:
%     ix    : (1xC) index of rows containing specified text [num]
%
% PROTOTYPE:
%     % included to test this function to ignore multiple prototypes
%     lines = {'line 1';'line 2';'another line';'line 2';'not line 2'}
%     text  = {'line 2'};

% make text into a cell if not already
if ischar(text)
    text = string(text);
end
% preallocate output
ix = [];
% loop through different text patterns
for i = 1:length(text)
    % for lines that contain the text:
    %     temp = find(cellfun(@any,strfind(lines,text{i})))';
    % for lines that match exactly:
    temp = find(strcmp(lines, text{i}));
    % save results
    ix   = [ix, temp];  %#ok<AGROW>
end