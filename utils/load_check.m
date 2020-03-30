function varargout = load_check(filename, varargin)

% LOAD_CHECK  loads the specified variables from file, but converts missing ones to warnings
%             and returns empties in those cases rather than erroring out.
%
% Input:
%     filename : (char) Name of file to be loaded
%     varargin : |opt| (char) Names of variables to load
%
% Output:
%   varargout : variables loaded from file
%
% Prototype:
%     x = 1;
%     y = 2;
%     save('data.mat', 'x', 'y');
%     [x, y, z] = load_check('data.mat', 'x', 'y', 'z');
%
% Notes:
%     1.  If variable names are not specified, full contents of file are returned as a struct.
%
% Change Log:
%     1.  Borrowed and slightly modified from RECAP version by David C. Stauffer in August 2019.

%% Check inputs
switch nargin
    case 1
        % nop
    otherwise
        if nargout ~= nargin - 1
            error('load_check:IOMismatch', 'Number of outputs must match number of inputs.');
        end
end

%% Preallocate output
% initialize output as empty
varargout = cell(1, nargout);

%% Read file
if exist(filename, 'file') == 2
    % load specified variables
    val = load( filename, varargin{:} );
    % load will return a struct with fields corresponding to each
    % requested variable it found in the file, in unknown order
else
    % this function is intended to "cover" for missing files
    % throw a warning message instead of an error
    warning('loadcheck:FileNotFound', 'File not found: "%s"', filename);
    return
end

%% Deal with output
% load creates val as a struct: copy fields to appropriate outputs
if nargin ~= 1 && isstruct(val)
    for ivar = 1:nargout
        % locate requested variable in the struct
        if isfield(val, varargin{ivar})
            % variable found: assign output
            varargout{ivar} = val.(varargin{ivar});
        end
    end
else
    % return complete contents of file in struct form
    varargout{1} = val;
end