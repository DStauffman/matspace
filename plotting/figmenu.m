function figmenu(action)

% FIGMENU   adds Prev, Next, Figs, and Close All menus to all figs
%
% Input:
%     action : |opt| identifies which uimenubutton has been depressed
%                    during callback handling [enumerated]
%                        enumerated values are (next, prev)
%
% Output:
%     (NONE)
%
% Prototype:
%     figure;
%     figure;
%     figmenu;
%
% See Also:
%     (NONE)
%
% Change Log:
%     1.  Added to DStauffman's library from LM in Aug 2013.

use_action = exist('action','var');

%% build lists
if ~use_action
    % list of figures
    figlist = sort(findobj('type','figure'));
    if isempty(figlist)
        disp([mfilename,': no figs found.'])
        return
    end
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
                                l = figchch(k).Label;
                                switch l
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
        if isa(f,'matlab.ui.Figure')
            use_new = true;
        else
            use_new = false;
        end
        % if you add a menu item, don't forget to delete it (above)
        % whenever figmenu is run again, otherwise Matlab will crash,
        % because you'll keep adding menu items until you run out of
        % memory...
        menu1 = uimenu(f);
        set(menu1,'Label','Figures');
        menu2 = uimenu(f);
        set(menu2,'Label','<<','Callback',[mfilename,'(''prev'')']);
        menu3 = uimenu(f);
        set(menu3,'Label','>>','Callback',[mfilename,'(''next'')']);
        menu4 = uimenu(f);
        set(menu4,'Label','Close All','Callback','close all');
        % create a menu item for each figure
        for j = 1:nfigs
            f = figlist(j);
            n = char(fignames(j));
            eval(sprintf('item%i = uimenu(menu1);',j))
            if ~use_new
                eval(sprintf('set(item%i,''Label'',''&%i: %s'')',j,f,n));
                eval(sprintf('set(item%i,''Callback'',''figure(%i)'')',j,f));
            else
                eval(sprintf('set(item%i,''Label'',''&%i: %s'')',j,f.Number,n));
                eval(sprintf('set(item%i,''Callback'',''figure(%i)'')',j,f.Number));
            end
        end
    end
else
    
    %% execute callbacks for >> and << menubuttons
    if strcmp(action,'next')
        fh = sort(get(0,'Children'));
        % if only one figure, simply exit
        if length(fh) == 1
            return
        end
        i = find(fh>gcf);
        if ~isempty(i)
            next = fh(i(1));
            figure(next);
        else
            next = fh(1);
            figure(next);
        end
    elseif strcmp(action,'prev')
        fh = sort(get(0,'Children'));
        % if only one figure, simply exit
        if length(fh) == 1
            return
        end
        i = find(fh<gcf);
        if ~isempty(i)
            prev = fh(i(end));
            figure(prev);
        else
            prev = fh(end);
            figure(prev);
        end
    else
        error('invalid option!')
    end
end