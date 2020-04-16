function [mask] = first_mask(bool_array)

% FIRST_MASK  gets the column index for the first time the boolean is true for each row.
%
% Input:
%     bool_array : (AxB) boolean array of whether on ART [bool]
%
% Output:
%     mask ..... : (AxB) boolean array where every line will only have one true at the first instance of ART [bool]
%
% Prototype:
%     bool_array = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 1 1];
%     mask       = matspace.utils.first_mask(bool_array);
%     assert(all(all(mask == [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 0 0; 1 0 0; 0 1 0; 1 0 0])));
%
% Change Log:
%     1.  Written by David C. Stauffer in Jan 2015.
%     2.  Added by David C. Stauffer to the matspace library in December 2015.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.

% get the number of rows and columns
[rows,cols] = size(bool_array);

% initailize the output mask
mask = false(rows,cols);

% deal with the first sample point, which is true iff true in the first column of bool_array
mask(:,1) = bool_array(:,1);

% loop through the columns and do "OR" comparisons to find all the transitions
for i = 2:cols
    mask(:,i) = or(bool_array(:,i),bool_array(:,i-1));
end

% loop back through the data from the end to the beginning doing "AND" comparsons to only keep the
% first transition
for i = cols:-1:2
    mask(:,i) = mask(:,i) & ~mask(:,i-1);
end