function out = between(value, lower, upper, is_closed)

% BETWEEN  Evaluates whether a value is between the bounds.
%
% Summary:
%     Returns logical array, true for values between upper and lower bounds.
%     This can be used as a convenience function for increased readability
%     or savings in memory when the value to be compared is only needed
%     temporarily.
%
% Input:
%     value     : matrix to be tested
%     lower     : lower bound, scalar or matrix
%     upper     : upper bound, scalar or matrix
%     is_closed : (1x2) Closed (1) or Open (0) bounds
%                     [0 0] or 0 -> (lb,ub)
%                     [1 1] or 1 -> [lb,ub]
%                     [0,1]      -> (lb,ub]
%                     [1,0]      -> [lb,ub]
%
% Output:
%     out : logical matrix, true for values between lower and upper bounds [bool]
%
% Prototype:
%     value = 5;
%     lower = 0;
%     upper = 10;
%     out   = matspace.utils.between(value, lower, upper);
%
% Change Log:
%     1.  Written by Matt Beck in Jan 2013.
%     2.  Updated by Keith Rogers in July 2014 for inclusion in SSC Toolbox.
%     3.  Incorporated by David C. Stauffer into matspace in Nov 2016.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

%% check for optional inputs
switch nargin
    case 3
        is_closed = false(1,2);
    case 4
        if isscalar(is_closed)
            is_closed = [is_closed,is_closed];
        end
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

%% argument checks
if numel(is_closed) ~= 2
    error('matspace:between:BadBoundarySpecification',...
        'Badly formatted specification of open/closed boundary conditions.');
end

%% calculations
if ~is_closed(1) && ~is_closed(2)
    % strictly greater and less than
    out = (value >  lower & value <  upper);
elseif ~is_closed(1) &&  is_closed(2)
    % greater than and less than or equal to
    out = (value >  lower & value <= upper);
elseif is_closed(1) && ~is_closed(2)
    % greater than or equal to and less than
    out = (value >= lower & value <  upper);
elseif is_closed(1) &&  is_closed(2)
    % greater than or equal to and less than or equal to
    out = (value >= lower & value <= upper);
end