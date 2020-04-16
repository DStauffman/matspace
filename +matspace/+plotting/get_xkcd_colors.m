function [colors] = get_xkcd_colors(filename)

% GET_XKCD_COLORS  reads the XKCD RGB color codes from the given filename.
%
% Input:
%     filename : (str) name of the file to read [char]
%
% Output:
%     colors     : (struct) Color code structure
%         .red   : (1x3) Color code for red
%         .blue  : (1x3) Color code for blue
%         .green : (1x3) color code for green
%           ... Many more, about 949 total in xkcd_rgb_colors
%
% Prototype:
%     filename = fullfile(matspace.paths.get_root_dir(), 'data', 'xkcd_rgb_colors.txt');
%     colors = matspace.plotting.get_xkcd_colors(filename);
%
% See Also:
%     matspace.plotting.get_color_lists
%
% Notes:
%     1.  See http://xkcd.com/color/rgb.txt for colors.
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

% optional inputs
switch nargin
    case 0
        import matspace.paths.get_root_dir % Note: delayed import as you don't need it if specifying the file directly
        filename = fullfile(get_root_dir(), 'data', 'xkcd_rgb_colors.txt');
    case 1
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% check for persistents to avoid loading from file again
persistent colors_ from_file
if ~isempty(colors_) && strcmp(filename, from_file)
    colors = colors_;
    return
end

% hard-coded values
num_header_lines = 1;

% open file
fid = fopen(filename, 'rt');
if fid == -1
    error('matspace:xkcdColors:BadFileOpen', 'Unable to open "%s" for reading.', filename);
end

% read the file
data = textscan(fid, '%s %s', 'Delimiter', '\t');

% close the file
fclose(fid);

% parse data
names = string(data{1});
rgb_hex = string(data{2});

% clean up names by converting spaces to underscores, slashes to dunders, and removing apostrophese.
names = names.replace(' ', '_');
names = names.replace('/', '__');
names = names.replace('''', '');
assert(length(names) == length(unique(names)), 'All colors names should be unique.');

% build the output structure
colors = [];
for i = 1+num_header_lines:length(names)
    % convert the hex codes to Matlab vectors
    colors.(names{i}) = rgb_hex_to_vec(rgb_hex{i});
end

% save future persistent values
colors_ = colors;
from_file = filename;


%% Subfunctions - rgb_hex_to_vec
function [vec] = rgb_hex_to_vec(hex, normalized)

% RGB_HEX_TO_VEC converts an RGB hex string to a MATLAB 3 vector

% optional inputs
switch nargin
    case 1
        normalized = true;
    case 2
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end
red = 16*hex_to_num(hex(2)) + hex_to_num(hex(3));
grn = 16*hex_to_num(hex(4)) + hex_to_num(hex(5));
blu = 16*hex_to_num(hex(6)) + hex_to_num(hex(7));

vec = [red, grn, blu];
if normalized
    vec = vec / 256;
end


%% Subfunctions - hex_to_num
function [num] = hex_to_num(hex)
% HEX_TO_NUM  converts a single hexidecimal character to its numeric value
switch hex
    case '0'
        num = 0;
    case '1'
        num = 1;
    case '2'
        num = 2;
    case '3'
        num = 3;
    case '4'
        num = 4;
    case '5'
        num = 5;
    case '6'
        num = 6;
    case '7'
        num = 7;
    case '8'
        num = 8;
    case '9'
        num = 9;
    case {'a', 'A'}
        num = 10;
    case {'b', 'B'}
        num = 11;
    case {'c', 'C'}
        num = 12;
    case {'d', 'D'}
        num = 13;
    case {'e', 'E'}
        num = 14;
    case {'f', 'F'}
        num = 15;
end