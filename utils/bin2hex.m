function [hexstr] = bin2hex(binstr, varargin)

% CONVERTS a binary string of zeros and ones to its hexidecimal string representation.
%
% Input:
%     binstr : char of zeros and ones or spaces
%     options : conversion options from {'lower', 'upper', 'pad4', 'pad8'}
%
% Output:
%     hexstr : char of hexidecimal equivalent
%
% Examples:
%     hex = bin2hex('1010')  return 'A'
%     hex = bin2hex('0000 0001 0010 0011 0100 0101 0110 0111', 'pad4')  returns '0123 4567'
%     hex = bin2hex('1000 1001 1010 1011 1100 1101 1110 1111', 'lower')  returns '89abcdef'
%
% Notes:
%     1.  'lower' converts the hexidecimal outputs to lowercase letters for a-f
%     2.  'upper' converts the hexidecimal outputs to uppercase letters for A-F
%     3.  'pad4' and 'pad8' add spaces as pads every 4 or 8 characters respectively
%
% See Also:
%     hex2bin, bin2dec, dec2bin, hex2dec, dec2hex
%
% Change Log:
%     1.  Written by David C. Stauffer in October 2018.

% check for empty case
if isempty(binstr)
    hexstr = '';
    return
end

% parse optional inputs
if isempty(varargin)
    options = {};
else
    options = varargin;
end

% deal with char/cell/string options
if ischar(binstr)
    hexstr = bin2hex_func(binstr, options);
elseif iscellstr(binstr)
    hexstr = cell(size(binstr));
    for i = 1:numel(binstr)
        hexstr{i} = bin2hex_func(binstr{i}, options);
    end
elseif isstring(binstr)
    hexstr = strings(size(binstr));
    for i = 1:numel(binstr)
        hexstr{i} = bin2hex_func(binstr{i}, options);
    end
else
    error('matspace:bin2hex:InvalidInputClass', 'Unexpected input class.');
end

%% Subfunctions - bin2hex_func
function [hexstr] = bin2hex_func(binstr, options)

% BIN2HEX_FUNC  is the actual implementation, separated out so that it can be called via a loop.

% hard-coded values
allowed_chars = ['0'; '1'; ' '];

% check string for allowed characters
chars = unique(binstr(:));
extra = setdiff(chars, allowed_chars);
if ~isempty(extra)
    error('matspace:bin2hex:BadChars', 'The following characters are not allowed in the input "%s".', extra);
end

% remove any spaces
clean = binstr(binstr ~= ' ');

% pad to an even hex boundary
pad = repmat('0', 1, mod(-length(clean), 4));
clean = [pad clean];

num_chars = length(clean) / 4;
assert(num_chars == round(num_chars), 'This should always be an integer if the padding is working correctly.');

hexstr = repmat('X', 1, num_chars);
for i = 1:num_chars
    hexstr(i) = get_hex(clean(4*i-3:4*i));
end

% process extra options
for i = 1:length(options)
    switch options{i}
        case 'lower'
            hexstr = lower(hexstr);
        case 'upper'
            hexstr = upper(hexstr);
        case 'pad4'
            hexstr = add_pad(hexstr, 4);
        case 'pad8'
            hexstr = add_pad(hexstr, 8);
        otherwise
            error('matspace:bin2hex:BadOption', 'Unexpected option string of "%s"', options{i});
    end
end

%% Subfunctions - get_hex
function [hex] = get_hex(bin)

% GET_HEX converts a four character binary array into the hex equivalent.

switch bin
    case '0000'
        hex = '0';
    case '0001'
        hex = '1';
    case '0010'
        hex = '2';
    case '0011'
        hex = '3';
    case '0100'
        hex = '4';
    case '0101'
        hex = '5';
    case '0110'
        hex = '6';
    case '0111'
        hex = '7';
    case '1000'
        hex = '8';
    case '1001'
        hex = '9';
    case '1010'
        hex = 'A';
    case '1011'
        hex = 'B';
    case '1100'
        hex = 'C';
    case '1101'
        hex = 'D';
    case '1110'
        hex = 'E';
    case '1111'
        hex = 'F';
    otherwise
        error('matspace:bin2hex:BadBinary', 'Unexpected binary string of "%s"', bin);
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