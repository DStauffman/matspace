function [ylabels] = get_ylabels(num_channels, y_label, kwargs)

% Build the list of y-labels.

arguments
    num_channels (1, 1) double
    y_label  % cellstr or char or string
    kwargs.Elements  (1, :) string  % or cellstr?
    kwargs.SingleLines (1, 1) logical
    kwargs.Description (1, :) char  % or string scalar?
    kwargs.Units (1, :) char  % or string scalar?
end

elements = kwargs.Elements;
single_lines = kwargs.SingleLines;
description = kwargs.Description;
units = kwargs.Units;

if isempty(y_label)
    ylabels = cell(1, num_channels);
    if single_lines
        for i = 1:num_channels
            ylabels{i} = [elements{i},' [',units,']'];
        end
    else
        ylabels(1:end-1) = {''};
        if num_channels > 0
            ylabels{end} = [description,' [',units,']'];
        end
    end
elseif iscell(y_label)
    ylabels = y_label;
else
    ylabels = cell(1, num_channels);
    if single_lines
        ylabels(:) = {y_label};
    else
        ylabels(1:end-1) = {''};
        ylabels{end} = y_label;
    end
end