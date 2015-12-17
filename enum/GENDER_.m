classdef(Enumeration) GENDER_ < int32

% GENDER_ is a enumerator class definition for the possible genders.
%
% Input:
%     None
%
% Output:
%     GENDER_ ...... : (enum) possible values
%         null   = 0 : not a valid setting, used to preallocate
%         female = 1 : female
%         male   = 2 : male
%
% Prototype:
%     GENDER_.female         % returns female as an enumeratod GENDER_ type
%     double(GENDER_.female) % returns 1, which is the enumerated value of GENDER_.female
%     char(GENDER_.female)   % returns 'female' as a character string
%     class(GENDER_.female)  % returns 'GENDER_' as a character string
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