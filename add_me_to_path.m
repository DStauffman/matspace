function [] = add_me_to_path(options)

% ADD_ME_TO_PATH  adds the relevant parts of the DStauffman library to your path.

% check for optional inputs
switch nargin
    case 0
        options = '';
    case 1
        % nop
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%s"', nargin);
end

% get the fullpath name to this m file
path_name = mfilename('fullpath');

% find all the string separators
ix        = strfind(path_name,filesep);

% keep the path name up to the second to last file separator
root_dir  = path_name(1:ix(end));

% process based on options
switch lower(options)
    case {'normal', ''}
        sub_folders = {'classes', 'enum', 'plotting', 'stats', 'tests', 'utils'};
        for i = 1:length(sub_folders)
            this_subfolder = sub_folders{i};
            %disp(['Add: ', fullfile(root_dir, this_subfolder)]);
            addpath(genpath(fullfile(root_dir, this_subfolder)));
        end
    case 'all'
        addpath(genpath(root_dir));
    otherwise
        error('dstauffman:BadPathOptions', 'Unexpected options: "%s"', options);
end