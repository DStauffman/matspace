function [new_units, unit_conv, leg_units, leg_conv] = get_units(units, second_units, legend_scale)

% Get all the unit conversions.

arguments (Output)
    new_units (1, :) char
    unit_conv (1, 1) double
    leg_units (1, :) char
    leg_conv (1, 1) double
end

import matspace.plotting.get_unit_conversion

[new_units, unit_conv] = get_unit_conversion(second_units, units);
if ~isempty(legend_scale)
    [leg_units, leg_conv] = get_unit_conversion(legend_scale, units);
else
    leg_units = new_units;
    leg_conv = unit_conv;
end