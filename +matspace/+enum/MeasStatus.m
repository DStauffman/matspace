classdef(Enumeration) MeasStatus < int32

% MeasStatus is a enumerator class definition for the possible Measurement Updates.
%
% Input:
%     None
%
% Output:
%     MeasStatus......... : (enum) possible values
%         null        = 0 : Not a valid setting, used to preallocate
%         accepted    = 1 : Accepted measurement update
%         rejected    = 2 : Rejected measurement update
%
% Methods:
%     is_accepted : returns a boolean for whether the measurement is accepted or not.
%     is_rejected : returns a boolean for whether the measurement is rejected or not.
%
% Prototype:
%     MeasStatus.accepted             % returns accepted as an enumerated MeasStatus type
%     double(MeasStatus.accepted)     % returns 1, which is the enumerated value of MeasStatus.accepted
%     char(MeasStatus.accepted)       % returns 'accepted' as a character string
%     class(MeasStatus.accepted)      % returns 'MeasStatus' as a character string
%     MeasStatus.accepted.is_accepted % return 1 (or true), as this is an accepted measurement
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2026.

    enumeration
        null(1)
        accepted(2)
        rejected(3)
    end

    methods
        function out = is_accepted(self)
            import matspace.enum.MeasStatus
            out = self == MeasStatus.accepted;
        end
        function out = is_rejected(self)
            import matspace.enum.MeasStatus
            out = self == MeasStatus.rejected;
        end
    end
end