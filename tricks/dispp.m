function [] = dispp(in,name)

% DISPP  is a structure recursive version of the built-in 'disp'
%
% PROTOTYPE:
%     disp('text');
%     a.b = 1;
%     disp(a);
%     b.c.d = [1 2];
%     disp(b);
%     c(1:5) = a;
%     disp(a);

if nargin == 1
    name = inputname(1);
end

if ~isstruct(in)
    % not a structure, so use the built in version
    builtin('disp',in);
else
    if length(in) == 1
        % is a structure, so loop through the fieldnames
        fn = fieldnames(in);
        for i=1:length(fn)
            if isstruct(in.(fn{i}))
                disp([name,'.',fn{i}]);
                dispp(in.(fn{i}),[name,'.',fn{i}]);
            else
                disp([name,'.',fn{i}]);
                builtin('disp',in.(fn{i}));
            end
        end
        builtin('disp',in);
    else
        % more than one element, so an array of structures, use build in version
        builtin('disp',in);
    end
end