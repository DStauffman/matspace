function [out] = fun_is_groups(x)
    % Check whether the input a valid grouping of states.
    out = isempty(x) || (iscell(x) && all(cellfun(@isvector, x)));
end