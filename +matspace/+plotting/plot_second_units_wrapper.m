function [] = plot_second_units_wrapper(ax, second_units)

% Wrapper to plot_second_yunits that allows numeric or dict options.
% 
% Input:
%     ax : Figure axes
%     second_units : string, double or {char, double}
%         Scale factor to apply, or dict with key for label and value for factor
% 
% Returns:
%     None
% 
% Notes:
%     1.  If second_units is just a number, then no units are displayed, but if a key and value,
%         then if it has brakets, replace the entire label, otherwise only replace what is in the
%         old label within the brackets
% 
% Prototype:
%     description = "Values over time";
%     y_label = "Value [rad]";
%     second_units = {"Better Units [µrad]", 1e6};
%     fig = figure();
%     ax = axes(fig);
%     plot(ax, [1, 5, 10], [1e-6, 3e-6, 2.5e-6], ".-");
%     ylabel(ax, y_label);
%     title(ax, description);
%     ax2 = matspace.plotting.plot_second_units_wrapper(ax, second_units);
% 
%     close(fig);

arguments
    ax (1, 1) matlab.graphics.axis.Axes
    second_units {mustBeNumOrStrNum} = ""
end

import matspace.plotting.plot_second_yunits

% check if processing anything
if (isstring(second_units) && strlength(second_units) == 0) || isempty(second_units)
    return
end

% determine what type of input was given
if isnumeric(second_units)
    label = '';
    value = second_units;
else
    label = second_units{1};
    value = second_units{2};
end
% check if we got a no-op value
if ~isnan(value) && value ~= 0 && value ~= 1
    % if all is good, build the new label and call the lower level function
    old_label = ax.YLabel.String;
    ix1 = strfind(old_label, '[');
    if contains(label, '[')
        % new label has units, so use them
        new_label = label;
    elseif ~isempty(ix1) && ~isempty(label)
        % new label is only units, replace them in the old label
        new_label = [old_label(1:ix1-1),'[',char(label),']'];
    else
        % neither label has units, just label them
        new_label = label;
    end
    plot_second_yunits(ax, new_label, value);
end


%% Subfunctions - mustBeDoubleOrDatetime
function mustBeNumOrStrNum(x)

if isempty(x)
    % valid if empty
    return
end
if isscalar(x)
    % valid if scalar (should be numeric or char/str)
    return
end
if iscell(x)
    if length(x) == 2
        if (ischar(x{1}) || isstring(x{1})) && isnumeric(x{2})
            % valid if cell where first value is char and second is numeric
            return
        end
    end
end
% all other cases are invalid
throwAsCaller(MException('matspace:plotting:BadSecUnits','Input must be exactly one or two elements.'))