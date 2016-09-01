function [bmi] = calculate_bmi(height, weight, gender, conv)

% CALCULATE_BMI  calculates a person's body mass index based on their given height, weight and gender.
%
% Input:
%     height : (scalar) height [inches]
%     weight : (scalar) weight [pounds]
%     gender : (scalar) gender, from {'F', 'M'} [char]
%     conv   : (scalar) unit conversion [num]
%
% Output:
%     bmi    : (scalar) body mass index [kg/m^2]
%
% Prototype:
%     height = 69;
%     weight = 168;
%     gender = 'M';
%     conv   = 703.0704; % converts from lb/in^2 to kg/m^2
%     bmi    = calculate_bmi(height, weight, gender, conv);
%     assert(abs(bmi - 24.809) < 1e-3);
%
% Change Log:
%     1.  Started by David C. Stauffer in May 2016.

% TODO: incorporate gender.  Also, does age matter?
bmi = weight / height^2 * conv;