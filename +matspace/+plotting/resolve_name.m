function [new_name] = resolve_name(old_name, kwargs)

% RESOLVE_NAME  resolves any issues in the given file name so that it can be saved to disk
%
% Input:
%     old_name             : (row) name of the file to save [char]
%     strip_classification : (scalar) |opt| Whether to strip any leading classification out [bool]
%     rep_token            : (scalar) |opt| Token to replace bad characters with, defaults to '_' [char]
%     force_win            : (scalar) |opt| Whether to force using windows replacements [bool]
%
% Output:
%     new_name : (row) modified name of the file [char]
%
% Prototype:
%     old_name = '(U//FOUO) Test file [\deg].txt';
%     strip_classification = true;
%     new_name = matspace.plotting.resolve_name(old_name, strip_classification);
%     assert(xor(~ispc,strcmp(new_name, 'Test file [_deg].txt')));
%     assert(xor( ispc,strcmp(new_name, 'Test file [\deg].txt'))); % '\' is allowed on Unix
%
% See Also:
%     matspace.plotting.storefig
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2020 based on code within storefig.m
%     2.  Updated by David C. Stauffer in July 2022 to check for newlines within the name.
%     3.  Updated by David C. Stauffer in April 2025 to handle string arrays

%% Arguments
arguments
    old_name {mustBeText}
    kwargs.strip_classification (1,1) logical = true
    kwargs.rep_token {mustBeTextScalar} = '_';
    kwargs.force_win (1,1) logical
end
if isfield(kwargs, 'force_win')
    USE_WINDOWS = kwargs.force_win;
else
    USE_WINDOWS = ispc;
end

% Initialize new name to the original and determine if processing a single string,
% otherwise assumed to be cell array
if ischar(old_name)
    new_name = {old_name};
else
    new_name = old_name;
end

% strip any leading classification text
if kwargs.strip_classification
    ix = regexp(cellstr(new_name(:)), '^\(\S*\)\s', 'end', 'once');
    strip = cellfun(@(x) ~isempty(x), ix);
    for i = 1:length(new_name)
        if strip(i)
            new_name{i} = new_name{i}(ix{1}+1:end);
        end
    end
end

% check for illegal characters and replace with underscores
if USE_WINDOWS
    bad_chars = {'<','>',':','"','/','\','|','?','*',newline};
else
    bad_chars = {'/',newline};
end
bad_names = false(size(new_name));
for i = 1:length(bad_chars)
    ix = contains(new_name, bad_chars{i});
    if any(ix)
        new_name  = strrep(new_name, bad_chars{i}, kwargs.rep_token);
        bad_names = bad_names | ix;
    end
end
if any(bad_names)
    disp('Bad name(s):');
    disp(new_name(bad_names));
    warning('matspace:plotting:storeFigIllegalChars', 'There were illegal characters in the figure name.');
end

% return single case back to char
if ischar(old_name)
    new_name = new_name{1};
end