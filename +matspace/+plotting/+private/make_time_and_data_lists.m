function [times, datum]  = make_time_and_data_lists(time, data, kwargs)

% Turns the different types of inputs into lists of 1-D data.

arguments
    time
    data
    kwargs.DataAsRows (1,1) logical
    kwargs.IsQuat (1,1) logical = false
end

data_as_rows = kwargs.DataAsRows;
is_quat = kwargs.IsQuat;
if is_quat
    mustBeQuat(data);
end

if isempty(data)
    % assert isempty(time, 'Time must be empty if data is empty.'  % TODO: include this?
    times = cell(1, 0);
    datum = cell(1, 0);
    return
end
if iscell(data)
    datum = data;
else
    this_data = data;
    if ~ismatrix(this_data)
        error('data_one must be 0d, 1d or 2d.');
    end
    if data_as_rows
        datum = cell(1, size(this_data, 1));
        for i = 1:size(this_data, 1)
            datum{i} = this_data(i, :);
        end
    else
        datum = cell(1, size(this_data, 2));
        for i = 1:size(this_data, 2)
            datum{i} = this_data(:, i);
        end
    end
end
num_chan = length(datum);
if is_quat && num_chan ~= 4
    error('Must be a 4-element quaternion');
end
if iscell(time)
    assert(length(time) == num_chan, 'The number of time channels must match the number of data channels, not %i and %i.', length(time), num_chan);
    times = time;
else
    [times(1:num_chan)] = {time};
end