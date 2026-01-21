function [out] = fun_is_gnd(x)
    % Check whether the input is a valid Gnd structure.
    out = isempty(x) || isstruct(x);
end