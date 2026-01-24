function [line] = plot_linear(ax, time, data, symbol, varargin)
% Plots a normal linear plot with passthrough options.
try
    if all(isnan(data))
        line = [];
        return
    end
catch % TypeError
    % no-op  % likely categorical data that cannot be safely coerced to NaNs
end
line = plot(ax, time, data, symbol, varargin{:});