function [out] = fun_is_fig_ax(x)
    % Check whether the input is a valid FigAx specification.
    out = isempty(x) || (iscell(x) && all(cellfun(@length, x) == 2));
end