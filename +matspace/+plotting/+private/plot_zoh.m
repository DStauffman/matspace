function [line] = plot_zoh(ax, time, data ,symbol, varargin)
%Plots a zero-order hold step plot with passthrough options.
try
    if all(isnan(data))
        line = [];
        return
    end
catch % TypeError
    % no-op  % likely categorical data that cannot be safely coerced to NaNs
end
line = stairs(ax, time, data, symbol, varargin{:});