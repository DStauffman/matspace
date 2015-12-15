function [seeds] = build_brackets(waves)

% PROTOTYPE:
%     seeds = build_brackets(0);
%     seeds = build_brackets(1);
%     seeds = build_brackets(2);
%     seeds = build_brackets(3);

seeds = [1 2 3];
for i = 1:waves
    this_complement = 3*2^i+1;
    for j = length(seeds):-1:1
        seeds = [seeds(1:j), this_complement-seeds(j),seeds(j+1:end)];
    end
end