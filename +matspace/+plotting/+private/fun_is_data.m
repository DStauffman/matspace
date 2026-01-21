function [out] = fun_is_data(x)
    % Check whether the input is a valid data stream.
    out = isnumeric(x) || iscell(x) || iscategorical(x);
end