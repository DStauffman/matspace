function [ix] = build_diff_indices(times1, times2, time_overlap, kwargs)

% Builds a structure of indices for the given RMS (or mean) start and stop times for multiple time vectors.

arguments
    times1
    times2
    time_overlap
    kwargs.RmsXmin
    kwargs.RmsXmax
end
rms_xmin = kwargs.RmsXmin;
rms_xmax = kwargs.RmsXmax;

import matspace.plotting.get_rms_indices
import matspace.plotting.private.build_indices
import matspace.utils.ifelse

if isempty(times1) && isempty(times2)
    % have nothing
    ix = struct('pts', zeros(1, 0));
    return
end
if ~isempty(times1) && isempty(times2)
    % only have times1
    ix = build_indices(times1, rms_xmin, rms_xmax, Label='one');
    return
end
if isempty(times1) && ~isempty(times2)
    % only have times2
    ix = build_indices(times2, rms_xmin, rms_xmax, Label='two');
    return
end
% have both times1 and times2
% TODO: pass in this information instead of repeating it
dt_same = ifelse(isdatetime(times1{1}), seconds(1e-12), 1e-12);  % TODO: is this possible?  How accurate are datetimes?
have_unique_t1 = isscalar(unique(cellfun(@length, times1))) && all(cellfun(@(x) max(abs(x - times1{1})), times1) < dt_same);
have_unique_t2 = isscalar(unique(cellfun(@length, times2))) && all(cellfun(@(x) max(abs(x - times2{1})), times2) < dt_same);
for i = 1:length(times1)
    this_time1 = times1{i};
    this_time2 = times2{i};
    this_overlap = time_overlap{i};
    if i == 1 || ~have_unique_t1 || ~have_unique_t2
        temp_ix = get_rms_indices(this_time1, this_time2, this_overlap, xmin=rms_xmin, xmax=rms_xmax);
    end
    if i == 1
        ix = [];
        ix.pts = temp_ix.pts;
        ix.one = cell(1, 0);
        ix.two = cell(1, 0);
        ix.overlap = cell(1, 0);
    else
        ix.pts = [min([ix.pts(1), temp_ix.pts(1)]), max([ix.pts(2), temp_ix.pts(2)])];
    end
    ix.one{end + 1} = temp_ix.one;
    ix.two{end + 1} = temp_ix.two;
    ix.overlap{end + 1} = temp_ix.overlap;
end