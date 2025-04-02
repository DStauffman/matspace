function [data] = load_hdf5(filename, base)

% LOAD_HDF5  loads the data from an HDF5 file into a MATLAB struct.
%
% Summary:
%     TBD
%
% Input:
%     filename : (row) Filename to load [char]
%
% Output:
%     data : (struct) Data from the file [num]
%
% Prototype:
%     filename = fullfile(matspace.paths.get_root_dir(), 'data', 'seeds.hdf5');
%     data = matspace.utils.load_hdf5(filename, '/');
%     assert(all(data.seeds(1:5) == [27713; 53319; 35561; 29419; 31308]));
%
% Notes:
%     1.  Written by David C. Stauffer in July 2022.

% arguments
arguments
    filename (1,:) char
    base (1,:) = '/self'
end

% open the file and find the datasets
info = h5info(filename, base);
datasets = string({info.Datasets(:).Name});

% initialize the output structure
data = struct();

% loop through embedded datasets
for i = 1:length(datasets)
    key = datasets{i};
    this_set = base + "/" + key;
    this_data = h5read(filename, this_set);
    size_data = size(this_data);
    if length(size_data) < 3
        if ischar(this_data)
            data.(key) = this_data;
        elseif size_data(1) == 1 || size_data(2) == 1
            data.(key) = this_data(:);
        else
            % TODO: HDF5 is row-wise data, so transpose
            data.(key) = transpose(this_data);
        end
    else
        % HDF5 is row-wise data, so transpose
        data.(key) = permute(this_data, [3 2 1]);
    end
end