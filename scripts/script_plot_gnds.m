% Script to run the GND plots with different time and opts combinations.

%% Flags
plots = dictionary();
plots{'att'} = true;
plots{'pos'} = false;
plots{'inn'} = false;
plots{'fpl'} = false;
plots{'his'} = false;
plots{'cov'} = false;
plots{'los'} = false;
plots{'sts'} = false;

%% Initializations
q1 = matspace.quaternions.quat_norm([0.1; -0.2; 0.3; 0.4]);
dq = matspace.quaternions.quat_from_euler(1e-6 * [-300; 100; 200], [3, 1, 2]);
q2 = matspace.quaternions.quat_mult(dq, q1);

date_zero = datetime(2020, 12, 19, 14, 20, 0);

num_points = 11;
num_states = 6;
num_axes   = 2;
num_innovs = 11;

t_bounds1 = [2, 8];
t_bounds2 = date_zero + seconds(t_bounds1);

bins = [inf, -5e-6, -5e-7, 0.0, 5e-7, 5e-6, inf];

%% KF1
kf1        = [];
kf1.name   = 'KF1';
kf1.time   = linspace(0, 10, num_points);
kf1.att    = repmat(q1, size(kf1.time));
kf1.pos    = 1e6 * rand(3, length(kf1.time));
kf1.vel    = 1e3 * rand(3, length(kf1.time));
kf1.covar  = 1e-6 * repmat(1:num_states, [1, num_points]);
kf1.active = [1, 2, 3, 4, 8, 12];

kf1.innov.name  = 'Sensor 1';
kf1.innov.units = 'm';
kf1.innov.time  = 1:num_innovs;
kf1.innov.innov = 1e-6 * ones(num_axes, num_innovs) .* sign(rand(num_axes, num_innovs) - 0.5);
kf1.innov.norm  = ones(num_axes, num_innovs) .* sign(rand(num_axes, num_innovs) - 0.5);
kf1.innov.fploc = rand(2, num_innovs);

%% KF2
kf2        = [];
kf2.name   = 'KF2';
kf2.time   = 2:12;
kf2.att    = repmat(q2, [1 length(kf2.time)]);
kf2.att(4, 5) = kf2.att(4, 5) + 50e-6;
kf2.att    = matspace.quaternions.quat_norm(kf2.att);
kf2.pos    = kf1.pos(:, [3, 4, 5, 6, 7, 8, 9, 10, 11, 1, 2]) - 1e5;
kf2.vel    = kf1.vel(:, [3, 4, 5, 6, 7, 8, 9, 10, 11, 1, 2]) - 100;
kf2.covar  = kf1.covar + 1e-9 * rand(size(kf1.covar));
kf2.active = kf1.active;

ix              = [1:7 9:num_innovs];
kf2.innov.name  = 'Sensor 2';
kf2.innov.time  = kf1.innov.time(ix);
kf2.innov.innov = kf1.innov.innov(:, ix) + 1e-8 * rand(num_axes, numel(ix));
kf2.innov.norm  = kf1.innov.norm(:, ix) + 0.1 * rand(num_axes, numel(ix));

%% Opts
opts1           = matspace.plotting.Opts();
opts1.case_name = 'Test 1: sec-sec';
opts1.quat_comp = true;
opts1.sub_plots = true;
opts1.date_zero = date_zero;
opts1.rms_xmin  = 4;
opts1.rms_xmax  = 20;
opts1.time_unit = 'min';

opts2           = matspace.plotting.Opts(opts1).convert_dates('datetime');
opts2.case_name = 'Test 2: dates-sec';

opts3           = matspace.plotting.Opts(opts1);
opts3.case_name = 'Test 3: sec-dates';

opts4           = matspace.plotting.Opts(opts2);
opts4.case_name = 'Test 4: dates-dates';

%% Copies
kd1 = kf1;  % deepcopy?
kd1.time = matspace.plotting.convert_time_to_date(kf1.time, date_zero, 'sec');
kd1.innov.time = matspace.plotting.convert_time_to_date(kf1.innov.time, date_zero, 'sec');
kd2 = kf2;  % deepcopy?
kd2.time = matspace.plotting.convert_time_to_date(kf2.time, date_zero, 'sec');
kd2.innov.time = matspace.plotting.convert_time_to_date(kf2.innov.time, date_zero, 'sec');

%% Plots
if plots{'att'}
    f1 = matspace.plotting.gnds.plot_attitude(kf1, kf2, opts=opts1);
    f2 = matspace.plotting.gnds.plot_attitude(kd1, kd2, opts=opts2, SecondUnits={'mrad', 1e3});
    f3 = matspace.plotting.gnds.plot_attitude(kf1, kf2, opts=opts3, LegendScale='milli');
    f4 = matspace.plotting.gnds.plot_attitude(kd1, kd2, opts=opts4, LegendScale='milli', SecondUnits={'nrad', 1e9});
end

if plots{'pos'}
    f1 = matspace.plotting.gnds.plot_position(kf1, kf2, opts=opts1);
    f2 = matspace.plotting.gnds.plot_position(kd1, kd2, opts=opts2, SecondUnits={'Mm', 1e-6});
    f3 = matspace.plotting.gnds.plot_position(kf1, kf2, opts=opts3, LegendScale='mega');
    f4 = matspace.plotting.gnds.plot_position(kd1, kd2, opts=opts4, LegendScale='milli', SecondUnits={'Mm', 1e-6});
end

if plots{'fpl'}
    f1 = matspace.plotting.gnds.plot_innov_fplocs(kf1.innov, opts=opts1);
    f2 = matspace.plotting.gnds.plot_innov_fplocs(kd1.innov, opts=opts2);
    f3 = matspace.plotting.gnds.plot_innov_fplocs(kf1.innov, opts=opts3, t_bounds=t_bounds1);
    f4 = matspace.plotting.gnds.plot_innov_fplocs(kd1.innov, opts=opts4, t_bounds=t_bounds2);
end

if plots{'inn'}
    f1 = matspace.plotting.gnds.plot_innovations(kf1.innov, kf2.innov, opts=opts1);
    f2 = matspace.plotting.gnds.plot_innovations(kd1.innov, kd2.innov, opts=opts2, SecondUnits={'mm', 1e3});
    f3 = matspace.plotting.gnds.plot_innovations(kf1.innov, kf2.innov, opts=opts3, LegendScale='milli');
    f4 = matspace.plotting.gnds.plot_innovations(kd1.innov, kd2.innov, opts=opts4, LegendScale='milli', SecondUnits={'nm', 1e9});
end

if plots{'his'}
    f1 = matspace.plotting.gnds.plot_innov_hist(kf1.innov, bins, opts=opts1);
    f2 = matspace.plotting.gnds.plot_innov_hist(kd1.innov, bins, opts=opts2, normalize_spacing=true);
    f3 = matspace.plotting.gnds.plot_innov_hist(kf1.innov, bins, opts=opts3, show_cdf=true);
    f4 = matspace.plotting.gnds.plot_innov_hist(kd1.innov, bins, opts=opts4, normalize_spacing=true, show_cdf=true);
end

if plots{'cov'}
    f1 = matspace.plotting.gnds.plot_covariance(kf1, kf2, opts=opts1);
    f2 = matspace.plotting.gnds.plot_covariance(kd1, kd2, opts=opts2, SecondUnits={'mrad', 1e3});
    f3 = matspace.plotting.gnds.plot_covariance(kf1, kf2, opts=opts3, LegendScale='milli');
    f4 = matspace.plotting.gnds.plot_covariance(kd1, kd2, opts=opts4, LegendScale='milli', SecondUnits={'nrad', 1e9});
end

if plots{'los'}
    f = matspace.plotting.gnds.plot_los(kf1, kf2, opts=opts2, LegendScale='milli', SecondUnits='micro');
end
if plots{'sts'}
    f = matspace.plotting.gnds.plot_states(kd1, kd2, opts=opts1, LegendScale='mill', SecondUnits={'nrad', 1e9});
end

% Test PDF saving
% matspace.plotting.save_figs_to_pdf(f1 + f2 + f3 + f4, filename=lms.get_output_dir() / 'GND_plots.pdf')
