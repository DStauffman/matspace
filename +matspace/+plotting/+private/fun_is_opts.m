function [out] = fun_is_opts(x)
    % Check whether the input is a Opts instance.
    out = isa(x, 'matspace.plotting.Opts');
end