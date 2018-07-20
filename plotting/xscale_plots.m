function [] = xscale_plots(figs, oldunit, newunit)

% XSCALE_PLOTS  rescales xaxis units and vectors for single axis figures.
%
% Summary:
%     1.  determines children of figure handles
%     2.  children that are not tagged as legends and that
%         also maintain an xlabel property are presumed to be
%         plot axis handles
%     3.  children of plot axis handles are presumed to express
%         vector plot data
%     4.  function confirms all plot axis xlabels and when
%         successful determines scale factor needed to convert
%         to new basis then scales all vector plot data and
%         modifies all plot axis xlabels
%     5.  care is taken to replace only that portion of xlabel
%         strings that express the unit
%     6.  for compatability with xextents tool also rescales
%         xaxis extents if they have been manually established
%
% Input:
%     figs    : (scalar) or (column) or (row) figure handles [numeric]
%     oldunit : (row) existing xaxis unit [enumerated]
%                     enumerated values are ('[sec]', '[min]', '[hr]', '[day]', '[year]')
%     newunit : (row) replacement xaxis unit [enumerated]
%                     enumerated values are ('[sec]', '[min]', '[hr]', '[day]', '[year]')
%
% Output:
%      None
%
% Prototype:
%     f1 = figure(5);
%     hold on;
%     plot(linspace(0,3600), 1e-6*(0.1+randn(1,100)), 'r');
%     plot(linspace(0,3600), 1e-6*(0.2+randn(1,100)), 'b');
%     plot(linspace(0,3600), 1e-6*(0.3+ones(1,100)), 'g');
%     plot([0 3600], [1.3e-6 1.3e-6], 'ko');
%     legend('r', 'b', 'g');
%     xlabel('something [sec]');
%     ylabel('something [rad]');
%     figmenu;
%
%     f2 = figure(6);
%     hold on;
%     plot(linspace(0,3600), 1e-6*(0.1+randn(1,100)), 'r');
%     plot(linspace(0,3600), 1e-6*(0.2+randn(1,100)), 'b');
%     plot(linspace(0,3600), 1e-6*(0.3+ones(1,100)), 'g');
%     plot([0 3600], [1.3e-6 1.3e-6], 'ko');
%     legend('r', 'b', 'g');
%     xlabel('something [sec]');
%     ylabel('something [m]');
%     figmenu;
%
%     xscale_plots([f1 f2],'[sec]','[min]');
%     yscale_plots([f1 f2],'unity','micro');
%
%     % clean up
%     close([f1 f2]);
%
% See Also:
%     figmenu, setup_plots, storefig, titleprefix, xextents, yscale_plots
%
% Notes:
%     This function expects the exact syntax of '[min]' and will not match other variations,
%     such as 'min' or '[Min]' or 'minutes'.
%
% Change Log:
%     1.  lineage: GARSE (Sims)
%     2.  Updated by David Stauffer in Jun 2009 to close colleague review PGPR 1006.
%     3.  Incorporated by David C. Stauffer into DStauffman library in Nov 2016.

%% determine conversion factor and string prefixes to replace
% get factors and labels
mult_old = get_factor(oldunit);
mult_new = get_factor(newunit);
% find the new effective multiplication factor
mult = mult_old / mult_new;

%% verify existing axis units
% if any figure handle fails, then this function returns without modifying anything
cnt = 1;
for hfig = figs
    % check if this is a valid figure handle
    if ~ishandle(hfig)
        warning('dstauffman:XScaleFig', 'Invalid figure handle specified: "%g".', hfig);
        return
    end
    % check that the figure has a valid axis child
    haxs = get(hfig,'children');
    if isempty(haxs)
        warning('dstauffman:XScaleChildren', 'Specified figure does not contain axis.');
        return
    end
    % loop through children axes
    for a = 1:length(haxs)
        % permit if xlabel property exists
        try
            hxut = get(haxs(a), 'xlabel');
        catch exception
            if strcmp(exception.identifier, 'MATLAB:class:InvalidProperty') || ...
                    strcmp(exception.identifier, 'MATLAB:hg:InvalidProperty')
                hxut = [];
            else
                rethrow(exception);
            end
        end
        % permit when xlabel property is not child to axis tagged as legend
        if strcmp('legend', get(haxs(a), 'tag'))
            hxut = [];
        end
        % accumulate permitted axes
        if ~isempty(hxut)
            xunit{cnt,1} = get(hxut,'string'); %#ok<AGROW>
            cnt = cnt+1;
        end
    end
end
% confirm that at least one permitted axes has the desired string
ixs = strfind(xunit, oldunit);
arr = cellfun(@(x) ~isempty(x),ixs);
if ~all(arr)
    warning('dstauffman:XScaleLabel', 'invalid ''xlabel'' property ''string'' exists.');
    return
end

%% rescale units
for hfig = figs
    haxs = get(hfig, 'children');
    for a = 1:length(haxs)
        % permit if xlabel property exists
        try
            hxut = get(haxs(a), 'xlabel');
        catch exception
            if strcmp(exception.identifier, 'MATLAB:class:InvalidProperty') || ...
                    strcmp(exception.identifier, 'MATLAB:hg:InvalidProperty')
                hxut = [];
            else
                rethrow(exception);
            end
        end
        % permit when xlabel property is not child to axis tagged as legend
        if strcmp('legend', get(haxs(a), 'tag'))
            hxut = [];
        end
        % modify permitted
        if ~isempty(hxut)
            hvec = get(haxs(a), 'children');
            xdat = findobj(hvec, '-property', 'xdata');
            % scale vector data
            for i = 1:length(xdat)
                % if this line/patch/area has a child, then skip it, the child will manipulate both
                % otherwise some plots might get double scaled.
                if isempty(get(xdat(i), 'Children'))
                    xdat_scaled = get(xdat(i), 'xdata')*mult;
                    set(xdat(i), 'xdata', xdat_scaled);
                end
            end
            % modify axis xlabel
            xunt   = get(haxs(a), 'xlabel');
            newstr = strrep(get(xunt, 'string'), oldunit, newunit);
            set(xunt, 'string', newstr);
            % rescale established xaxis extents
            if strcmp(get(haxs(a), 'xlimmode'), 'manual')
                set(haxs(a), 'xlim', [min(min(xdat_scaled)), max(max(xdat_scaled))]);
            end
        end
    end
end


%% Subfunctions
function [mult] = get_factor(unit)

% GET_FACTOR  gets the multiplication factor for the desired units.
%
% Input:
%     unit : (row) string specifying the unit standard
%                    from: {'[sec]','[min]','[hr]','[day]'}
%
% Output:
%     mult   : (scalar) multiplication factor [num]

% find the desired units and label prefix
switch unit
    case '[sec]'
        mult = 1;
    case '[min]'
        mult = 60;
    case '[hr]'
        mult = 3600;
    case '[day]'
        mult = 86400;
    otherwise
        error('dstauffman:BadPlottingUnit', 'Unexpected unit value: "%s".', unit);
end