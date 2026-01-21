function [out] = fun_is_colormap(x)

% Check whether the input is a valid colormap
out = (ischar(x) && validatecolor(x)) || isempty(x) || ...
    (isnumeric(x) && size(x, 2) == 3) || isa(x, 'matspace.plotting.colors.ColorMap');