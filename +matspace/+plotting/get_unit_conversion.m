function [new_units, unit_mult] = get_unit_conversion(conversion, units)

% GET_UNIT_CONVERSION  Acts as a wrapper to unit conversions for legends in plots and for scaling second axes.
%
% Input:
%     conversion : (row) string specifying unit standard metric prefix or some special cases, from:
%         {'yotta', 'zetta', 'exa', 'peta', 'tera', 'giga', 'mega',
%          'kilo', 'hecto', 'deca', 'unity', 'deci', 'centi', 'milli',
%          'micro', 'nano', 'pico', 'femto', 'atto', 'zepto', 'yocto',
%          'arcminute', 'arcsecond', 'milliarcsecond', 'microarcsecond',
%          'percentage', 'arcsecond^2'}
%     units : (row) label to apply the prefix to (sometimes replaced when dealing with radians and english units) [char]
%
% Output:
%     new_units : (row) Units with the correctly prepended abbreviation (or substitution) [char]
%     unit_mult : (scalar) Multiplication factor [num]
%
% Notes:
%     1.  Special cases include dimensionless/radians to arcseconds or parts per million, or
%         appropriately scaling radians squared.
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2021 when he had to deal with arcseconds and other
%         special cases.
%     2.  Translated from Python into Matlab by David C. Stauffer in January 2022.
%
% Prototype:
%     conversion = 'micro';
%     units = 'rad';
%     [new_units, unit_mult] = matspace.plotting.get_unit_conversion(conversion, units);
%     assert(unit_mult == 1000000.0);
%     assert(strcmp(new_units, '\murad'));

import matspace.plotting.get_factors

if isempty(conversion)
    new_units = '';
    unit_mult = 1;
    return
end
if isnumeric(conversion)
    new_units = '';
    unit_mult = conversion;
    return
end
if ~ischar(conversion)
    new_units = conversion{1};
    unit_mult = conversion{2};
    return
end
if strcmp(conversion, 'percentage')
    new_units = '%';
    unit_mult = 100;
    return
end
[unit_mult, label] = get_factors(conversion, true);
if any(strcmp(units, {'', 'rad', 'rad^2'})) && contains('arc', conversion)  % check direction of contains statement
    new_units = label;
elseif strcmp(units, 'rad^2')
    new_units = ['(', label, 'rad)^2'];
    unit_mult = unit_mult ^ 2;
elseif isempty(units) || strcmp(units, 'unitless')
    % special empty cases
    if strcmp(conversion, 'milli')
        new_units = 'ppk';
    elseif strcmp(conversion, 'micro')
        new_units = 'ppm';
    elseif strcmp(conversion, 'nano')
        new_units = 'ppb';
    elseif strcmp(conversion, 'pico')
        new_units = 'ppt';
    elseif label
        error('The unit conversion given doesn''t work for empty units.')
    else
        new_units = [label, units];
    end
else
    new_units = [label, units];
end