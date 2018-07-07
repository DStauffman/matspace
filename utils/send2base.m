function [sent_vars] = send2base(varargin)

% SEND2BASE  sends the specified arguments into the base workspace.
%
% Input:
%     varargin : names of variables to pass
%     -exclude, x : string or cell of names to exclude
%
% Output:
%     sent_vars : names of the variables that were assigned in the base workspace
%
% Notes:
%     1.  Allows the use of '*' for wildcards, but otherwise does an exact (case-sensitive) match.
%
% Examples:
%     % variables in current workspace (nominally do this in a function, so they aren't already in
%     % the base workspace
%     test     = 123;
%     name_one = '1';
%     name_two = '2';
%
%     % As standard function call
%     send2base('test');
%
%     % as a statement
%     send2base test name_one;
%
%     % with wildcards
%     send2base('name*');
%
%     % with exclusions
%     send2base('test', 'name_one', 'name_two', '-exclude', '*two');
%
%     % send everything
%     send2base('*');
%
%     % send everything, except for some common exceptions
%     send2base('*', '-exclude', {'ans', 'obj', 'this', 'self'});
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2018.

%% Initializations
% default configuration
exclusions = {};

% handle simple string case
if nargin == 1 && ischar(varargin)
    varargin = {varargin};
end
num_args = length(varargin);

%% Configurations
% first loop through varargin and find all configuration options that need to be separated from
% the names of variables to process
skip = false;
keep = true(1, num_args);
for i = 1:num_args
    if skip
        keep(i) = false;
        skip = false;
        continue
    end
    this_arg = varargin{i};
    if strcmp(this_arg, '-exclude')
        exclusions = union(exclusions, varargin{i+1});
        keep(i) = false;
        skip = true;
        continue
    end
    if strncmp(this_arg, '-', 1)
        error('dstauffman:BadSendVarsOption', 'Unexpected option "%s".', this_arg);
    end
end

%% Variable matching
% remaining variables to process once configuration options are removed
vars_to_pass = varargin(keep);

% get all the variables in the caller workspace
variables = evalin('caller','who');

% determine which names have wildcards
has_wildcard = cellfun(@(x) ismember('*', x), vars_to_pass);

% find all the matches with any potential wildcards
if ~any(has_wildcard)
    all_vars = vars_to_pass;
else
    all_vars = vars_to_pass(~has_wildcard);
    for name = vars_to_pass(has_wildcard)
        % convert the wildcards to an equivalent regexp
        this_regexp = regexptranslate('wildcard', name);
        new_matches = ~cellfun(@isempty, regexp(variables, this_regexp));
        if ~isempty(new_matches)
            all_vars = union(all_vars, variables(new_matches));
        end
    end
end

% find any specified names that don't exist
bad_names = setdiff(all_vars, variables);
if ~isempty(bad_names)
    % Note: string command only works on newer Matlab (R2016B+), but it's awesome!!
    try
        bad_names_str = join(string(bad_names), ', ');
    catch exception
        if strcmp(exception.identifier, 'MATLAB:UndefinedFunction')
            bad_names_str = bad_names{i};
        else
            rethrow(exception);
        end
    end
    error('dstauffman:BadSendVarsName', 'Variable(s) named "%s" don''t exist', bad_names_str);
end

%% Exclusions
% determine which exclusions have wildcards
has_wildcard = cellfun(@(x) ismember('*', x), exclusions);
if ~any(has_wildcard)
    % simple case with no exclusions
    all_vars = setdiff(all_vars, exclusions);
else
    all_vars = setdiff(all_vars, exclusions(~has_wildcard));
    % remove any variables based on exclusions
    for name = exclusions(has_wildcard)
        % convert the wildcards to an equivalent regexp
        this_regexp = regexptranslate('wildcard', name);
        ix_keep = cellfun(@isempty, regexp(all_vars, this_regexp));
        if ~all(ix_keep)
            all_vars = all_vars(ix_keep);
        end
    end
end

%% Processing
% sort for consistent ordering despite how they may have been discovered by wildcards, etc.
all_vars = sort(all_vars);
% process the matching variables
for i = 1:length(all_vars)
    % get the name of this variable
    name = all_vars{i};
    % get the value
    value = evalin('caller', name);
    % assign in the base workspace
    assignin('base', name, value);
end

%% Output
if nargout > 0
    sent_vars = all_vars;
end