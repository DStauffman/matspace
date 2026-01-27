function [ix] = get_rms_indices(time_one, time_two, time_overlap, kwargs)

% Gets the indices and time points for doing RMS calculations and plotting RMS lines.
%
% Parameters
% ----------
% time_one : array_like
%     Time vector one
% time_two : array_like
%     Time vector two
% time_overlap : array_like
%     Time vector of points in both arrays
% xmin : float
%     Minimum time to include in calculation
% xmax : float
%     Maximum time to include in calculation
%
% Returns
% -------
% ix : struct
%     Structure of indices, with fields:
%     pts : [2, ] float
%         Time to start and end the RMS calculations from
%     one : (A, ) ndarray of bool
%         Array of indices into time_one between the rms bounds
%     two : (B, ) ndarray of bool
%         Array of indices into time_two between the rms bounds
%     overlap : (C, ) ndarray of bool
%         Array of indices into time_overlap between the rms bounds
%
% Changl Log:
%     1.  Written by David C. Stauffer in May 2020 when it needed to handle datetime64 objects.
%     2.  Translated into Matlab by David C. Stauffer in January 2026.
%
% Prototype:
%     time_one     = 0:10;
%     time_two     = 2:12;
%     time_overlap = 2:10;
%     xmin         = 1;
%     xmax         = 8;
%     ix = matspace.plotting.get_rms_indices(time_one, time_two, time_overlap, xmin=xmin, xmax=xmax);
%     assert(all(ix.pts == [1 8]));

arguments
    time_one (1, :) {mustBeDoubleOrDatetime} = zeros(1, 0)
    time_two (1, :) {mustBeDoubleOrDatetime} = zeros(1, 0)
    time_overlap (1, :) {mustBeDoubleOrDatetime} = zeros(1, 0)
    kwargs.xmin (1, 1) {mustBeDoubleOrDatetime} = -inf
    kwargs.xmax (1, 1) {mustBeDoubleOrDatetime} = inf
end

% process inputs
xmin = kwargs.xmin;
xmax = kwargs.xmax;

% check consistency of inputs (if any are datetimes, then any non-empty must be datetime)
valid_nums = true(1, 5);
valid_date = true(1, 5);
if ~isempty(time_one)
    valid_nums(1) = isnumeric(time_one);
    valid_date(1) = isdatetime(time_one);
end
if ~isempty(time_two)
    valid_nums(2) = isnumeric(time_two);
    valid_date(2) = isdatetime(time_two);
end
if ~isempty(time_overlap)
    valid_nums(3) = isnumeric(time_overlap);
    valid_date(3) = isdatetime(time_overlap);
end
valid_nums(4) = isnumeric(xmin);
valid_date(4) = isdatetime(xmin);
valid_nums(5) = isnumeric(xmax);
valid_date(5) = isdatetime(xmax);

% initialize output
ix = struct();
if all(valid_nums)
    ix.pts = zeros(1, 0);
elseif all(valid_date)
    ix.pts = NaT(1, 0);
else
    error('All inputs must be numeric or datetime, but you cannot mix and match');
end
ix.one = false(1, 0);
ix.two = false(1, 0);
ix.overlap = false(1, 0);

% alias some flags
have1 = ~isempty(time_one);
have2 = ~isempty(time_two);
have3 = ~isempty(time_overlap);
% get the min/max times
if have1
    if have2
        % have both
        t_min = min([min(time_one), min(time_two)]);
        t_max = max([max(time_one), max(time_two)]);
    else
        % have only time 1
        t_min = min(time_one);
        t_max = max(time_one);
    end
elseif have2
    % have only time 2
    t_min = min(time_two);
    t_max = max(time_two);
else
    % have neither time 1 nor time 2
    assert(false, "At least one time vector must be given.");
end
if process(xmin, t_max, @lt)
    if have1
        p1_min = time_one >= xmin;
    end
    if have2
        p2_min = time_two >= xmin;
    end
    if have3
        p3_min = time_overlap >= xmin;
    end
    ix.pts = [ix.pts, max([xmin, t_min])];
else
    if have1
        p1_min = true(size(time_one));
    end
    if have2
        p2_min = true(size(time_two));
    end
    if have3
        p3_min = true(size(time_overlap));
    end
    ix.pts = [ix.pts, t_min];
end
if process(xmax, t_min, @gt)
    if have1
        p1_max = time_one <= xmax;
    end
    if have2
        p2_max = time_two <= xmax;
    end
    if have3
        p3_max = time_overlap <= xmax;
    end
    ix.pts = [ix.pts, min([xmax, t_max])];
else
    if have1
        p1_max = true(size(time_one));
    end
    if have2
        p2_max = true(size(time_two));
    end
    if have3
        p3_max = true(size(time_overlap));
    end
    ix.pts = [ix.pts, t_max];
end
assert(length(ix.pts) == 2 && ix.pts(1) <= ix.pts(2), 'Time points aren''t as expected: "%f"', ix.pts);
% calculate indices
if have1
    ix.one = p1_min & p1_max;
end
if have2
    ix.two = p2_min & p2_max;
end
if have3
    ix.overlap = p3_min & p3_max;
end


%% Subfunctions - process
function [process] = process(time, t_bound, func)
% Determines if the given time should be processed.
if isdatetime(time)
    process = ~isnat(time) && func(time, t_bound);
elseif isempty(time)
    process = false;
else
    process = ~isnan(time) && ~isinf(time) && func(time, t_bound);
end


%% Subfunctions - mustBeDoubleOrDatetime
function mustBeDoubleOrDatetime(x)

if ~isnumeric(x) && ~isdatetime(x)
    throwAsCaller(MException('matspace:plotting:BadTimeValue','Input must be numeric or datetime.'))
end