function [] = shift_axes_up(figs, shift)

% SHIFT_AXES_UP  shifts the axes on the given figures up by the given percentage.
%
% Input:
%     figs  : (1xN) figure handles to process
%     shift : (scalar) Value to shift, from 0-1
%
% Output:
%     (None)
%
% Prototype:
%     fig = figure();
%     ax = axes(fig);
%     plot(ax, 0:10, 0:10, '.-');
%     shift = 0.20;
%     matspace.plotting.shift_axes_up(fig, shift);
%
%     % clean-up
%     close(fig);
%
% See Also:
%     matspace.plotting.plot_classification, matspace.plotting.setup_plots
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2020.

% check shift values
assert(shift >= 0 && shift <= 1, 'The shift should be a value between zero and one, not "%g"', shift);

% confirm figures
for hfig = figs
    if ~ishandle(hfig)
        warning('matspace:AxisShiftBadFigure', 'Invalid figure handle specified: "%g".', hfig);
        return
    end
    haxs = get(hfig, 'children');
    if isempty(haxs)
        warning('matspace:AxisShiftBadAxes', 'Specified figure (%g) does not contain axis.', hfig);
        return
    end
end

% modify xaxis extents
for hfig = figs
    haxs = get(hfig, 'children');
    for a = 1:length(haxs)
        % determine if this axes should be processed
        process = false;
        % permit if title property exists and is not empty
        try
            if ~isempty(get(haxs(a), 'title'))
                process = true;
            end
        catch %#ok<CTCH>
            % nop
        end
        % permit only when handle is not tagged as legend
        if process && strcmp('legend', get(haxs(a), 'tag'))
            process = false;
        end
        % modify permitted
        if process
            old_pos = get(haxs(a),  'Position');
            delta   = shift * old_pos(4);
            new_pos = old_pos + [0 delta 0 -delta];
            set(haxs(a), 'Position', new_pos);
        end
    end
end