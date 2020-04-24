function [new_name] = resolve_name(old_name, strip_classification)

% RESOLVE_NAME  resolves any issues in the given file name so that it can be saved to disk
%
% Input:
%     old_name             : (row) name of the file to save [char]
%     strip_classification : (scalar) |opt| Whether to strip any leading classification out [bool]
%
% Output:
%     new_name : (row) modified name of the file [char]
%
% Prototype:
%     old_name = '(U//FOUO) Test file [\deg].txt';
%     strip_classification = false;
%     new_name = matspace.plotting.resolve_name(old_name, strip_classification);
%     assert(xor(~ispc,strcmp(new_name, 'Test file [_deg].txt')));
%     assert(xor( ispc,strcmp(new_name, 'Test file [\deg].txt'))); % '\' is allowed on Unix
%
% See Also:
%     matspace.plotting.storefig
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2020 based on code within storefig.m

% optional inputs
switch nargin
    case 1
        strip_classification = true;
    case 2
        %nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% Initialize new name to the original and determine if processing a single string,
% otherwise assumed to be cell array
% TODO: make it process string arrays instead of cell arrays?
if ischar(old_name)
    is_single = true;
    new_name  = {old_name};
else
    is_single = false;
    new_name  = old_name;
end

% strip any leading classification text
if strip_classification
    ix = regexp(new_name, '^\(\S*\)\s', 'end', 'once');
    strip = cellfun(@(x) ~isempty(x), ix);
    for i = 1:length(new_name)
        if strip(i)
            new_name{i} = new_name{i}(ix{1}+1:end);
        end
    end
end

% check for illegal characters and replace with underscores
if ispc
    bad_chars = {'<','>',':','"','/','\','|','?','*'};
else
    bad_chars = {'/'};
end
bad_names = false(size(new_name));
for i = 1:length(bad_chars)
    ix = ~cellfun(@isempty, strfind(new_name, bad_chars{i}));
    if any(ix)
        new_name  = strrep(new_name, bad_chars{i}, '_');
        bad_names = bad_names | ix;
    end
end
if any(bad_names)
    disp('Bad name(s):');
    disp(new_name(bad_names));
    warning('matspace:plotting:storeFigIllegalChars', 'There were illegal characters in the figure name.');
end

% return single case back to char
if is_single
    new_name = new_name{1};
end