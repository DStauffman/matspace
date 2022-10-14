function [value] = get_random_value(distribution, num, varargin)

% GET_RANDOM_VALUE  gets a random value using the given distribution and coefficients.
%
% Input:
%     distribution : (char) the distribution to use, from {'Uniform', 'Normal', 'Beta', 'Gamma', 'Triangular'}
%
% Output:
%     value : (num) a random value sampled from the given distribution
%
% Examples:
%     num = [10000, 1];
%     edges = [0:10];
%     values = matspace.utils.get_random_value('None', num, 5);
%     histogram(values, edges);
%
%     values = matspace.utils.get_random_value('Uniform', num, 0, 10);
%     histogram(values, edges);
%
%     values = matspace.utils.get_random_value('Normal', num, 5, 3);
%     histogram(values, edges);
%
%     values = matspace.utils.get_random_value('Beta', num, 0, 10, 1, 2);
%     histogram(values, edges);
%
%     values = matspace.utils.get_random_value('Gamma', num, 1, 2);
%     histogram(values, edges);
%
%     values = matspace.utils.get_random_value('Triangular', num, 0, 4, 10);
%     histogram(values, edges);
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2018.
%     2.  Updated by David C. Stauffer in October 2022 to not require any special toolboxes.

% Imports
import matspace.coder.betarnd_mex

switch nargin
    case 0
        error('Unexpected number of inputs');
    case 1
        num = [1 1];
        nargs = 0;
    case 2
        nargs = 0;
    otherwise
        nargs = length(varargin);
end

use_toolbox = false;  %#ok<*UNRCH>  % Requires Statistics and Machine Learning Toolbox

% split to the appropriate distribution
switch lower(distribution)
    case 'none'
        switch nargs
            case 0
                value = ones(num);
            case 1
                value = repmat(varargin{1}, num);
            otherwise
                error('Unexpected number of inputs for distribution of %s', distribution);
        end
    case 'uniform'
        switch nargs
            case 0
                value = rand(num);
            case 2
                this_min  = varargin{1};
                this_max  = varargin{2};
                if use_toolbox
                    value = random('Uniform', this_min, this_max, varargin{3:end});
                else
                    value = rand(num) * (this_max-this_min) + this_min;
                end
            otherwise
                error('Unexpected number of inputs for distribution of %s', distribution);
        end
    case 'normal'
        this_mean = varargin{1};
        this_std  = varargin{2};
        if use_toolbox
            value = random('Normal', this_mean, this_std, varargin{3:end});
        else
            value = randn(num) * this_std + this_mean;
        end
    case 'beta'
        if length(num) == 1
            num = [num num];
        end
        this_min  = varargin{1};
        this_max  = varargin{2};
        alpha     = varargin{3};
        beta      = varargin{4};
        if use_toolbox
            value = random('Beta', alpha, beta, varargin{5:end}) * (this_max-this_min) + this_min;
        else
            value = betarnd_mex(num(1), num(2), alpha, beta) * (this_max-this_min) + this_min;
        end
    case 'gamma'
        alpha     = varargin{1};
        beta      = varargin{2};
        if use_toolbox
            value = random('Gamma', alpha, beta, varargin{3:end});
        else
            % TODO: write this
        end
    case 'triangular'
        this_min  = varargin{1};
        this_peak = varargin{2};
        this_max  = varargin{3};
        if use_toolbox
            pd    = makedist('Triangular', 'a', this_min, 'b', this_peak, 'c', this_max);  % Requires Statistics and Machine Learning Toolbox
            value = pd.random(num);
        else
            % TODO: write this
        end
    otherwise
        error('hesat:UnexpectedRandomDistribution', 'Unexpected value for distribution: "%s"', distribution');
end