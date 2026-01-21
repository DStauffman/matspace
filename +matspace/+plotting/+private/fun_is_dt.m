function [out] = fun_is_dt(x)
    % Check whether the input is a numeric or duration
    out = isnumeric(x) || isduration(x);
end