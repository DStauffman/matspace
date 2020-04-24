function storefig(fig_hand,path,format) %#ok<*MCPRT>

% STOREFIG  store figures to directory in specified format.
%
% Summary:
%     (NONE)
%
% Input:
%     fig_hand : (1xN) figure handles [numeric]
%     path     : (row) existing storage directory path [string]
%     format   : (row) figure format [enumerated string]
%                      enumerated values are ('png', 'emf', 'fig', 'jpg') see note 1.
%
% Output:
%     \figname.format : various output files named according to their workspace name
%                       saved as extension type specified by "format"
%
% Prototype:
%     f1 = figure(5);
%     hold on;
%     set(gcf,'name','fig5');
%     title('somethingA');
%     plot(linspace(0,3600),1+randn(1,100),'r');
%     legend('r');
%     xlabel('something [sec]');
%     ylabel('something');
%     matspace.plotting.figmenu;
%
%     f2 = figure(6);
%     hold on;
%     set(gcf,'name','fig6');
%     title('somethingB');
%     plot(linspace(0,3600),1+randn(1,100),'r');
%     legend('r');
%     xlabel('something [sec]');
%     ylabel('something');
%     matspace.plotting.figmenu;
%
%     folder = matspace.paths.get_root_dir();
%     matspace.plotting.storefig([f1 f2],folder,'png');
%
%     % clean up
%     close([f1 f2]);
%     delete(fullfile(folder, 'fig5.png'));
%     delete(fullfile(folder, 'fig6.png'));
%
% See Also:
%     matspace.plotting.titleprefix, matspace.plotting.xextents, matspace.plotting.xscale_plots,
%     matspace.plotting.setup_plots
%
% Notes:
%     1.  "format" can also be a cell array to save the plots as multiple different types.
%
% Change Log:
%     1.  Added to matspace library in Sept 2013.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

% Imports
import matspace.plotting.resolve_name

% optional inputs
switch nargin
    case 1
        path   = pwd;
        format = 'png';
    case 2
        format = 'png';
    case 3
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% confirm that handles are valid figures
for f = fig_hand
    hfig = f;
    if ~ishandle(hfig)
        warning('matspace:plotting:storeFigBadHandle', 'Invalid figure handle specified: "%i".',hfig);
        return
    end
    haxs = get(hfig,'children');
    if isempty(haxs)
        warning('matspace:plotting:storeFigBadAxes', 'Specified figure "%i" does not contain an axis.', hfig);
        return
    end
end

% confirm whether storage directory exists
if ~exist(path, 'dir')
    warning('matspace:plotting:storeFigBadPath', 'Specified storage path not found: "%s".', path);
    return
end

% make formats always be a cell array
if ~iscell(format)
    format = {format};
end

% get figure name
fig_name = get(fig_hand,'name');
if ~iscell(fig_name)
    fig_name = {fig_name};
end

% resolve any name issues
fig_name = resolve_name(fig_name);

% save plots
for f = 1:length(fig_hand)
    for i = 1:length(format)
        switch format{i}
            case 'png'
                print(fig_hand(f), '-dpng', fullfile(path, [fig_name{f},'.png']));
            case 'emf'
                print(fig_hand(f), '-dmeta', fullfile(path, [fig_name{f},'.emf']));
            case 'fig'
                saveas(fig_hand(f), fullfile(path, [fig_name{f},'.fig']));
            case 'jpg'
                print(fig_hand(f), '-djpeg', fullfile(path, [fig_name{f},'.jpg']));
            otherwise
                warning('matspace:plotting:storeFigBadExt', 'Unexpected extension type "%s"; plot not saved.', format{i});
        end
    end
end