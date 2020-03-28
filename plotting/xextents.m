function [] = xextents(figs, xmin, xmax)

% XEXTENTS  modifies xaxis extents of single axis figures.
%
% Summary:
%     1.  determines children of figure handles
%     2.  children that are not tagged as legends and that
%         also maintain child title handles are presumed to
%         be plot axis handles within which xlim property
%         may be manipulated to modify the xaxis scope of
%         rendered plot data
%     3.  function resets xaxis plot extents applying
%         arguments satisfing the condition xmin < xmax
%
% Input:
%     figs : (scalar) or (column) or (row) figure handles [numeric]
%     xmin : (scalar) xaxis minimum plot extent [string]
%     xmax : (scalar) xaxis maximum plot extent [string]
%
% Output:
%     None
%
% Prototype:
%     f1 = figure(5);
%     hold on;
%     title('something');
%     plot(linspace(0,3600), 1+randn(1,100), 'r');
%     legend('r');
%     xlabel('something [sec]');
%     ylabel('something');
%     figmenu;
%
%     f2 = figure(6);
%     hold on;
%     title('something');
%     plot(linspace(0,3600), 1+randn(1,100), 'r');
%     legend('r');
%     xlabel('something [sec]');
%     ylabel('something');
%     figmenu;
%
%     xextents([f1 f2],-500,2000);
%
%     % clean up
%     close([f1 f2]);
%
% See Also:
%     figmenu, setup_plots, storefig, titleprefix, xscale_plots
%
% Change Log:
%     1.  lineage: GARSE (Sims)
%     2.  Updated by David C. Stauffer in Jun 2009 to close colleague review PGPR 1006.
%     3.  Incorporated by David C. Stauffer into matspace library in Nov 2016.

% confirm extents
if xmin > xmax
    % TODO: should this be an error instead?
    warning('matspace:XExtentsXValues', ...
        'Argument xmin (%g) must be less than argument xmax(%g)', xmin, xmax);
end

% confirm figures
for hfig = figs
    if ~ishandle(hfig)
        warning('matspace:XExtentsBadFigure', 'Invalid figure handle specified: "%g".', hfig);
        return
    end
    haxs = get(hfig, 'children');
    if isempty(haxs)
        warning('matspace:XExtentsBadAxes', 'Specified figure (%g) does not contain axis.', hfig);
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
            set(haxs(a), 'xlim', [xmin xmax])
        end
    end
end