function [result] = vec_angle(vec1, vec2, kwargs)

% Calculates the angle between two unit vectors.
% 
% Input:
%     vec1 : (3, N) Vector 1
%     vec2 : (3, N) Vector 2
%     kwargs:
%         UseCross : bool, optional, default is true; Use cross product in calculation
%         normalized : bool, optional, default is true; Whether vectors are normalized
% 
% Output:
%     result : (1, N) Angle between vectors.
%
% Prototype:
%     vec1 = [1; 0; 0];
%     vec2 = matspace.vectors.rot(2, 1e-5) * vec1;
%     vec3 = [0; 1; 0];
%     angle = matspace.vectors.vec_angle(vec1, vec2);
%     assert(angle == 1e-5);
% 
%     angle2 = matspace.vectors.vec_angle(vec1, vec3, UseCross=false);
%     assert(abs(angle2 - 1.570796326795) < 1e-12);
%
% Notes:
%     1.  Note that the cross product method is more computationally expensive, but is more accurate
%         for vectors with small angular differences, as the arcsin is Taylor series is order 2
%         instead of order 1 error for the arcsin.
% 
% Change Log:
%     2.  Written by David C. Stauffer in September 2020.
%     2.  Translated into Matlab by David C. Stauffer in February 2026.

% arguments
arguments (Input)
    vec1 (:, :) double
    vec2 (:, :) double
    kwargs.UseCross (1, 1) logical = true
    kwargs.Normalized (1, 1) logical = true
end
arguments (Output)
    result (1, :) double
end
use_cross = kwargs.UseCross;
normalized = kwargs.Normalized;

% Imports
import matspace.utils.unit
import matspace.utils.where

% Size checks
[r1, c1] = size(vec1);
[r2, c2] = size(vec2);
if r1 ~= r2
    error('matspace:vecAngle:BadSize', 'Size mismatch between vectors.');
end
if c1 ~= c2
    if c1 == 1
        vec1 = repmat(vec1, [1 c2]);
    elseif c2 == 1
        vec2 = repmat(vec2, [1 c1]);
    else
        error('matspace:vecAngle:BadSize', 'Size mismatch between vectors.');
    end
end

% normalize if desired, otherwise assume it already is
if ~normalized
    vec1 = unit(vec1);
    vec2 = unit(vec2);
end

% calculate the result using dot products
% Note: using sum and multiply instead of dot for 2D case
dot_prod = dot(vec1, vec2, 1);
temp = sum(dot_prod, 1);
% handle small floating point errors (but let others still crash)
if isscalar(temp)
    if temp > 1.0 && temp < 1 + 3 * eps
        temp = 1.0;
    end
else
    temp((temp > 1.0) & (temp < 1 + 3 * eps)) = 1.0;
end
dot_result = acos(temp);
if ~use_cross
    result = dot_result;
    return
end
% if desired, use cross product result, which is more accurate for small differences, but has
% an ambiguity for angles greater than pi/2 (90 deg).  Use the dot product result to resolve
% the ambiguity.
if size(vec1, 1) == 2 && size(vec2, 1) == 2
    cross_prod = vec1(1, :) .* vec2(2, :) - vec1(2, :) .* vec2(1, :);
else
    cross_prod = cross(vec1, vec2, 1);
end
temp = realsqrt(sum(cross_prod.^2, 1));
% return dot product result for sums greater than 1 (due to small numerical inconsistencies near 180 deg separation)
if isscalar(temp)
    if temp <= 1.0
        cross_result = asin(temp);
    else
        cross_result = dot_result;
    end
else
    cross_result = dot_result;
    ix = temp < 1.0;
    cross_result(ix) = asin(temp(ix));
end
result = where(dot_result > pi /2, pi - cross_result, cross_result);