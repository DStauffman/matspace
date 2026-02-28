function [] = setup_plots(fig_hand, opts, form)

% SETUP_PLOTS  applies each plot preference in one function.
%
% Summary:
%     None
%
% Input:
%      fig_hand       : (1xN) figure handles [num]
%      opts           : (class) optional plot settings
%          .case_name
%          .disp_xmin
%          .disp_xmax
%          .time_unit
%          .save_plot
%          .plot_type
%          .save_path
%      form           : |opt| (row) specify form of plot [enumerated string]
%                                   from:
%                                       'time', X-axis is time, scale Y-axis
%                                       'dist', X-axis is not time, scale Y-axis
%                                       'time_no_y_scale', X-axis is time, don't scale Y-axis
%                                       'dist_no_y_scale', X-axis is not time, don't scale Y-axis
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
%
%     opts           = matspace.plotting.Opts();
%     opts.case_name = 'NULL';
%     opts.disp_xmin = 100;
%     opts.disp_xmax = 580;
%     opts.time_unit = 'min';
%     opts.save_plot = true;
%     opts.plot_type = 'png';
%     opts.save_path = matspace.paths.get_root_dir();
%     matspace.plotting.setup_plots(f, opts, 'time');
%
%     % clean up
%     close(f);
%     delete(fullfile(matspace.paths.get_root_dir, 'NULL - Something Plot.png'));
%
% See Also:
%     matspace.plotting.titleprefix, matspace.plotting.xextents, matspace.plotting.xscale_plots,
%     matspace.plotting.storefig, matspace.plotting.yscale_plots
%
% Change Log:
%     1.  Added to matspace library from GARSE in Sept 2013.
%     2.  Updated by David C. Stauffer in March 2020 to support datetime time vectors.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.

%% Arguments
arguments
    fig_hand (1, :) matlab.ui.Figure
    opts (1, 1) matspace.plotting.Opts
    form {mustBeMember(form, ["time", "dist", "time_no_y_scale", "dist_no_y_scale"])} = 'time'
end

%% Imports
import matspace.plotting.get_classification
import matspace.plotting.get_time_factor
import matspace.plotting.plot_classification
import matspace.plotting.set_plot_location
import matspace.plotting.shift_axes_up
import matspace.plotting.storefig
import matspace.plotting.titleprefix
import matspace.plotting.xextents
import matspace.plotting.xscale_plots
import matspace.plotting.yscale_plots

%% Initializations
% check for empty input
if isempty(fig_hand)
    return
end
% ensure fig_hand is a row vector
fig_hand = fig_hand(:)';

%% Check valid forms
if ~any(strcmp(form, {'time', 'dist', 'time_no_y_scale', 'dist_no_y_scale'}))
    error('matspace:UnexpectedForm', 'Unexpected plot form of "%s".', form);
end

%% opts Aliases
update_name     = ~isempty(opts.case_name);
scale_xaxis     = ~isempty(opts.time_unit) && ~strcmp(opts.time_unit, 'datetime') && ...
    ~strcmp(opts.time_base, opts.time_unit);
change_xextents = (~isinf(opts.disp_xmin) || ~isinf(opts.disp_xmax)) && ...
    (~isdatetime(opts.disp_xmin) || ~isnat(opts.disp_xmin) && (~isdatetime(opts.disp_xmax) || ~isnat(opts.disp_xmax)));
save_plot       = opts.save_plot;
have_save_path  = ~isempty(opts.save_path);
show_link       = opts.show_link;
move_plots      = ~strcmp(opts.plot_locs, 'default');
plot_type       = opts.plot_type;

%% append case name to plots
if update_name
    titleprefix(fig_hand,[opts.case_name,' - ']);
end

if any(strcmp(form, {'time','time_no_y_scale'}))
    %% Change x-axis scale
    if scale_xaxis
        xscale_plots(fig_hand,['[',opts.time_base,']'],['[',opts.time_unit,']']);
    end

    %% Change x-axis extents
    if change_xextents
        if scale_xaxis
            mult = get_time_factor(opts.time_unit);
            xextents(fig_hand, opts.disp_xmin/mult, opts.disp_xmax/mult);
        else
            xextents(fig_hand, opts.disp_xmin, opts.disp_xmax);
        end
    end
end

%% Label plot classification
[classification, caveat] = get_classification(opts.classify);
if ~isempty(classification)
    shift_axes_up(fig_hand, 0.08);
end
plot_classification(fig_hand, classification, caveat=caveat);

%% Move plots
if move_plots
    set_plot_location(fig_hand, opts.plot_locs);
end

%% Save Plots
if save_plot
    if have_save_path
        save_path = opts.save_path;
    else
        save_path = pwd;
    end
    storefig(fig_hand, save_path, plot_type);
    if show_link && ~isempty(fig_hand)
        fprintf('Plots saved to: <a href="matlab: web(''%s'',''-browser'');">%s</a>\n',save_path,save_path);
    end
end