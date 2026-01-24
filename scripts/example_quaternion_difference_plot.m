% Plot some quaternion differences.

%% Imports
import matspace.quaternions.quat_from_euler
import matspace.quaternions.quat_mult
import matspace.quaternions.quat_norm
%import matspace.plotting.COLOR_LISTS
import matspace.plotting.Opts
import matspace.plotting.plot_quaternion
import matspace.plotting.plot_time_difference

%% Script
% build data
q1 = quat_norm([0.1; -0.2; 0.3; 0.4]);
dq = quat_from_euler(1e-6 * [-300; 100; 200], [3, 1, 2]);
q2 = quat_mult(dq, q1);

time_one = 0:10;
quat_one = repmat(q1, size(time_one));

time_two = 2:12;
quat_two = repmat(q2, size(time_two));
quat_two(4, 5) = quat_two(4, 5) + 50e6;
quat_two = quat_norm(quat_two);

% plotting options
opts = Opts();
opts.case_name = 'test_plot';
opts.quat_comp = false;
opts.sub_plots = false;
opts.sing_line = true;
opts.names = ["KF1", "KF2"];

% make plots
figs1 = matspace.plotting.plot_quaternion('Quaternion', time_one, time_two, quat_one, quat_two, opts=opts);

figs2 = matspace.plotting.plot_time_difference(...
    'State Differences', ...
    time_one, ...
    quat_one, ...
    time_two, ...
    quat_two, ...
    opts=opts, ...
    elements=["X", "Y", "Z", "S"], ...
    colormap=COLOR_LISTS.quat_comp, ...
    units='rad', ...
    second_units='micro');
