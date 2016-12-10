function [counter] = read_all_prototypes(folder,fid,counter,recursive)

% READ_ALL_PROTOTYPES  reads all the prototypes from the specified folder
%
% SUMMARY:
%     (TBD)
%
% Input:
%     folder    : (row) string specifying the folder name [char]
%     fid       : (scalar) file identifier [num]
%     counter   : (scalar) function counter to start from [num]
%     recursive : (scalar) true/false flag for whether processing recursively [bool]
%
% Output:
%     counter   : final counter of prototypes found [num]
%     Also writes results to file
%
% Prototype:
%     folder    = get_root_dir();
%     fid       = [];
%     recursive = true;
%     disp('This prototype rocks (and can otherwise get you in an infinite loop).');
%     % read_all_prototypes(folder,fid,recursive);
%
% Change Log:
%     1.  Written by David C. Stauffer circa 2011.
%     2.  Incorporated by David C. Stauffer into DStauffman Matlab tools in Dec 2016.

% hard-coded inputs
folder_exclusions = {'new', 'tests'};
file_exclusions   = {'all_prototypes'};
ignore_classes    = true;

% check for optional inputs
switch nargin
    case 0
        folder    = pwd;
        fid       = [];
        counter   = 0;
        recursive = true;
    case 1
        fid       = [];
        counter   = 0;
        recursive = false;
    case 2
        recursive = false;
        counter   = 0;
    case 3
        counter   = 0;
    case 4
        % nop
    otherwise
        error('Unexpected number of inputs.');
end

% open file if not already specified
if isempty(fid)
    filename = fullfile(pwd,'all_prototypes.m');
    fid = fopen(filename,'wt');
    if fid == -1
        error('Unable to open "%s" for writing.',filename);
    end
    fprintf(fid,'%s\n','function [] = all_prototypes() %#ok<*DEFNU>');
    fprintf(fid,'%s\n\n','    main()');
end

% list the current folder contents
list = dir(folder);

% loop through contents
for i = 3:length(list)
    % alias this item
    this_name = fullfile(folder,list(i).name);
    % check if a subfolder
    if list(i).isdir
        % if processing recursively, then call this function on the subfolder, otherwise break out of this iteration
        if recursive && ~any(strcmp(list(i).name,folder_exclusions))
            counter = read_all_prototypes(this_name,fid,counter,recursive);
        else
            continue
        end
    else
        % if this is a file, then check if it's a *.m file
        [~,name,ext] = fileparts(this_name);
        if strcmp(ext,'.m') && ~any(strcmp(name,file_exclusions))
            % read this m file
            temp_fid = fopen(this_name,'rt');
            if temp_fid == -1
                error('Unable to open "%s" for reading.',this_name);
            end
            % read file
            lines = textscan(temp_fid,'%s',inf,'Delimiter','\n');
            % close file
            fclose(temp_fid);
            % keep contents of first cell from textscan command
            lines = lines{1};
            % check and ignore if this is a class definition
            if ignore_classes && strncmp(lines{1},'classdef',8)
                continue
            end
            ix1 = find_lines(lines,'% Prototype:');
            ix2 = union(find_lines(lines,'% See Also:'), find_lines(lines,'% Change Log:'));
            % throw warning if prototype is not found
            if isempty(ix1) || isempty(ix2)
                warning('utils:findPrototype','PROTOTYPE not found for <a href="matlab: web(''%s'',''-browser'');">%s</a>',this_name,this_name);
                continue
            end
            % increment counter
            counter = counter + 1;
            % pull out prototype
            this_prototype = cellfun(@(x) x(2:end),lines(ix1(1)+1:ix2(1)-1),'UniformOutput',false);
            % write out prototype
            fprintf(fid,'%s\n',['%% ',this_name]);
            fprintf(fid,'%s\n',['function [] = function_',num2str(counter,'%04i'),'()']);
            for j = 1:length(this_prototype)
                fprintf(fid,'%s\n',this_prototype{j});
            end
        end
    end
end

if length(dbstack) == 1
    fprintf(fid,'%s\n','%% Wrapper function');
    fprintf(fid,'%s\n','function [] = main()');
    fprintf(fid,'%s\n','');
    fprintf(fid,'%s\n',['for i = 1:',int2str(counter)]);
    fprintf(fid,'%s\n','    this_name = [''function_'',num2str(i,''%04i'')];');
    fprintf(fid,'%s\n','    try');
    fprintf(fid,'%s\n','        eval(this_name);');
    fprintf(fid,'%s\n','    catch exception %#ok<NASGU>');
    fprintf(fid,'%s\n','        warning(''utils:prototypeFailed'',''Failed.'')');
    fprintf(fid,'%s\n','    end');
    fprintf(fid,'%s','end');
    fclose(fid);
    edit(filename);
end


%% Subfunctions
function [ix] = find_lines(lines,text)

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
    text = {text};
end
% preallocate output
ix = [];
% loop through different text patterns
for i = 1:length(text)
    % for lines that contain the text:
    %     temp = find(cellfun(@any,strfind(lines,text{i})))';
    % for lines that match exactly:
    temp = find(strcmp(lines,text{i}));
    % save results
    ix   = [ix, temp]; %#ok<AGROW>
end