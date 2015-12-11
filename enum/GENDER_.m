classdef(Enumeration) GENDER_ < int32
    
% GENDER_ is a enumerator class definition for the possible genders.
%
% Input:
%     None
%
% Output:
%     GENDER_        : (enum) possible values
%         null   = 0 : not a valid setting, used to preallocate
%         male   = 1 : uncircumcised male
%         female = 2 : female
%
% Prototype:
%     GENDER_.female         % returns female as an enumeratod GENDER_ type
%     double(GENDER_.female) % returns 2, which is the enumerated value of GENDER_.female
%     char(GENDER_.female)   % returns 'female' as a character string
%
% Change Log:
%     1.  Written by David Stauffer in June 2013.

    enumeration
        null(0)
        male(1)
        female(2)
    end
end