function [ix] = build_indices(times, rms_xmin, rms_xmax, kwargs)

% Builds a structure of indices for the given RMS (or mean) start and stop times.

arguments
    times
    rms_xmin
    rms_xmax
    kwargs.Label {mustBeMember(kwargs.Label, ["one", "two"])} = 'one'
end
label = kwargs.Label;

import matspace.plotting.get_rms_indices

ix = struct();
ix.pts = zeros(1, 0);
ix.(label) = cell(1, 0);
if isempty(times)
    % no times given, so nothing to calculate
    return
end
if isscalar(unique(cellfun(@length, times))) && max(cellfun(@(x) max(abs(x - times{1})), times)) < 1e-12
    % case where all the time vectors are exactly the same
    temp_ix = get_rms_indices(times{1}, xmin=rms_xmin, xmax=rms_xmax);
    ix.pts = temp_ix.pts;
    ix.(label) = {temp_ix.one};
end
for i = 1:length(times)
    this_time = times{i};
    % general case
    temp_ix = get_rms_indices(this_time, xmin=rms_xmin, xmax=rms_xmax);
    if i == 1
        ix.pts = temp_ix.pts;
    else
        ix_pts = ix.pts;
        tp_pts = temp_ix.pts;
        ix.pts = [min([ix_pts(1), tp_pts(1)]), max([ix_pts(2), tp_pts(2)])];
    end
    ix.(label) = [ix.(label), temp_ix.one];
end