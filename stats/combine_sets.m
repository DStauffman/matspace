function [n,u,s] = combine_sets(n1,u1,s1,n2,u2,s2)

% COMBINE_SETS  combines the mean and standard deviations for two non-overlapping sets of data.
%
% Summary:
%     This function combines two non-overlapping data sets, given a number of samples, mean
%     and standard deviation for the two data sets.  It first calculates the total number of samples
%     then calculates the total mean using a weighted average, and then calculates the combined
%     standard deviation using an equation found on wikipedia.  It also checks for special cases
%     where either data set is empty or if only one total point is in the combined set.
%
% Input:
%     n1 : (scalar) number of points in data set 1
%     u1 : (scalar) mean of data set 1
%     s1 : (scalar) standard deviation of data set 1
%     n2 : (scalar) number of points in data set 2
%     u2 : (scalar) mean of data set 2
%     s2 : (scalar) standard deviation of data set 2
%
% Output:
%     n  : (scalar) number of points in the combined data set
%     u  : (scalar) mean of the combined data set
%     s  : (scalar) standard deviation of the combined data set
%
% Prototype:
%     n1 = 5;
%     u1 = 1;
%     s1 = 0.5;
%     n2 = 10;
%     u2 = 2;
%     s2 = 0.25;
%     [n,u,s] = combine_sets(n1,u1,s1,n2,u2,s2);
%
% See Also:
%     mean, std
%
% Reference:
%     http://en.wikipedia.org/wiki/Standard_deviation#Sample-based_statistics, on 8/7/12
%
% Change Log:
%     1.  Written by David C. Stauffer in July 2012.

% combine total number of samples
n = n1 + n2;

% check for zero case
if n == 0
    u = 0;
    s = 0;
    return
end

% calculate the combined mean
u = 1/n * (n1*u1 + n2*u2);

% calculate the combined standard deviation
if n ~= 1
    s = realsqrt(1/(n-1) * ( (n1-1)*s1^2 + n1*u1^2 + (n2-1)*s2^2 + n2*u2^2 - n*u^2));
else
    % special case where one of the data sets is empty
    if n1 == 1
        s = s1;
    elseif n2 == 1
        s = s2;
    else
        error('stats:badSetSize', 'Total samples are 1, but neither data set has only one item.');
    end
end