function [out] = fun_is_2nd_units(x)
    % Check whether the input is a valid second units specification.
    import matspace.plotting.private.fun_is_text
    out = isempty(x) || (isnumeric(x) && isscalar(x)) || fun_is_text(x) || ...
        (iscell(x) && length(x) == 2 && fun_is_text(x{1}) && isnumeric(x{2}));
end