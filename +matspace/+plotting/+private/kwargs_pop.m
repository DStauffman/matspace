function [value, unmatched] = kwargs_pop(unmatched, key, default)

% Find the key in unmatched and pop it out, else use the default

if isfield(unmatched, key)
    value = unmatched.(key);
    unmatched = rmfield(unmatched, key);
else
    value = default;
end