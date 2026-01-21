function [out] = fun_is_time(x)
    % Check whether the input is a valid time entry or cell array of time entries.
    out = sub_is_time(x) || (iscell(x) && all(cellfun(@sub_is_time, x)));
end


%% Subfunctions - sub_is_time
function [out] = sub_is_time(x)
    % Check whether the input is a valid time entry.
    out = (isnumeric(x) || isdatetime(x)) && (isempty(x) || isvector(x));
end