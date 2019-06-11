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
%     figmenu;
%
%     f2 = figure(6);
%     hold on;
%     set(gcf,'name','fig6');
%     title('somethingB');
%     plot(linspace(0,3600),1+randn(1,100),'r');
%     legend('r');
%     xlabel('something [sec]');
%     ylabel('something');
%     figmenu;
%
%     import matspace.get_root_dir
%     folder = get_root_dir();
%     storefig([f1 f2],folder,'png');
%
%     % clean up
%     close([f1 f2]);
%     delete(fullfile(folder, 'fig5.png'));
%     delete(fullfile(folder, 'fig6.png'));
%
% See Also:
%     titleprefix    xextents    xscale_plots    setup_plots
%
% Notes:
%     1.  "format" can also be a cell array to save the plots as multiple different types.
%
% Change Log:
%     1.  Added to DStauffman's MATLAB library in Sept 2013.

% confirm that handles are valid figures
for f = fig_hand
    hfig = f;
    if ~ishandle(hfig)
        warning('dstauffman:plotting:storeFigBadHandle', 'Invalid figure handle specified: "%i".',hfig);
        return
    end
    haxs = get(hfig,'children');
    if isempty(haxs)
        warning('dstauffman:plotting:storeFigBadAxes','Specified figure "%i" does not contain an axis.', hfig);
        return
    end
end

% add filesep to end of path if necessary
if ~strcmp(path(end),filesep)
    path = [path,filesep];
end

% confirm whether storage directory exists
if ~exist(path,'dir')
    warning('dstauffman:plotting:storeFigBadPath','Specified storage path not found: "%s".', path);
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

% check for illegal characters and replace with underscores
if ispc
    bad_chars = {'<','>',':','"','/','\','|','?','*'};
else
    bad_chars = {'/'};
end
bad_names = false(size(fig_name));
for i = 1:length(bad_chars)
    ix = ~cellfun(@isempty,strfind(fig_name,bad_chars{i}));
    if any(ix)
        fig_name  = strrep(fig_name,bad_chars{i},'_');
        bad_names = bad_names & ix;
    end
end
if any(bad_names)
    disp('Bad name(s):');
    disp(fig_name(bad_names));
    warning('dstauffman:plotting:storeFigIllegalChars','There were illegal characters in the figure name.');
end

% save plots
for f = 1:length(fig_hand)
    for i = 1:length(format)
        switch format{i}
            case 'png'
                print(fig_hand(f),'-dpng',[path,fig_name{f},'.png']);
            case 'emf'
                print(fig_hand(f),'-dmeta',[path,fig_name{f},'.emf']);
            case 'fig'
                saveas(fig_hand(f),[path,fig_name{f},'.fig']);
            case 'jpg'
                print(fig_hand(f),'-djpeg',[path,fig_name{f},'.jpg']);
            otherwise
                warning('dstauffman:plotting:storeFigBadExt','Unexpected extension type "%s"; plot not saved.', format{i});
        end
    end
end