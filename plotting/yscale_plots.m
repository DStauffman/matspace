function [] = yscale_plots(figs, prefix_old, prefix_new)

% YSCALE_PLOTS  rescales yaxis units and vectors for single axis figures.
%
% Summary:
%    1.  Determines children of figure handles.
%    2.  Children that are not tagged as legends and that
%        also maintain a ylabel property are presumed to be
%        plot axis handles and are added to a list.
%    3.  Children of plot axis handles are presumed to express
%        vector plot data (xdata & ydata fields).
%    4.  Function confirms all plot axis ylabels and when
%        it has successful determines scale factor needed to convert
%        to new basis then scales all vector plot data and
%        modifies all plot axis ylabels.
%    5.  Care is taken to replace only that portion of xlabel
%        strings that specify some units using [units].
%    6.  For compatability with manual yextents, this function also rescales
%        yaxis extents if they have been manually established.
%
% Input:
%     figs       : (scalar) or (column) or (row) figure handles [num]
%     prefix_old : (row) existing xaxis unit [enum] see note 1
%     prefix_new : (row) replacement xaxis unit [enum] see note 1
%
% Output:
%     None
%
% Prototype:
%     f1 = figure;
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
%     f2 = figure;
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
%     figmenu, setup_plots, storefig, titleprefix, xextents, xscale_plots
%
% Notes:
%     1.  Allowable prefixes are from any standard metric prefix:
%             % DCS - yes, I realize this list is probably overkill
%             'yotta','zetta','exa','peta','tera','giga','mega',
%             'kilo','hecto','deca','unity','deci','centi','milli',
%             'micro','nano','pico','femto','atto','zepto','yocto'
%
% Change Log:
%     1.  Written by David C. Stauffer in Nov 2012.
%     2.  Incorporated by David C. Stauffer into matspace library in Nov 2016.
%     3.  Updated by David C. Stauffer in March 2019 to handle bug where values are exactly the same
%         for all points.

%% hard-coded values
% units to exclude from scaling
exclusions = {'[dimensionless]','[normalized]','[ndim]','[%]','\sigma'};

%% determine conversion factor and string prefixes to replace
% get factors and labels
[mult_old, label_old] = get_factors(prefix_old);
[mult_new, label_new] = get_factors(prefix_new);
% find the new effective multiplication factor
mult = mult_old / mult_new;

%% verify existing axis units
cnt = 1;
for hfig = figs
    % check if this is a valid figure handle
    if ~ishandle(hfig)
        warning('matspace:YScaleFig', 'Invalid figure handle specified: "%s"', hfig);
        return
    end
    % check that the figure has a valid axis child
    haxs = get(hfig,'children');
    if isempty(haxs)
        warning('matspace:YScaleChildren', 'Specified figure does not contain axis.');
        return
    end
    % loop through children axes
    for a = 1:length(haxs)
        % permit if ylabel property exists
        try
            hyut = get(haxs(a), 'ylabel');
        catch exception
            if strcmp(exception.identifier, 'MATLAB:class:InvalidProperty') || ...
                    strcmp(exception.identifier, 'MATLAB:hg:InvalidProperty')
                hyut = [];
            else
                rethrow(exception);
            end
        end
        % permit when ylabel property is not child to axis tagged as legend
        if strcmp('legend', get(haxs(a), 'tag'))
            hyut = [];
        end
        % accumulate permitted axes
        if ~isempty(hyut)
            yunit{cnt,1} = get(hyut,'string'); %#ok<AGROW>
            cnt = cnt+1;
        end
    end
end
% confirm that at least one permitted axes has the desired string
ixs = strfind(yunit,['[',label_old]);
arr = cellfun(@(x) ~isempty(x),ixs);
if ~all(arr)
    warning('matspace:YScaleLabel', 'invalid ''ylabel'' property ''string'' exists.');
    return
end

%% rescale units
for hfig = figs
    haxs = get(hfig, 'children');
    for a = 1:length(haxs)
        % permit if ylabel property exists
        try
            hyut = get(haxs(a), 'ylabel');
        catch exception
            if strcmp(exception.identifier, 'MATLAB:class:InvalidProperty') || ...
                    strcmp(exception.identifier, 'MATLAB:hg:InvalidProperty')
                hyut = [];
            else
                rethrow(exception);
            end
        end
        % permit when ylabel property is not child to axis tagged as legend
        if strcmp('legend',get(haxs(a),'tag'))
            hyut = [];
        end
        % modify permitted
        if ~isempty(hyut)
            % get ylabel
            yunt   = get(haxs(a),'ylabel');
            ystr   = get(yunt,'string');
            % check for exclusions
            skip   = false;
            for e = 1:length(exclusions)
                if ~isempty(strfind(ystr,exclusions{e}))
                    skip = true;
                end
            end
            if skip
                break
            end
            % modify axis ylabel
            newstr = strrep(ystr, ['[',label_old], ['[',label_new]);
            set(yunt, 'string', newstr);
            % get y data
            hvec = get(haxs(a), 'children');
            ydat = findobj(hvec, '-property', 'ydata');
            % scale vector data
            ymin = inf;
            ymax = -inf;
            for i = 1:length(ydat)
                ydat_scaled = get(ydat(i), 'ydata')*mult;
                ymin = min(ymin, min(min(ydat_scaled)));
                ymax = max(ymax, max(max(ydat_scaled)));
                set(ydat(i),'ydata',ydat_scaled);
            end
            % rescale established xaxis extents
            if strcmp(get(haxs(a), 'ylimmode'), 'manual')
                if ymin == ymax
                    % fix bug where limits can't be identically equal
                    ymin = ymin - 2*eps(ymin);
                    ymax = ymax + 2*eps(ymax);
                end
                set(haxs(a), 'ylim', [ymin, ymax]);
            end
        end
    end
end