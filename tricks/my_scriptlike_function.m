function [] = my_scriptlike_function(x, y, z)

%% Get inputs
switch nargin
    case 0
        x = evalin('base', 'x');
        y = evalin('base', 'y');
        z = evalin('base', 'z');
    case 3
        % nop
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%s"', nargin);
end

%% Actual function logic
out = x + y.^2 - z/10;

%% Save variables to workspace
if nargout == 0
    vars = who;
    for i = 1:length(vars)
        assignin('base', vars{i}, eval(vars{i}));
    end
end