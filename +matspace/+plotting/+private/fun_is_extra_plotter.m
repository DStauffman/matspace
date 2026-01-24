function [out] = fun_is_extra_plotter(x)
    % Check whether the input is a time bound.
    out = isempty(x) || isa(x, 'function_handle');
end