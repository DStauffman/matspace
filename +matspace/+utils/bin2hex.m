function [hexstr] = bin2hex(binstr, capitilization, kwargs)

% CONVERTS a binary string of zeros and ones to its hexadecimal string representation.
%
% Input:
%     binstr : char of zeros and ones or spaces
%     capitilization : capitilization of hex string, from {'lower', 'upper'}, default is upper
%     kwargs : keyword arguments
%         .group number of characters in each group, separated by spaces, default of zero means no grouping
%
% Output:
%     hexstr : char of hexadecimal equivalent
%
% Examples:
%     hex = matspace.utils.bin2hex('1010');
%     assert(strcmp(hex, 'A'));
%     hex = matspace.utils.bin2hex('0000 0001 0010 0011 0100 0101 0110 0111', 'group', 4);
%     assert(strcmp(hex, '0123 4567'));
%     hex = matspace.utils.bin2hex('1000 1001 1010 1011 1100 1101 1110 1111', 'lower');
%     assert(strcmp(hex, '89abcdef'));
%
% Notes:
%     1.  'lower' converts the hexadecimal outputs to lowercase letters for a-f
%     2.  'upper' converts the hexadecimal outputs to uppercase letters for A-F
%     3.  'pad4' and 'pad8' add spaces as pads every 4 or 8 characters respectively
%
% See Also:
%     matspace.utils.hex2bin, bin2dec, dec2bin, hex2dec, dec2hex
%
% Change Log:
%     1.  Written by David C. Stauffer in October 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.
%     3.  Updated by David C. Stauffer in January 2023 to use function arguments.

arguments
    binstr {mustBeText, mustBeBinaryStr}
    capitilization {mustBeMember(capitilization, ["lower", "upper"])} = 'upper'
    kwargs.group {mustBeInteger, mustBeTwoMult(kwargs.group)} = 0
end

% check for empty case
if isempty(binstr)
    hexstr = '';
    return
end

% deal with char/cell/string options
if ischar(binstr)
    hexstr = bin2hex_func(binstr, capitilization, kwargs);
elseif iscellstr(binstr)
    hexstr = cell(size(binstr));
    for i = 1:numel(binstr)
        hexstr{i} = bin2hex_func(binstr{i}, capitilization, kwargs);
    end
elseif isstring(binstr)
    hexstr = strings(size(binstr));
    for i = 1:numel(binstr)
        hexstr{i} = bin2hex_func(binstr{i}, capitilization, kwargs);
    end
else
    % should not be possible to get here based on arguments validation
    error('matspace:bin2hex:InvalidInputClass', 'Unexpected input class.');
end

%% Subfunctions - bin2hex_func
function [hexstr] = bin2hex_func(binstr, capitilization, kwargs)

% BIN2HEX_FUNC  is the actual implementation, separated out so that it can be called via a loop.

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
switch capitilization
    case 'lower'
        hexstr = lower(hexstr);
    case 'upper'
        hexstr = upper(hexstr);
    otherwise
        % should not be possible to get here based on arguments validation
        error('matspace:bin2hex:BadOption', 'Unexpected option string of "%s"', capitilization);
end

if kwargs.group ~= 0
    hexstr = add_pad(hexstr, kwargs.group);
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

%% Subfunctions - mustBeTwoMult(x)
function mustBeTwoMult(x)
% validates the grouping options
if ~any(x == [0 2 4 8 16 32])
    eidType = 'matspace:bin2hex:badGrouping';
    msgType = 'Output must be grouped by 0, 2, 4, 8, 16 or 32 bits.';
    throwAsCaller(MException(eidType, msgType));
end

%% Subfunctions - mustBeBinaryStr
function mustBeBinaryStr(x)
% validates the allowed binary string characters, either 0, 1 or space

% hard-coded values
allowed_chars = ['0'; '1'; ' '];

% check string for allowed characters
if ischar(x)
    chars = unique(x);
else
    chars = [];
    for i = 1:length(x)
        chars = unique([chars, unique(x{i})]);
    end
end
extra = setdiff(chars, allowed_chars);
if ~isempty(extra)
    throwAsCaller(MException('matspace:bin2hex:BadChars', ...
        'The following characters are not allowed in the input "%s".', extra));
end