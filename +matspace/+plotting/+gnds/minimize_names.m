function [combined_name] = minimize_names(names, kwargs)

% Combine the unique characters in a name to make them simpler.
%
% Input:
%     names : (1, :) string array of name fields to be combined
%     Sep   : (1, 1) str, optional, default is ","; String to combine between the shortened names
%
% Output:
%     combined_name : (1, 1) string; Combined string of shortened names
%
% See Also:
%     matspace.plotting.gnds.plot_covariance
%
% Change Log:
%     1.  Written by David C. Stauffer in July 2024.
%     2.  Translated into Matlab by David C. Stauffer in February 2026.
%
% Prototype:
%     names = ["Gyro Bias 1", "Gyro Bias 2", "Gyro Bias 3"];
%     combined_name = matspace.plotting.gnds.minimize_names(names);
%     assert(combined_name == "Gyro Bias 1,2,3");

% parse inputs
arguments (Input)
    names (1, :) string
    kwargs.Sep (1, 1) string = ","
end
arguments (Output)
    combined_name (1, 1) string
end
sep = kwargs.Sep;

% check simple cases
if isempty(names)
    combined_name = "";
    return
end
if isscalar(names)
    combined_name = names(1);
    return
end

% find all the unique characters
all_chars = '';
for i = 1:length(names)
    name = names{i};
    all_chars = unique([all_chars, unique(name)]);
end

% check if all numbers
if isempty(setdiff(all_chars, '1234567890'))
    combined_name = strjoin(names, sep);
    return
end

% find the minimum length of any name, then loop through and find the first non-matching character
min_len = min(strlength(names));
match = min_len + 1;
for i = 1:min_len
    if isstrprop(names{1}(i), 'digit')
        match = i;
        break
    end
    shorts = cellfun(@(x) x(1:i), names, UniformOutput=false);
    if length(unique(shorts)) > 1
        match = i;
        break
    end
end

% shorten the names given the first non-matching character
same_name = names{1}(1:match - 1);
short_name = strjoin(cellfun(@(x) x(match:end), names, UniformOutput=false), sep);
combined_name = [same_name,short_name];