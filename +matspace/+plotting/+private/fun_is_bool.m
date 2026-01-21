function [out] = fun_is_bool(x)
    % Check whether the input is a single boolean.
    out = isscalar(x) && islogical(x);
end