function [] = setup_plots(fig_hand,OPTS,form)

% SETUP_PLOTS  applies each plot preference in one function.
%
% Summary:
%     None
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
%     None
%
% Prototype:
%     f = figure('name', 'Something Plot');
%     hold on;
%     plot(linspace(0, 3600), 0.1 + randn(1, 100), 'r');
%     plot(linspace(0, 3600), 0.2 + randn(1, 100), 'b');
%     plot(linspace(0, 3600), 0.3 + ones(1, 100), 'g');
%     plot([0, 3600], [1.3, 1.3], 'ko');
%     title(get(f, 'name'), 'Interpreter', 'none');
%     hold off;
%     legend('r', 'b', 'g');
%     xlabel('something [sec]');
%     ylabel('something [rad]');
%     figmenu;
%
%     import matspace.get_root_dir
%
%     OPTS           = Opts();
%     OPTS.case_name = 'NULL';
%     OPTS.disp_xmin = 100;
%     OPTS.disp_xmax = 580;
%     OPTS.time_unit = 'min';
%     OPTS.save_plot = true;
%     OPTS.plot_type = 'png';
%     OPTS.save_path = get_root_dir();
%     OPTS.vert_fact = 'milli';
%     setup_plots(f, OPTS, 'time');
%
%     % clean up
%     close(f);
%     delete(fullfile(get_root_dir, 'NULL - Something Plot.png'));
%
% See Also:
%     titleprefix, xextents, xscale_plots, storefig, yscale_plots
%
% Change Log:
%     1.  Added to matspace library from GARSE in Sept 2013.
%     2.  Updated by David C. Stauffer in March 2020 to support datetime time vectors.

%% Initializations
switch nargin
    case 2
        form = 'time';
    case 3
        %nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end
% check for empty input
if isempty(fig_hand)
    return
end
% ensure fig_hand is a row vector
fig_hand = fig_hand(:)';

%% Check valid forms
if ~any(strcmp(form,{'time','dist','time_no_y_scale','dist_no_y_scale'}))
    error('matspace:UnexpectedForm', 'Unexpected plot form of "%s".', form);
end

%% OPTS Aliases
update_name     = ~isempty(OPTS.case_name);
scale_xaxis     = ~isempty(OPTS.time_unit) && ~strcmp(OPTS.time_unit, 'datetime') && ...
    ~strcmp(OPTS.time_base, OPTS.time_unit);
change_xextents = ~isinf(OPTS.disp_xmin) || ~isinf(OPTS.disp_xmax);
scale_yaxis     = any(strcmp(form, {'time', 'dist'}));
save_plot       = OPTS.save_plot;
have_save_path  = ~isempty(OPTS.save_path);
show_link       = OPTS.show_link;
move_plots      = ~strcmp(OPTS.plot_locs, 'default');
plot_type       = OPTS.plot_type;

%% append case name to plots
if update_name
    titleprefix(fig_hand,[OPTS.case_name,' - ']);
end

if any(strcmp(form,{'time','time_no_y_scale'}))
    %% Change x-axis scale
    if scale_xaxis
        xscale_plots(fig_hand,['[',OPTS.time_base,']'],['[',OPTS.time_unit,']']);
    end

    %% Change x-axis extents
    if change_xextents
        if scale_xaxis
            switch OPTS.time_unit
                case 'epoch'
                    mult = 1/400;
                case 'sec'
                    mult = 1;
                case 'min'
                    mult = 60;
                case 'hr'
                    mult = 3600;
                case 'day'
                    mult = 86400;
                otherwise
                    error('matspace:plotting:BadOptsTimeUnit', 'Unexpected value for ''OPTS.time_unit''.');
            end
            xextents(fig_hand, OPTS.disp_xmin/mult, OPTS.disp_xmax/mult);
        else
            xextents(fig_hand, OPTS.disp_xmin, OPTS.disp_xmax);
        end
    end
end

%% Scale the y-axis
if scale_yaxis
    yscale_plots(fig_hand,'unity',OPTS.vert_fact);
end

%% Label plot classification
[classification, caveat] = get_classification(OPTS.classify);
plot_classification(fig_hand, classification, caveat);

%% Move plots
if move_plots
    set_plot_location(fig_hand,OPTS.plot_locs);
end

%% Save Plots
if save_plot
    if have_save_path
        save_path = OPTS.save_path;
    else
        save_path = pwd;
    end
    storefig(fig_hand, save_path, plot_type);
    if show_link && ~isempty(fig_hand)
        fprintf('Plots saved to: <a href="matlab: web(''%s'',''-browser'');">%s</a>\n',save_path,save_path);
    end
end