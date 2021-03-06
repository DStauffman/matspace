function [binstr] = hex2bin(hexstr, varargin)

% CONVERTS a hexidecimal string of characters to its binary string representation.
%
% Input:
%     hexstr : char of hexidecimal
%     options : conversion options from {'drop', 'pad4', 'pad8'}
%
% Output:
%     binstr : char of zeros and ones or spaces
%
% Examples:
%     bin = matspace.utils.hex2bin('A');
%     assert(strcmp(bin, '1010'));
%     bin = matspace.utils.hex2bin('012', 'drop');
%     assert(strcmp(bin, '10010'));
%     bin = matspace.utils.hex2bin('89abcdef', 'pad4');
%     assert(strcmp(bin, '1000 1001 1010 1011 1100 1101 1110 1111'));
%
% Notes:
%     1.  'drop' drops any leading zeros on the resulting binary string
%     2.  'pad4' and 'pad8' add spaces as pads every 4 or 8 characters respectively
%
% See Also:
%     matspace.utils.bin2hex, bin2dec, dec2bin, hex2dec, dec2hex
%
% Change Log:
%     1.  Written by David C. Stauffer in October 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

% check for empty case
if isempty(hexstr)
    binstr = '';
    return
end

% parse optional inputs
if isempty(varargin)
    options = {};
else
    options = varargin;
end

% deal with char/cell/string options
if ischar(hexstr)
    binstr = hex2bin_func(hexstr, options);
elseif iscellstr(hexstr)
    binstr = cell(size(hexstr));
    for i = 1:numel(hexstr)
        binstr{i} = hex2bin_func(hexstr{i}, options);
    end
elseif isstring(hexstr)
    binstr = strings(size(hexstr));
    for i = 1:numel(hexstr)
        binstr{i} = hex2bin_func(hexstr{i}, options);
    end
else
    error('matspace:bin2hex:InvalidInputClass', 'Unexpected input class.');
end

%% Subfunctions - hex2bin_func
function [binstr] = hex2bin_func(hexstr, options)

% HEX2BIN_FUNC  is the actual implementation, separated out so that it can be called via a loop.

% hard-coded values
temp = '0123456789 ABCDEFabcdef';
allowed_chars = temp(:);

% check string for allowed characters
chars = unique(hexstr(:));
extra = setdiff(chars, allowed_chars);
if ~isempty(extra)
    error('matspace:hex2bin:BadChars', 'The following characters are not allowed in the input "%s".', extra);
end

% remove any spaces
clean = hexstr(hexstr ~= ' ');

% preallocate
binstr = repmat('X', 1, 4 * length(clean));
for i = 1:length(clean)
    % populate output
    binstr(4*i-3:4*i) = get_bin(clean(i));
end

% process extra options
for i = 1:length(options)
    switch options{i}
        case 'drop'
            ix = find(binstr == '1', 1, 'first');
            binstr = binstr(ix:end);
        case 'pad4'
            binstr = add_pad(binstr, 4);
        case 'pad8'
            binstr = add_pad(binstr, 8);
        otherwise
            error('matspace:hex2bin:BadOption', 'Unexpected option string of "%s"', options{i});
    end
end

%% Subfunctions - get_hex
function [bin] = get_bin(hex)

% GET_BIN converts a single hex character into the four bit binary equivalent.

switch upper(hex)
    case '0'
        bin = '0000';
    case '1'
        bin = '0001';
    case '2'
        bin = '0010';
    case '3'
        bin = '0011';
    case '4'
        bin = '0100';
    case '5'
        bin = '0101';
    case '6'
        bin = '0110';
    case '7'
        bin = '0111';
    case '8'
        bin = '1000';
    case '9'
        bin = '1001';
    case 'A'
        bin = '1010';
    case 'B'
        bin = '1011';
    case 'C'
        bin = '1100';
    case 'D'
        bin = '1101';
    case 'E'
        bin = '1110';
    case 'F'
        bin = '1111';
    otherwise
        error('Unexpected binary string of "%s"', hex);
end

%% Subfunctions - add_pad
function [new] = add_pad(old, pad)

% ADD_PAD  adds a space every `pad` places to the string.
%
% old = '1234567890'
% pad = 4;
% new = add_pad(old, pad);
% assert(strcmp(new, '12 3456 7890'));

% get orginial length
orig_len = length(old);
% determine how many spaces to add
spaces = floor((orig_len-1) / pad);
if spaces > 0
    % preallocate final string to all spaces
    new = repmat(' ', 1, orig_len+spaces);
    % loop through backwards to add chunks of characters
    for i = 0:spaces-1
        temp = orig_len - (pad*i:pad*i+pad-1);
        new(temp+spaces-i) = old(temp);
    end
    % deal with the final block that might be shorter than the rest
    temp = 1:(mod(orig_len-1,pad)+1);
    new(temp) = old(temp);
else
    new = old;
end