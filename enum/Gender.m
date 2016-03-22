classdef(Enumeration) Gender < int32

% Gender is a enumerator class definition for the possible genders.
%
% Input:
%     None
%
% Output:
%     Gender ....... : (enum) possible values
%         null   = 0 : not a valid setting, used to preallocate
%         female = 1 : female
%         male   = 2 : male
%
% Prototype:
%     Gender.female         % returns female as an enumeratod Gender type
%     double(Gender.female) % returns 1, which is the enumerated value of Gender.female
%     char(Gender.female)   % returns 'female' as a character string
%     class(Gender.female)  % returns 'Gender' as a character string
%
% Change Log:
%     1.  Written by David Stauffer in June 2013.
%     2.  Added to DStauffman MATLAB library in December 2015.

    enumeration
        null(0)
        female(1)
        male(2)
    end
end