function [] = setup_plots(fig_hand, opts)

% SETUP_PLOTS  applies each plot preference in one function.
%
% Summary:
%     None
%
% Input:
%      fig_hand       : (1xN) figure handles [num]
%      opts           : (class) optional plot settings
%          .case_name
%          .save_plot
%          .plot_type
%          .save_path
%          .show_link
%          .plot_locs
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
%     opts.save_plot = true;
%     opts.plot_type = 'png';
%     opts.save_path = matspace.paths.get_root_dir();
%     matspace.plotting.setup_plots(f, opts);
%
%     % clean up
%     close(f);
%     delete(fullfile(matspace.paths.get_root_dir, 'NULL - Something Plot.png'));
%
% See Also:
%     matspace.plotting.titleprefix, matspace.plotting.storefig, matspace.plotting.plot_classification
%
% Change Log:
%     1.  Added to matspace library from GARSE in Sept 2013.
%     2.  Updated by David C. Stauffer in March 2020 to support datetime time vectors.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.
%     4.  Updated by David C. Stauffer in March 2026 to remove X-scale and Y-scale options.

%% Arguments
arguments
    fig_hand (1, :) matlab.ui.Figure
    opts (1, 1) matspace.plotting.Opts
end

%% Imports
import matspace.plotting.get_classification
import matspace.plotting.plot_classification
import matspace.plotting.set_plot_location
import matspace.plotting.shift_axes_up
import matspace.plotting.storefig
import matspace.plotting.titleprefix

%% Initializations
% check for empty input
if isempty(fig_hand)
    return
end
% ensure fig_hand is a row vector
fig_hand = fig_hand(:)';

%% opts Aliases
update_name    = ~isempty(opts.case_name);
save_plot      = opts.save_plot;
have_save_path = ~isempty(opts.save_path);
show_link      = opts.show_link;
move_plots     = ~strcmp(opts.plot_locs, 'default');
plot_type      = opts.plot_type;

%% append case name to plots
if update_name
    titleprefix(fig_hand,[opts.case_name,' - ']);
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