function [] = setup_plots(fig_hand,OPTS,form)

% SETUP_PLOTS  applies each plot preference in one function.
%
% Summary:
%     (NONE)
%
% Input:
%      fig_hand       : (1xN) figure handles [num]
%      OPTS           : (class) optional plot settings
%          .case_name
%          .disp_xmin
%          .disp_xmax
%          .time_unit
%          .save_plot
%          .plot_type
%          .save_path
%      form           : |opt| (row) specify form of plot [enumerated string]
%                                      'time', X-axis is time, scale Y-axis
%                                      'dist', X-axis is not time, scale Y-axis
%                                      'time_no_y_scale', X-axis is time, don't scale Y-axis
%                                      'dist_no_y_scale', X-axis is not time, don't scale Y-axis
%
% Output:
%     (NONE)
%
% Prototype:
%     f = figure('name','Something Plot');
%     hold on;
%     plot(linspace(0,3600),0.1+randn(1,100),'r');
%     plot(linspace(0,3600),0.2+randn(1,100),'b');
%     plot(linspace(0,3600),0.3+ones(1,100),'g');
%     plot([0,3600],[1.3,1.3],'ko');
%     title(get(f,'name'),'Interpreter','none');
%     hold off;
%     legend('r','b','g');
%     xlabel('something [sec]');
%     ylabel('something [rad]');
%     figmenu;
%
%     OPTS.case_name = 'NULL';
%     OPTS.disp_xmin = 100;
%     OPTS.disp_xmax = 580;
%     OPTS.time_unit = 'min';
%     OPTS.save_plot = true;
%     OPTS.plot_type = 'png';
%     OPTS.save_path = pwd;
%     OPTS.vert_fact = 'milli';
%     setup_plots(f,OPTS,'time');
%
% See Also:
%     titleprefix.m, xextents.m, xscale_plots.m, storefig.m, yscale_plots.m
%
% Change Log:
%     1.  Added to DStauffman's MATLAB library from GARSE in Sept 2013.

%% Initializations
switch nargin
    case 2
        form = 'time';
    case 3
        %nop
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%s"', nargin);
end
% check for empty input
if isempty(fig_hand)
    return
end
% ensure fig_hand is a row vector
fig_hand = fig_hand(:)';

%% append case name to plots
if isfield(OPTS,'case_name')
    titleprefix(fig_hand,[OPTS.case_name,' - ']);
end

if any(strcmp(form,{'time','time_no_y_scale'}))
    %% Change x-axis scale
    % if isfield(OPTS,'time_unit')
    %     xscale_plots(fig_hand,'[sec]',['[',OPTS.time_unit,']']);
    % end
    
    %% Change x-axis extents
    % if isfield(OPTS,'disp_xmin') && isfield(OPTS,'disp_xmax')
    %     if isfield(OPTS,'time_unit')
    %         switch OPTS.time_unit
    %             case 'epoch'
    %                 mult = 1/400;
    %             case 'sec'
    %                 mult = 1;
    %             case 'min'
    %                 mult = 60;
    %             case 'hr'
    %                 mult = 3600;
    %             case 'day'
    %                 mult = 86400;
    %             otherwise
    %                 error('dstauffman:plotting:BadOptsTimeUnit', 'Unexpected value for "OPTS.time_unit".');
    %         end
    %     else
    %         mult = 1;
    %     end
    %     xextents(fig_hand,OPTS.disp_xmin/mult,OPTS.disp_xmax/mult);
    % end
end

%% Scale the y-axis
% if any(strcmp(form,{'time','dist'}))
%     if isfield(OPTS,'vert_fact')
%         yscale_plots(fig_hand,'unity',OPTS.vert_fact);
%     end
% end

%% Label plot classification
% % determine classification (hard-coded to false for now)
% mloc     = mfilename('fullpath');
% ix       = strfind(mloc,filesep);
% location = mloc(1:ix(end));
% if false
%     classification = 'S';
% else
%     classification = 'U';
% end
% plot_classification(fig_hand,classification);

%% Save Plots
if isfield(OPTS,'save_plot')
    if OPTS.save_plot
        if isfield(OPTS,'save_path')
            save_path = OPTS.save_path;
        else
            save_path = pwd;
        end
        if isfield(OPTS,'plot_type')
            plot_type = OPTS.plot_type;
        else
            plot_type = 'png';
        end
        storefig(fig_hand,save_path,plot_type);
        if isfield(OPTS,'show_link') && OPTS.show_link && ~isempty(fig_hand)
            fprintf('Plots saved to: <a href="matlab: web(''%s'',''-browser'');">%s</a>\n',save_path,save_path);
        end
    end
end