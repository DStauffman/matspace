function [c, ia, ib] = intersect2(A, B, precision, flag, setOrder) %#codegen

% INTERSECT2  is the same as the built-in intersect, but with a specified precision.
%
% Summary:
%     This function quantizes the A & B matrices to the specified precision, and then does a normal
%     intersect command.  Specifying precision = 0 will give the same result as a normal intersect command.
%
% Input:
%     A         : (1xA) input vector 1 [num]
%     B         : (1xB) input vector 2 [num]
%     precision : (scalar) numerical precision tolerance [num]
%     flag      : (row) optional flag for operating on rows of matrices [char]
%     setOrder  : (row) optional string for setting the order of outputs [char] - see note 1
%
% Output:
%                       where N = number of unique elements in both A & B
%     c         : (1xN) values in both A & B as quantized by the precision input [num]
%     ia        : (1xN) index for A to build c [num]
%     ib        : (1xN) index for B to build c [num]
%
% Prototype:
%     A           = [1 2 3 3 5 6];
%     B           = [3.0000000001 4.9999999999];
%     precision   = 1e-6;
%     [c, ia, ib] = matspace.stats.intersect2(A, B, precision);
%     % case 2: this case causes problems with the original implementation
%     A           = [1.000001 1.99999975];
%     B           = [1.0000015 2.00000025];
%     precision   = 1e-6;
%     [c, ia, ib] = matspace.stats.intersect2(A, B, precision);
%
% See Also:
%     intersect
%
% Notes:
%     1.  Intersect was updated in MATLAB 2012A and includes additional inputs that were not part
%         of earlier releases.  This function will support either version
%
% Change Log:
%     1.  Written by David C. Stauffer in Feb 2010.
%     2.  Updated by David C. Stauffer in Mar 2010 for PGPR 1045.
%     3.  Updated by David C. Stauffer in Jul 2012 to make more robust to quantization problems.
%     4.  Updated by David C. Stauffer in June 2020 to finally work on all boundary cases.

% define the appropriate function based on the input arguments
is_stable = false;
switch nargin
    case 2
        precision = 0;
        func = @(a, b) intersect(a, b);
    case 3
        func = @(a, b) intersect(a, b);
    case 4
        func = @(a, b) intersect(a, b, flag);
        if strcmpi(flag, 'stable')
            is_stable = true;
        end
    case 5
        % this version will have a warning on old versions of MATLAB prior to 2012A
        func = @(a, b) intersect(a, b, flag, setOrder);
        if strcmpi(flag, 'stable') || strcmpi(setOrder, 'stable')
            is_stable = true;
        end
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% allow a zero precision to be passed in and behave like the normal intersect command
if precision == 0
    % do a normal intersect
    [c, ia, ib] = func(A, B);
    return
end

% determine if all the inputs and integers
all_int = isinteger(A) && isinteger(B) && isinteger(precision);
% find larger max of A or B, must call max three times to support up to 3D matrices A and B
maxAorB = max(max(max(abs(A))), max(max(max(abs(B)))));
% check if largest component of A and B is too close to the precision floor
if ~all_int && ((maxAorB/precision) > (0.01/eps))
    warning('matspace:intersectPrecision','This function may have problems if precision gets too small');
end

% due to the splitting of the quanta, two very close numbers could still fail the intersect.
% fix this by repeating the comparsion when shifted by half a quanta.
half_precision = double(precision) / 2;
if all_int
    lo_tol = cast(floor(half_precision), class(precision));
    hi_tol = cast(ceil(half_precision), class(precision));
else
    lo_tol = half_precision;
    hi_tol = half_precision;
end

% create a quantized version of A & B, plus each one shifted by half a quanta in either direction
A1 = floor(A / precision);
B1 = floor(B / precision);
A2 = floor((A - lo_tol) / precision);
B2 = floor((B - lo_tol) / precision);
A3 = floor((A + hi_tol) / precision);
B3 = floor((B + hi_tol) / precision);

% do a normal intersect on the quantized data
[~, ia1, ib1] = func(A1, B1);
[~, ia2, ib2] = func(A1, B2);
[~, ia3, ib3] = func(A1, B3);
[~, ia4, ib4] = func(A2, B1);
[~, ia5, ib5] = func(A3, B1);

% combine the results
ia = union(union(union(union(ia1, ia2), ia3), ia4), ia5);
ib = union(union(union(union(ib1, ib2), ib3), ib4), ib5);

% calculate output
if nargin >= 4 && strcmpi(flag,'rows')
    c = A(ia,:);
    return
end

% since you don't know which of the five intersects will find each index, then you need to make them
% 'sorted' or 'stable' after the fact.  They will come sorted by index, which gives stable order
% in the output c
c = A(ia);
if ~is_stable && ~issorted(c)
    [c, ix1] = sort(c);
    ia = ia(ix1);
    [~, ix2] = sort(B(ib));
    ib = ib(ix2);
end