% Bar Plotting Examples.

% Create data
time = datetime(2024, 12, 16, 23, 50, 00) + minutes(0:10);
data = [...
    0.50, 0.45, 0.55, nan, 0.35, 0.36, nan, 0.4, nan, 0.5, nan;
    0.50, 0.55, 0.45, nan, 0.65, 0.64, nan, 0.6, nan, 0.5, 0.4;
];
elements = ["A", "B"];

% create Opts
opts = matspace.plotting.Opts().convert_dates('datetime');

% plot the time history of the breakdown, with gaps
matspace.plotting.plot_bar_breakdown('Breakdown', time, data, Opts=opts, Elements=elements, TimeUnits='datetime');