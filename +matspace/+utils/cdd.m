function [folder] = cdd(name)

% CD to path containing the specified mfile, model or directory
%
% Input:
%     name : |opt| Name of file to find [char]
%
% Output:
%     folder : (str) Location where the file was found, empty if not found.
%
% Examples:
%     % switches to location of currently active file
%     matspace.utils.cdd
%
%     % Switch the folder containing the specified file
%     matspace.utils.cdd('matspace.utils.setup_dir');
%
%     % Switch to directory. Can be relative path. Will switch to first occurrence found.
%     matspace.utils.cdd('../matspace/tests');
%
% Change Log:
%     1.  Originally written by Jesse Hopkins in 2009.
%     2.  Updated by David C. Stauffer in November 2018.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.

%% Parse inputs
switch nargin
    case 0
        % get the current active file in the editor
        active_editor = com.mathworks.mlservices.MLEditorServices.getEditorApplication.getInstance.getActiveEditor;
        if ~isempty(active_editor)
            name = char(active_editor.getStorageLocation.getFile.getAbsolutePath);
        end
    case 1
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

%% Initialize output
folder = '';

%% Look for the name
temp = which(name);
switch exist(temp) %#ok<EXIST>
    case {2,3,4,6}
        % 'exist' filename values
        folder = fileparts(temp);
    case 7
        % 'exist' directory value
        folder = temp;
end

%% Change to the directory
if ~isempty(folder)
    disp(['cd to: ', folder]);
    cd(folder);
else
    disp([name, ' was not found.']);
end

% clear varargout to avoid ans being printed when called as a script with no outputs
if nargout == 0
    clear folder
end