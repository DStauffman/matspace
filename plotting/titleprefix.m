function titleprefix(fig_hand,prefix)

% TITLEPREFIX  add title prefix to single axis figures.
%
% Summary:
%     1.  Determines children of figure handles
%     2.  Children that are not tagged as legends and that
%         also maintain child title handles are presumed
%         to be plot axis within which child title handles
%         maintain title string properties
%     3.  Function adds prefix to all title strings taking
%         care to express '\' and '_' characters using
%         appropriate string syntax which implies that
%         special subscript chracters are unsupported
%     4.  For compatability with figumenu tool also adds
%         prefix to figure name and reinitializes figmenu
%
% Input:
%     fig_hand : (1xN) figure handles [num]
%     prefix   : (row) title prefix to be left concatenated [char]
%
% Output:
%     (NONE)
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
%     grid on;
%
%     f2 = figure(6);
%     hold on;
%     set(gcf,'name','fig6');
%     title('somethingB');
%     plot(linspace(0,3600),1+randn(1,100),'r');
%     legend('r');
%     xlabel('something [sec]');
%     ylabel('something');
%     grid on;
%     figmenu;
%
%     titleprefix([f1 f2],'pre\pre_');
%
%     % clean up
%     close([f1 f2]);
%
% See Also:
%     xextents    xscale_plots    storefig    setup_plots
%
% Change Log:
%     1.  Added to DStauffman's MATLAB library from GARSE in Sept 2013.

%% Tests
% confirm that handles are valid figures, and that they have at least one axis child
if any(~ishandle(fig_hand))
    warning('dstauffman:utils:titleprefix','invalid figure handle specified');
    return
end
haxs = get(fig_hand,'children');
if ~iscell(haxs)
    haxs = {haxs};
end
if any(cellfun(@isempty,haxs))
    warning('dstauffman:utils:titleprefix','specified figure does not contain axis');
    return
end

%% prepend title prefix
for i = 1:length(fig_hand)
    for j = 1:length(haxs{i})
        this_axis = haxs{i}(j);
        % permit if title property exists
        try
            htit = get(this_axis,'title');
        catch exception
            if any(strcmp(exception.identifier,{'MATLAB:class:InvalidProperty','MATLAB:hg:InvalidProperty'}))
                htit = [];
            else
                rethrow(exception);
            end
        end
        % permit when handle is not tagged as legend
        if strcmp('legend',get(this_axis,'tag'))
            htit = [];
        end
        % modify if all tests say it is permitted
        if ~isempty(htit)
            % format title prefix based on interpreter value
            switch get(htit,'Interpreter')
                case {'latex','tex'}
                    fprefix = strrep(prefix,'\','\\');
                    fprefix = strrep(fprefix,'_','\_');
                case 'none'
                    fprefix = prefix;
                otherwise
                    error('dstauffman:plotting:BadTitleInterpreterOption', 'Unexpected value for the title interpreter.');
            end
            old_title = get(htit,'string');
            if ~isempty(old_title)
                set(htit,'string',[fprefix,old_title]);
            end
        end
    end
    % also modify figure name
    old_name = get(fig_hand(i),'name');
    set(fig_hand(i),'name',[prefix,old_name]);
end
% recall figmenu to update
figmenu;