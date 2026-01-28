function [color_map] = get_python_colormap(cmap, num_colors, kwargs)

% pyenv(Version='C:\Users\DStauffman\Documents\venvs\everything\Scripts\python.exe', ExecutionMode='OutOfProcess');

arguments
    cmap {mustBeTextScalar} = 'Dark2'
    num_colors (1, 1) double = 0
    kwargs.KeepAlpha (1, 1) logical = false
end
keep_alpha = kwargs.KeepAlpha;

plt = py.importlib.import_module('matplotlib.pyplot');
if num_colors > 0
    cmp = plt.get_cmap(cmap, uint32(num_colors));
else
    cmp = plt.get_cmap(cmap);
end

switch class(cmp.colors)
    case {'py.tuple', 'py.list'}
        temp = cellfun(@double, cell(cmp.colors), UniformOutput=false);
        color_map = vertcat(temp{:});
    case 'py.numpy.ndarray'
        color_map = double(cmp.colors);
    otherwise
        error('Unexpected python class output of %s', class(cmp.colors));
end

if size(color_map, 2) == 4 && ~keep_alpha
    color_map = color_map(:, 1:3);
end