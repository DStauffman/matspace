function [fig_hand, err] = plot_states(kf1, kf2, varargin)

% Plots the Kalman Filter state histories.
%
% Input:
% kf1 : class Kf
%     Kalman filter output
% kf2 : class Kf, optional
%     Second filter output for potential comparison
% truth : class Kf, optional
%     Third filter output that is considered truth
% opts : class Opts, optional
%     Plotting options
% skip_setup_plots : bool, optional, default is False
%     Whether to skip the setup_plots step
% groups : iterable of ints
%     How to group plots based on state numbers
% fields : dict[str, str], optional
%     Fields to plot, default is covar and Covariance
% **kwargs : dict
%     Additional keyword arguments to override plotting options or pass to lower level plot function
%
% Output:
% fig_hand : list of class matplotlib.figure.Figure
%     Figure handles
% err : dict
%     Numerical outputs of comparison
%
% Prototype:
%     num_points = 11;
%     num_states = 6;
%
%     kf1        = [];  % Kf();
%     kf1.name   = 'KF1';
%     kf1.time   = 0:10;
%     kf1.state   = 1e-6 * ones(num_states, num_points);
%     kf1.active = [1, 2, 3, 4, 8, 12];
%
%     kf2        = [];  % Kf();
%     kf2.name   = 'KF2';
%     kf2.time   = kf1.time;
%     kf2.state  = kf1.state + 1e-9 * rand(size(kf1.state));
%     kf2.active = kf1.active;
%
%     opts = matspace.plotting.Opts();
%     opts.case_name = 'test_plot';
%     opts.sub_plots = true;
%
%     fig_hand = matspace.plotting.gnds.plot_states(kf1, kf2, opts=opts);
%
%     % Close plots
%     close(fig_hand);
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2026.

%% Imports
import matspace.plotting.Opts
import matspace.plotting.gnds.plot_covariance
import matspace.plotting.private.fun_is_bool
import matspace.plotting.private.fun_is_dict
import matspace.plotting.private.fun_is_gnd
import matspace.plotting.private.fun_is_groups
import matspace.plotting.private.fun_is_opts

%% Parser
% Argument parser
p = inputParser;
p.KeepUnmatched = true;
addRequired(p, 'Kf1', @fun_is_gnd);
addRequired(p, 'Kf2', @fun_is_gnd);
addParameter(p, 'Opts', Opts(), @fun_is_opts);
addParameter(p, 'Truth', [], @fun_is_gnd);
addParameter(p, 'SkipSetupPlots', false, @fun_is_bool);
addParameter(p, 'Groups', [], @fun_is_groups);
addParameter(p, 'Fields', '', @fun_is_dict);
% do parse
parse(p, kf1, kf2, varargin{:});
% create some convenient aliases
opts             = p.Results.Opts;
truth            = p.Results.Truth;
skip_setup_plots = p.Results.SkipSetupPlots;
groups           = p.Results.Groups;
fields           = p.Results.Fields;
unmatched        = p.Unmatched;

% check optional inputs
if isempty(fields)
    fields = dictionary('state', 'State Estimates');
end
unmatched_args = namedargs2cell(unmatched);
[fig_hand, err] = plot_covariance(...
    kf1, ...
    kf2, ...
    unmatched_args{:}, ...
    Truth=truth, ...
    Opts=opts, ...
    SkipSetupPlots=skip_setup_plots, ...
    Groups=groups, ...
    Fields=fields);