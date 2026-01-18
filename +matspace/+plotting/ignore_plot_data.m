function [ignore] = ignore_plot_data(data, ignore_empties, col)

% Determine whether to ignore this data or not.
% 
% Inputs:
% data : (N, M) ndarray
%     Data to plot or ignore
% ignore_empties : bool
%     Whether to potentially ignore empties or not
% col : int, optional
%     Column number to look at to determine if ignoring, if not present, look at entire matrix
% 
% Output:
% ignore : bool
%     Whether data is null (all zeros/nans) and should be ignored.
% 
% Notes:
%     1.  Written by David C. Stauffer in April 2017.
%     2.  Translated into Matlab by David C. Stauffer in January 2026.
% 
% Prototype:
%     data = zeros([3, 10])
%     ignore_empties = true;
%     col = 2;
%     ignore = matspace.plotting.ignore_plot_data(data, ignore_empties, col);
%     assert(ignore);

switch nargin
    case 1
        ignore_empties = false;
        use_col = false;
    case 2
        use_col = false;
    case 3
        use_col = true;
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% if we are not ignoring empties then never ignore
if ~ignore_empties
    ignore = false;
    return
end
% if data is empty, ignore it
if isempty(data) || (iscell(data) && all(cellfun(@isempty, data)))
    ignore = true;
    return
end
% otherwise determine if ignoring by seeing if data is all zeros or nans
if ~use_col
    ignore = all(data == 0 | isnan(data), 'all');
else
    ignore = all((data(:, col) == 0) | isnan(data(:, col)));
end