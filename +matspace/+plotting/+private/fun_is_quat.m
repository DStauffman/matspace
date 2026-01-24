function [out] = fun_is_quat(x)
    % Check whether the input is a valid quaternion.
    out = (isnumeric(x) && ((isvector(x) && length(x) == 4)) || size(x, 1) == 4) || (iscell(x) && length(x) == 4);
end