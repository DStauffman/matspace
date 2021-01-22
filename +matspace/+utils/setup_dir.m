function [] = setup_dir(directory, rec, wipe)

% SETUP_DIR  clears contents or instantiates directory for writing output files.
%
% Summary:
%     If the input directory exists, removes its contents.  If it does not exist, create it.
%     The function also displays a message if the directory was created or content was deleted.
%
% Input:
%     directory : (str) directory [char]
%     rec       : |opt| (scalar) whether to recursively walk the directory, default is true [bool]
%     wipe      : |opt| (scalar) whether to wipe the existing contents, default is true [bool]
%
% Output:
%     None
%
% Prototype:
%     % create a folder
%     directory = fullfile(pwd, 'testdir');
%     matspace.utils.setup_dir(directory);
%
%     % create a file within the folder
%     save(fullfile(directory, 'testfile.mat'));
%
%     % call setup_dir again to clear the folder
%     matspace.utils.setup_dir(directory);
%
%     % remove the test directory for cleanup
%     rmdir(directory);
%
% See Also:
%     mkdir, delete
%
% Change Log:
%     1.  Added to matspace library from GARSE in Sept 2013.
%     2.  Modified to be fully recursive by David C. Stauffer in Sept 2013.
%     3.  Modified by David C. Stauffer to optionally not wipe existing directories in October 2016.
%     4.  Modified by David C. Stauffer in January 2019 to be able to specify if recursive or not.
%     5.  Updated by David C. Stauffer in April 2020 to put into a package.
%     6.  Modified by David C. Stauffer in January 2021 to use function arguments.

arguments
    directory (1,:) char
    rec logical = true
    wipe logical = true
end

% Imports
import matspace.utils.setup_dir

% check for empty case
if isempty(directory)
    return
end

% empty files within directory if it already exists
if isfolder(directory)
    if wipe
        contents = dir(directory);
        names    = {contents(3:end).name};
        isdir    = [contents(3:end).isdir];
        for i = 1:length(names)
            this_item = fullfile(directory, names{i});
            if rec && isdir(i)
                % call recursively for subfolders
                setup_dir(this_item, rec, wipe);
                % now delete the empty folder
                rmdir(this_item);
            else
                if ~isdir(i)
                    % delete files
                    delete(this_item);
                end
            end
        end
        % display that something was removed
        if ~isempty(names)
            disp(['Files/Sub-folders were removed from "',directory,'"']);
        end
    else
        disp(['Directory: "',directory,'" already exists, and was not wiped.'])
    end
else
    % create directory if it does not exist
    try
        mkdir(directory);
        disp(['Created directory: "',directory,'"']);
    catch exception
        error('matspace:utils:DirCreation', '"%s" could not be created because: "%s".', ...
            directory, exception.message);
    end
end