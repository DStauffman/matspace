function [out] = fun_is_dict(x)
    % Check whether the input is a dictionary instance.
    out = isa(x, 'dictionary');
end