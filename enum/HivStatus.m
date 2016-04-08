classdef(Enumeration) HivStatus < int32

% HivStatus is a enumerator class definition for the possible HIV statuses.
%
% Input:
%     None
%
% Output:
%     HivStatus ......... : (enum) possible values
%         uninfected = -1 : not infected
%         null       =  0 : not set, used for preallocation
%         acute      =  1 : acute
%         chronic    =  2 : chronic
%
% Prototype:
%     HivStatus.acute         % returns acute as an enumeratod HivStatus type
%     double(HivStatus.acute) % returns 1, which is the enumerated value of HivStatus.acute
%     char(HivStatus.acute)   % returns 'acute' as a character string
%     class(HivStatus.acute)  % returns 'HivStatus' as a character string
%
%     hiv_status = [HivStatus.uninfected, HivStatus.null, HivStatus.acute, HivStatus.chronic];
%     assert(all(hiv_status.is_infected == [false, false, true, true]));
%     assert(all(hiv_status.is_not_infected == [true, false, false, false]));
%
% Methods:
%     is_infected     : returns a boolean for whether the person is infected or not.
%     is_not_infected : returns a boolean for whether the person is not infected or not.
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2013.
%     2.  Methods added by David C. Stauffer in April 2016.
%     3.  Added to DStauffman MATLAB library in April 2016.

    enumeration
        uninfected(-1)
        null(0)
        acute(1)
        chronic(2)
    end

    methods
        function out = is_infected(obj)
            %out = obj == HivStatus.acute | obj == HivStatus.chronic; % more explicit option
            out = obj > 0; % slightly faster option
        end
        function out = is_not_infected(obj)
            out = obj == HivStatus.uninfected;
        end
    end
end