function [data_func, func_name] = calc_rms(datum, ix, kwargs)

% Calculates the RMS/mean.

arguments
    datum (1, :) cell
    ix (1, :) cell
    kwargs.UseMean (1, 1) logical
end

import matspace.utils.nanmean
import matspace.utils.nanrms

use_mean = kwargs.UseMean;

if ~use_mean
    func_name = 'RMS';
    func_lamb = @nanrms;
else
    func_name = 'Mean';
    func_lamb = @nanmean; %#ok<NANMEAN>
end
data_func = cell(1, length(datum));
for j = 1:length(datum)
    data = datum{j};
    data_func{j} = func_lamb(data(ix{j}));
end