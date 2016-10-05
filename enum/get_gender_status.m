function [is_female, is_male] = get_gender_status(gender)

% GET_GENDER_STATUS  determines whether someone is female or male based on their Gender enum.
%
% Input:
%     gender : (Nx1) array of Gender [Gender enum]
%
% Output:
%     is_female : (Nx1) logical array of whether this person is female [bool]
%     is_male   : (Nx1) logical array of whether this person is male [bool]
%
% Prototype:
%     gender = [Gender.null; Gender.female; Gender.male; Gender.uncirc_male; Gender.circ_male];
%     [is_female, is_male] = get_gender_status(gender);
%     assert(all(is_female == [0; 1; 0; 0; 0]));
%     assert(all(is_male   == [0; 0; 1; 1; 1]));
%
% See Also:
%     Gender
%
% Notes:
%     1.  This function is kept separately from the methods in the `Gender` class for optimization
%         and compilation reasons.
%     2.  `null` genders are not considered male or female.
%
% Change Log:
%     1.  Written by David C. Stauffer in September 2016.

% determine if female
is_female = gender == Gender.female;

% determine if male
is_male = gender == Gender.male | gender == Gender.uncirc_male | gender == Gender.circ_male;