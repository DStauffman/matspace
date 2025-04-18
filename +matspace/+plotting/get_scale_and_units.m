function [scale, units] = get_scale_and_units(type)

% GET_SCALE_AND_UNITS  gets the appropriate scale factor and units string for the given type.
%
% Input:
%     type : (str) Type of plot data, from {'unity', 'population', 'percentage', 'per 100K', 'cost'}
%
% Output:
%     scale : (scalar) Numeric scale factor [ndim]
%     units : (str) Name of units [char]
%
% Prototype:
%     [scale, units] = matspace.plotting.get_scale_and_units('unity');
%     assert(scale == 1);
%     assert(strcmp(units, ''));
%
% See Also:
%     matspace.plotting.plot_monte_carlo, matspace.plotting.plot_time_history
%
% Change Log:
%     1.  Functionalized by David C. Stauffer in September 2017.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

switch type
    case 'unity'
        scale = 1;
        units = '';
    case 'population'
        scale = 1;
        units = '#';
    case 'percentage'
        scale = 100;
        units = '%';
    case 'per 100K'
        scale = 100000;
        units = 'per 100,000';
    case 'cost'
        scale = 1e-3;
        units = '$K''s';
    otherwise
        error('matspace:badPlottingType', 'Unknown data type for plot: "%s".', type);
end