function [out] = fun_is_dt(x)
    % Check whether the input is a numeric or duration
    out = isscalar(x) && (isnumeric(x) || isduration(x));
end