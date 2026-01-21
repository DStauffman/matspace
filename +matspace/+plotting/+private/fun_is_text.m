function [out] = fun_is_text(x)
    % Check whether the input is a single text entry.
    out = (ischar(x) && (isempty(x) || size(x, 1) == 1)) || (isstring(x) && isscalar(x));
end