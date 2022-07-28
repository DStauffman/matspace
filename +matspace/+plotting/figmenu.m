function [] = figmenu(action)

% FIGMENU   adds Prev, Next, Figs, and Close All menus to all figs
%
% Input:
%     action : |opt| identifies which uimenubutton has been depressed
%                    during callback handling [enumerated]
%                        enumerated values are (next, prev)
%
% Output:
%     None - adds buttons to plot toolbar on figures
%
% Prototype:
%     f1 = figure;
%     f2 = figure;
%     matspace.plotting.figmenu;
%
%     % clean up
%     close([f1 f2]);
%
% See Also:
%     matspace.plotting.setup_plots
%
% Change Log:
%     1.  Added to matspace library from LM in Aug 2013.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

%% hard-coded values
% TODO: figure out how to get name of package programmatically
% Was: mfilename
% Could be: ['matspace.plotting.', mfilename]
% Now:
callback_name = 'matspace.plotting.figmenu';

%% Compatibility options
use_action = exist('action','var');
if verLessThan('matlab','9.3')
    % support for R2016B and earlier, TODO: R2017A (9.2) is untested
    text_field = 'Label';
    char10 = char(10); %#ok<CHARTEN>
else
    % support for R2017B and newer
    text_field = 'Text';
    char10 = newline;
end

%% build lists
if ~use_action
    % list of figures
    figlist = findobj('type','figure');
    if isempty(figlist)
        disp([callback_name,': no figs found.'])
        return
    end
    figlist    = sortfigs(figlist);
    fignames   = get(figlist,'name');
    if ~iscell(fignames)
        fignames = {fignames};
    end
    is_unnamed = find(cellfun(@isempty,fignames));
    fignames(is_unnamed) = arrayfun(@(x) ['Hello Figure ',int2str(x)],is_unnamed,'UniformOutput',false);
    nfigs      = length(figlist);

    %% delete existing NEXT, PREV, or FIGURES menus
    for i = 1:nfigs
        if ishandle(figlist(i))
            figch = get(figlist(i),'Children');
            if ~isempty(figch)
                for j = 1:length(figch)
                    figchch = get(figch(j));
                    if ~isempty(figchch)
                        if strcmp(figchch.Type,'uimenu')
                            for k = 1:length(figchch)
                                label = figchch(k).(text_field);
                                switch label
                                    case {'Figures','<<','>>','Close All'}
                                        delete(figch(j));
                                    otherwise
                                        % nop
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    %% add NEXT, PREV, and FIGURES menus
    for i = 1:nfigs
        f = figlist(i);
        % if you add a menu item, don't forget to delete it (above)
        % whenever figmenu is run again, otherwise Matlab will crash,
        % because you'll keep adding menu items until you run out of
        % memory...
        menu1 = uimenu(f);
        set(menu1,text_field,'Figures');
        menu2 = uimenu(f);
        set(menu2,text_field,'<<','Callback',[callback_name,'(''prev'')']);
        menu3 = uimenu(f);
        set(menu3,text_field,'>>','Callback',[callback_name,'(''next'')']);
        menu4 = uimenu(f);
        set(menu4,text_field,'Close All','Callback','close all');
        % create a menu item for each figure
        for j = 1:nfigs
            f = figlist(j);
            n = strrep(fignames{j}, char10, '; ');
            eval(sprintf('item%i = uimenu(menu1);',j))
            eval(sprintf('set(item%i,''%s'',''&%s: %s'')',j,text_field,fignum_to_str(f),n));
            eval(sprintf('set(item%i,''Callback'',''figure(%s)'')',j,fignum_to_str(f)));
        end
    end
else

    %% execute callbacks for >> and << menubuttons
    % get sorted list of figures
    figs = sortfigs(get(0,'Children'));
    % if only one figure, simply exit
    if length(figs) == 1
        return
    end
    % find the next or prev figure, and set it as the active one
    switch action
        case 'next'
            next = find_fig(figs, true);
            figure(next);
        case 'prev'
            prev = find_fig(figs, false);
            figure(prev);
        otherwise
            error('matspace:plotting:figMenuInvalidOpiton', 'Invalid option!');
    end
end

%% Subfunctions - sortfigs
function [figs] = sortfigs(figs)
% Stores the given figure handles for old and new versions of Matlab.
if ~isnumeric(figs)
    % fix bug in sorting for newer matlab.ui.Figure classes that aren't just numeric
    [~, sort_ix] = sort([figs.Number]);
    figs = figs(sort_ix);
else
    figs = sort(figs);
end

%% Subfunctions - fignum_to_str
function [text] = fignum_to_str(fig)
% Converts a figure number to text for old and new versions of Matlab.
if isa(fig, 'matlab.ui.Figure')
    text = int2str(fig.Number);
else
    text = int2str(fig);
end

%% Subfunctions - find_fig
function [fig] = find_fig(figs, next)
% Finds the next or previous figure
this_fig = gcf;
if next
    if isa(this_fig, 'matlab.ui.Figure')
        ix = find([figs.Number] > this_fig.Number, 1, 'first');
    else
        ix = find(figs > gcf, 1, 'first');
    end
    if ~isempty(ix)
        fig = figs(ix(1));
    else
        fig = figs(1);
    end
else
    if isa(this_fig, 'matlab.ui.Figure')
        ix = find([figs.Number] < this_fig.Number, 1, 'last');
    else
        ix = find(figs < gcf, 1, 'last');
    end
    if ~isempty(ix)
        fig = figs(ix(1));
    else
        fig = figs(end);
    end
end