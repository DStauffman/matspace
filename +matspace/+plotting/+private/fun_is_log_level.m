function [out] = fun_is_log_level(x)
    % Check whether the input is a Log Level value.
    out = isscalar(x) && isnumeric(x) && x >= 0 && x <= 20;
end