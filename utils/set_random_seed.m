function [] = set_random_seed(is_repeatable,seed,num_cycles,cycle)

% SET_RANDOM_SEED  sets the random seed in such a way as to force parfor loops to be independent.
%
% Summary:
%     This function creates an instance of the RandStream object, modifies the appropriate settings
%     and then globally sets this as the stream from which random numbers are generated.
%
% Input:
%     is_repeatable : (scalar) true/false flag for whether the sequence is repeatable [bool]
%     seed          : (1xN)    number to be used as seed for the repeatable sequence [ndim]
%     num_cycles    : (scalar) number of independent cycles to generate [ndim]
%     cycle         : (scalar) number of the stream to be used for non-repeatable sequences [ndim]
%
% Output:
%    None - effects any future random calls through the RandStream object interface.
%
% Prototype:
%     is_repeatable = false;
%     seed          = 0;
%     num_cycles    = 5;
%     cycle         = 1;
%     set_random_seed(is_repeatable,seed,num_cycles,cycle);
%
% Change Log:
%     1.  Written by David Stauffer in Apr 2014.
%     2.  Added to DStauffman MATLAB library in December 2015.

if is_repeatable
    rndstr = RandStream.create('mrg32k3a','NumStreams',num_cycles,'StreamIndices',cycle,'Seed',seed(cycle));
else
    rndstr = RandStream.create('mrg32k3a','NumStreams',num_cycles,'StreamIndices',cycle);
end
RandStream.setGlobalStream(rndstr);