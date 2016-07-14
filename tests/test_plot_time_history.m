%% test plot_time_history

%% TODO: turn into unit test

time        = 1:10;
data        = 2*sin(time);
OPTS        = Opts();
time2       = -1:2:12;
data2       = 1.5*sin(time2+1);
description = 'Some Sine Waves';
type        = 'unity'; %{'unity', 'population', 'percentage', 'per 100K', 'per 100,000', 'cost'}
truth_time  = 3:3:15;
truth_data  = 2.2*sin(truth_time);

%% Plots
% nominal
plot_time_history(time, data);

% with OPTS
plot_time_history(time, data, OPTS);

% with description
plot_time_history(time, data, [], 'Description', description);

% with second data set
plot_time_history(time, data, [], 'Time2', time2, 'Data2', data2);

% with type
plot_time_history(time, data, [], 'Type', 'unity');
plot_time_history(time, data, [], 'Type', 'population');
plot_time_history(time, data, [], 'Type', 'percentage');
plot_time_history(time, data, [], 'Type', 'per 100K');
plot_time_history(time, data, [], 'Type', 'cost');

% with truth
plot_time_history(time, data, [], 'TruthTime', truth_time, 'TruthData', truth_data);
plot_time_history(time, data, [], 'TruthTime', truth_time, 'TruthData', truth_data, 'Description', 'HIV Prevalence');

% with everything
plot_time_history(time, data, OPTS, 'Type', 'percentage', 'Time2', time2, 'Data2', data2, ...
    'TruthTime', truth_time, 'TruthData', truth_data, 'Description', 'HIV Prevalence');