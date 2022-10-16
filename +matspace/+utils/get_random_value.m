function [value] = get_random_value(distribution, num, coeffs, minmax)

% GET_RANDOM_VALUE  gets a random value using the given distribution and coefficients.
%
% Input:
%     distribution : (char) the distribution to use, from {'None', 'Uniform', 'Normal', 'Beta', 'Gamma', 'Triangular'}
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
%     values = matspace.utils.get_random_value('Uniform', num, [0, 10]);
%     histogram(values, edges);
%
%     values = matspace.utils.get_random_value('Normal', num, [5, 3]);
%     histogram(values, edges);
%
%     values = 10 * matspace.utils.get_random_value('Beta', num, [2, 3]);
%     histogram(values, edges);
%
%     values = matspace.utils.get_random_value('Gamma', num, [1, 2]);
%     histogram(values, edges);
%
%     values = matspace.utils.get_random_value('Triangular', num, [0, 4, 10]);
%     histogram(values, edges);
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2018.
%     2.  Updated by David C. Stauffer in October 2022 to not require any special toolboxes.

arguments
    distribution (1,:) char
    num {mustBeNumeric, mustBeReal} = 1
    coeffs (1, :) {mustBeNumeric, mustBeReal, mustBeLessThanXElems(coeffs, 4), mustHaveXCoeffs(distribution, coeffs)} = []
    minmax (1, :) {mustBeNumeric, mustBeReal, mustBeLessThanXElems(minmax, 2)} = []
end

% Imports
import matspace.coder.betarnd_mex

use_toolbox = true;  %#ok<*UNRCH>  % Requires Statistics and Machine Learning Toolbox

% split to the appropriate distribution
switch lower(distribution)
    case 'none'
        assert(isempty(minmax), 'minmax should be empty with distribution %s', distribution);
        if isempty(coeffs)
            value = ones(num);
        else
            value = repmat(coeffs(1), num);
        end
    case 'uniform'
        % Note: coeffs or min/max mean the same thing for a uniform distribution (TODO: is this true?)
        if use_toolbox
            if isempty(coeffs)
                coeffs = [0, 1];
            end
            pd = makedist('Uniform', coeffs(1), coeffs(2));
            if ~isempty(minmax)
                pd = truncate(pd, minmax(1), minmax(2));
            end
            value = pd.random(num);
        else
            if isempty(coeffs)
                value = rand(num);
            else
                value = rand(num) * (coeffs(2)-coeffs(1)) + coeffs(1);
            end
        end
    case 'normal'
        if use_toolbox
            if isempty(coeffs)
                coeffs = [0, 1];
            end
            pd = makedist('Normal', coeffs(1), coeffs(2));
            if ~isempty(minmax)
                pd = truncate(pd, minmax(1), minmax(2));
            end
            value = pd.random(num);
        else
            if isempty(coeffs)
                value = randn(num);
            else
                value = coeffs(1) + randn(num) * coeffs(2);
            end
        end
    case 'beta'
        if use_toolbox
            if isempty(coeffs)
                coeffs = [1, 1];
            end
            pd = makedist('Beta', coeffs(1), coeffs(2));
            if ~isempty(minmax)
                pd = truncate(pd, minmax(1), minmax(2));
            end
            value = pd.random(num);
        else
            value = betarnd_mex(num(1), num(2), alpha, beta) * (this_max-this_min) + this_min;
        end
    case 'gamma'
        if use_toolbox
            if isempty(coeffs)
                coeffs = [1, 1];
            end
            pd = makedist('Gamma', coeffs(1), coeffs(2));
            if ~isempty(minmax)
                pd = truncate(pd, minmax(1), minmax(2));
            end
            value = pd.random(num);
        else
            % TODO: write this
        end
    case 'triangular'
        if use_toolbox
            if isempty(coeffs)
                coeffs = [0, 0.5, 1];
            end
            pd = makedist('Triangular', coeffs(1), coeffs(2), coeffs(3));
            if ~isempty(minmax)
                pd = truncate(pd, minmax(1), minmax(2));
            end
            value = pd.random(num);
        else
            % TODO: write this
        end
    otherwise
        error('matspace:UnexpectedRandomDistribution', 'Unexpected value for distribution: "%s"', distribution');
end
end


function mustBeLessThanXElems(a, b)
    if length(a) > b
        eidType = 'matspace:mustBeLessThanXElems:tooManyElements';
        msgType = 'Input must be a less than %i elements, upper triangular matrix.';
        throwAsCaller(MException(eidType, msgType, b));
    end
end

function mustHaveXCoeffs(dist, coeffs)
    switch lower(dist)
        case 'none'
            num_coeffs = 1;
        case 'uniform'
            num_coeffs = 2;
        case 'normal'
            num_coeffs = 2;
        case 'beta'
            num_coeffs = 2;
        case 'gamma'
            num_coeffs = 2;
        case 'triangular'
            num_coeffs = 3;
        otherwise
            eidType = 'matspace:mustHaveXCoeffs:badDist';
            msgType = 'Unexpected Distribution of %s.';
            throwAsCaller(MException(eidType, msgType, dist));
    end
    if ~isempty(coeffs) && length(coeffs) ~= num_coeffs
        eidType = 'matspace:mustHaveXCoeffs:wrongNumCoeffs';
        msgType = 'Distribution %s must have %i coefficients.';
        throwAsCaller(MException(eidType, msgType, dist, num_coeffs));
    end
end