function [xlims] = label_x(this_axes, disp_xmin, disp_xmax, time_is_date, time_units, start_date)

% Build the list of x-labels.

arguments
    this_axes
    disp_xmin
    disp_xmax
    time_is_date (1, 1) logical
    time_units {mustBeTextScalar}
    start_date {mustBeTextScalar}
end

import matspace.plotting.disp_xlimits

if time_is_date
    xlabel(this_axes, 'Date');
    assert(time_units == "datetime", 'Expected time units of "datetime", not "%s".', time_units);
else
    xlabel(this_axes, ['Time [',time_units,']',start_date]);
    assert(time_units ~= "datetime", 'Expected time units of "seconds" or such, not "%s".', time_units);
end
axis auto;
disp_xlimits(this_axes, xmin=disp_xmin, xmax=disp_xmax);
xlims = xlim(this_axes);