function [c, ia, ib] = intersect2(A, B, precision, flag, setOrder) %#codegen

% INTERSECT2  is the same as the built-in intersect, but with a specified precision.
%
% SUMMARY:
%     This function quantizes the A & B matrices to the specified precision, and then does a normal
%     intersect command.  Specifying precision = 0 will give the same result as a normal intersect command.
%
% INPUT:
%     A         : (1xA) input vector 1 [num]
%     B         : (1xB) input vector 2 [num]
%     precision : (scalar) numerical precision tolerance [num]
%     flag      : (row) optional flag for operating on rows of matrices [char]
%     setOrder  : (row) optional string for setting the order of outputs [char] - see note 1
%
% OUTPUT:
%                       where N = number of unique elements in both A & B
%     c         : (1xN) values in both A & B as quantized by the precision input [num]
%     ia        : (1xN) index for A to build c [num]
%     ib        : (1xN) index for B to build c [num]
%
% PROTOTYPE:
%     A         = [1 2 3 3 5 6];
%     B         = [3.0000000001 4.9999999999];
%     precision = 1e-6;
%     [c,ia,ib] = intersect2(A,B,precision)
%     % case 2: this case causes problems with the original implementation
%     A         = [1.000001 1.99999975];
%     B         = [1.0000015 2.00000025];
%     precision = 1e-6;
%     [c,ia,ib] = intersect2(A,B,precision)
%
% SEE ALSO:
%     intersect
%
% REFERENCE:
%     (NONE)
%
% NOTES:
%     1.  Intersect was updated in MATLAB 2012A and includes additional inputs that were not part
%         of earlier releases.  This function will support either version
%
% CHANGE LOG:
%     1.  Written by David Stauffer in Feb 2010.
%     2.  Updated by David Stauffer in Mar 2010 for PGPR 1045.
%     3.  Updated by David Stauffer in Jul 2012 to make more robust to quantization problems.
%
% EXPORT CONTROL WARNING:
%     (NONE)
%
% CLASSIFICATION:
%     (NONE)

% determine the number of optional arguments that were passed in
switch nargin
    case 2
        precision = 0;
        opt_flags = 0;
    case 3
        opt_flags = 0;
    case 4
        opt_flags = 1;
    case 5
        opt_flags = 2;
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% allow a zero precision to be passed in and behave like the normal intersect command
if precision == 0
    % do a normal intersect
    switch opt_flags
        case 0
            [c, ia, ib] = intersect(A, B);
        case 1
            [c, ia, ib] = intersect(A, B, flag);
        case 2
            % this line and others like it will have a warning on old versions of MATLAB prior to 2012A
            [c, ia, ib] = intersect(A, B, flag, setOrder);
    end
    return
end

% find larger max of A or B, must call max three times to support up to 3D matrices A and B
maxAorB = max(max(max(abs(A))), max(max(max(abs(B)))));
% check if largest component of A and B is too close to the precision floor
if (maxAorB/precision) > (0.01/eps)
    warning('matspace:intersectPrecision','This function may have problems if precision gets too small');
end

% create a quantized version of A & B
A2 = precision*round(A/precision);
B2 = precision*round(B/precision);
% do a normal intersect on the quantized data
switch opt_flags
    case 0
        [~, ia1, ib1] = intersect(A2, B2);
    case 1
        [~, ia1, ib1] = intersect(A2, B2, flag);
    case 2
        [~, ia1, ib1] = intersect(A2, B2, flag, setOrder);
end

% due to the splitting of the quanta, two very close numbers could still fail the intersect.
% fix this by repeating the comparsion when shifted by half a quanta.
A2 = precision*round((A+precision/2)/precision) - precision/2;
B2 = precision*round((B+precision/2)/precision) - precision/2;
% do a normal intersect on the shifted and quantized data
switch opt_flags
    case 0
        [~, ia2, ib2] = intersect(A2, B2);
    case 1
        [~, ia2, ib2] = intersect(A2, B2, flag);
    case 2
        [~, ia2, ib2] = intersect(A2, B2, flag, setOrder);
end

% combine the results
ia = union(ia1, ia2);
ib = union(ib1, ib2);

% calculate output
if opt_flags >= 1 && strcmpi(flag,'rows')
    c = A(ia,:);
else
    c = A(ia);
end