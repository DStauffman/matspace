function [] = setup_dir(directory)

% SETUP_DIR  clears contents or instantiates directory for writing output files.
%
% Summary:
%     If the input directory exists, removes its contents.  If it does not exist, create it.
%     The function also displays a message if the directory was created or content was deleted.
%
% Input:
%     directory : (str) directory [char]
%
% Output:
%     None
%
% Prototype:
%     % create a folder
%     directory = fullfile(pwd,'testdir');
%     setup_dir(directory);
%
%     % create a file within the folder
%     save(fullfile(directory,'testfile.mat'));
%
%     % call setup_dir again to clear the folder
%     setup_dir(directory);
%
%     % remove the test directory for cleanup
%     rmdir(directory);
%
% See Also:
%     mkdir, delete
%
% Change Log:
%     1.  Added to DStauffman's library from GARSE in Sept 2013.
%     2.  Modified to be fully recursive by David Stauffer in Sept 2013.

% add filesep to end of path if necessary
if ~strcmp(directory(end),filesep)
    directory = [directory,filesep];
end

% empty files within directory if it already exists
if exist(directory,'dir')
    contents = dir(directory);
    names    = {contents(3:end).name};
    isdir    = [contents(3:end).isdir];
    for i = 1:length(names)
        if isdir(i)
            % call recursively for subfolders
            setup_dir([directory,names{i}]);
        else
            % delete files
            delete([directory,names{i}]);
        end
    end
    % display that something was removed
    if ~isempty(names)
        disp(['Files/Sub-folders were removed from "',directory,'"']);
    end
else
    % create directory if it does not exist
    try
        mkdir(directory);
        disp(['Created directory "',directory,'"']);
    catch exception
        error('utils:DirCreation', '"%s" could not be created because: "%s"', directory, exception.message);
    end
end