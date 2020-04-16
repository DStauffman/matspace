function [out] = fix_rollover(data, roll, log_level, dim)

% FIX_ROLLOVER  unrolls data rollovers for unsigned integers.
%
% Summary:
%     This function finds the points at which rollovers occur, where a rollover is considered a
%     difference of more than half the rollover value, and then classifies the rollover as a top
%     to bottom or bottom to top rollover.  It then rolls the data as a step function in partitions
%     formed by the rollover points, so there will always be one more partition than rollover points.
%
% Input:
%     data .... : (1xN) or (Nx1) input vector of unsigned integers with rollovers present [int]
%                 (MxN) on (NxM) if dim is present and specified
%     roll .... : (scalar) value at which rollover occurs [num]
%     log_level : (scalar) optional argument for the level of logging to output to the command window, from (1:10) [num]
%                              < 5  no information is displayed
%                              >=5  number of top to bottom, or bottom to top rollovers is displayed
%     dim ..... : (scalar) optional dimension to operate on a matrix input, from {1, 2} [num]
%
% Output:
%     out ..... : (1xN) on (Nx1) output vector after rollovers have been corrected [num]
%
% Prototype:
%     x   = [1 2 3 4 5 6 0 1 3 6 0 6 5 2];
%     exp = [1 2 3 4 5 6 7 8 10 13 14 13 12 9];
%     y   = matspace.utils.fix_rollover(x, 7, 10);
%     assert(all(y == exp));
%
% Notes:
%     1.  A difference between two successive points is determined to be a rollover (rather than a
%         gap) if the difference is greater than half the rollover value.
%
% Change Log:
%     1.  Written by Matt Beck and David C. Stauffer in June 2009.
%     2.  Updated by David C. Stauffer in November 2009 to pass PGPR 1027.
%     3.  Added to matspace tools by David C. Stauffer in March 2020.
%     4.  Updated by David C. Stauffer in April 2020 to support matrices and a dimension argument,
%         and put into a package.

% Imports
import matspace.utils.fix_rollover % Note: this calls itself recursively

% optional inputs
switch nargin
    case 2
        log_level = 10;
    case 3
        % nop
    case 4
        % call recursively with vector input
        out = zeros(size(data));
        switch dim
            case 1
                for i = 1:size(data, 2)
                    out(:, i) = fix_rollover(data(:, i), roll, log_level);
                end
            case 2
                for i = 1:size(data, 1)
                    out(i, :) = fix_rollover(data(i, :), roll, log_level);
                end
            otherwise
                error('matspace:rollBadDim', 'Unexpected dimension: "%i"', dim);
        end
        return
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end
% default log level
if isempty(log_level)
    log_level = 10;
end

% check that input is a vector and initialize compensation variables with the same dimensions
if isvector(data)
    % t2b means top to bottom rollovers, while b2t means bottom to top rollovers
    num_el           = length(data);
    compensation_t2b = zeros(size(data));
    compensation_b2t = zeros(size(data));
else
    if isempty(data)
        out = data;
        return
    else
        error('matspace:rollVector', 'Input argument ''in'' must be a vector.')
    end
end

% find indices for top to bottom rollovers, these indices act as partition boundaries
roll_ix = find(diff(data) > (roll/2));
if ~isempty(roll_ix)
    % add final field to roll_ix so that final partition can be addressed
    roll_ix(end+1) = num_el;
    % loop only on original length of roll_ix, which is now length - 1
    for i = 1:(length(roll_ix)-1)
        % creates a step function to be added to the input array where each
        % step down occurs after a top to bottom roll over.
        compensation_t2b((roll_ix(i) + 1):roll_ix(i+1)) = -roll * i;
    end
    % display a warning based on the log level
    if log_level >= 5
        warning('matspace:rollover', ['corrected ', num2str(length(roll_ix)-1),' bottom to top rollover(s)']);
    end
end

% find indices for top to bottom rollover, these indices act as partition boundaries
roll_ix = find(diff(data) < -(roll/2));
if ~isempty(roll_ix)
    % add final field to roll_ix so that final partition can be addressed
    roll_ix(end+1) = num_el;
    % loop only on original length of roll_ix, which is now length - 1
    for i = 1:(length(roll_ix)-1)
        % creates a step function to be added to the input array where each
        % step up occurs after a bottom to top roll over.
        compensation_b2t((roll_ix(i) + 1):roll_ix(i+1)) = roll * i;
    end
    % display a warning based on the log level
    if log_level >= 5
        warning('matspace:rollover', ['corrected ', num2str(length(roll_ix)-1),' top to bottom rollover(s)']);
    end
end

% create output
out = data + compensation_b2t + compensation_t2b;

% double check for remaining rollovers
if any(diff(out)> (roll/2)) || any(diff(out) < -(roll/2))
    if log_level >= 5
        warning('matspace:doubleRoll','A rollover was fixed recursively');
    end
    out = fix_rollover(out,roll,log_level);
end