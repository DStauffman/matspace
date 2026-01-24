function [out] = fun_is_lim(x)
    % Check whether the input is a valid xlim/ylim/zlim vector (exactly two values).
    out = isempty(x) || length(x) == 2;
end