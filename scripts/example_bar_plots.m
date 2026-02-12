% Bar Plotting Examples.

% settings
use_datetime = false;  %#ok<*UNRCH>
date_zero = datetime(2024, 12, 16, 23, 50, 00);

% Create data
if use_datetime
    time = date_zero + minutes(0:10);
else
    time = 60 * (0:10);
end
data = [...
    0.50, 0.45, 0.55, nan, 0.35, 0.36, nan, 0.4, nan, 0.5, nan;
    0.50, 0.55, 0.45, nan, 0.65, 0.64, nan, 0.6, nan, 0.5, 0.4;
];
elements = ["A", "B"];

% create Opts
opts = matspace.plotting.Opts();
if use_datetime
    opts.convert_dates('datetime');
else
    opts.time_unit = 'sec';  % TODO: handle this in the function?
    opts.date_zero = date_zero;
end

% plot the time history of the breakdown, with gaps
matspace.plotting.plot_bar_breakdown('Breakdown', time, data, Opts=opts, Elements=elements);