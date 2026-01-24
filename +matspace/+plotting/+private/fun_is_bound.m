function [out] = fun_is_bound(x)
    % Check whether the input is a time bound.
    out = isscalar(x) && (isnumeric(x) || isdatetime(x));
end