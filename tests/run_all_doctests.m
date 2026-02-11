% Run docstring tests
%
% Note: uses custom read_all_prototypes function, as Matlab does not provide this ability built-in.

folder    = matspace.paths.get_root_dir();
recursive = true;
matspace.utils.read_all_prototypes(folder, recursive, Verbose=true);

all_prototypes();