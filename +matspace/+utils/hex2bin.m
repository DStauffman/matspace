function [binstr] = hex2bin(hexstr, leading_zeros, kwargs)

% CONVERTS a hexadecimal string of characters to its binary string representation.
%
% Input:
%     hexstr : char of hexadecimal
%     leading_zeros : whether to include leading zeros or not, from {'drop', 'keep'}, default is keep
%     kwargs : keyword arguments
%         .group number of characters in each group, separated by spaces, default of zero means no grouping
%
% Output:
%     binstr : char of zeros and ones or spaces
%
% Examples:
%     bin = matspace.utils.hex2bin('A');
%     assert(strcmp(bin, '1010'));
%     bin = matspace.utils.hex2bin('012', 'drop');
%     assert(strcmp(bin, '10010'));
%     bin = matspace.utils.hex2bin('89abcdef', 'group', 4);
%     assert(strcmp(bin, '1000 1001 1010 1011 1100 1101 1110 1111'));
%
% Notes:
%     1.  You could use dec2bin(hex2dec(hex)), but this can have issues for numbers over 53 bits,
%         which lose precision when converted to floating point values. This function avoids those
%         conversions.  It can also handle spaces for visual representation.
%
% See Also:
%     matspace.utils.bin2hex, bin2dec, dec2bin, hex2dec, dec2hex
%
% Change Log:
%     1.  Written by David C. Stauffer in October 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.
%     3.  Updated by David C. Stauffer in January 2023 to use function arguments.

arguments
    hexstr {mustBeText, mustBeHexStr}
    leading_zeros {mustBeMember(leading_zeros, ["drop", "keep"])} = 'keep'
    kwargs.group {mustBeInteger, mustBeTwoMult(kwargs.group)} = 0
end

% check for empty case
if isempty(hexstr)
    binstr = '';
    return
end

% deal with char/cell/string options
if ischar(hexstr)
    binstr = hex2bin_func(hexstr, leading_zeros, kwargs);
elseif iscellstr(hexstr)
    binstr = cell(size(hexstr));
    for i = 1:numel(hexstr)
        binstr{i} = hex2bin_func(hexstr{i}, leading_zeros, kwargs);
    end
elseif isstring(hexstr)
    binstr = strings(size(hexstr));
    for i = 1:numel(hexstr)
        binstr{i} = hex2bin_func(hexstr{i}, leading_zeros, kwargs);
    end
else
    % should not be possible to get here based on arguments validation
    error('matspace:hex2bin:InvalidInputClass', 'Unexpected input class.');
end

%% Subfunctions - hex2bin_func
function [binstr] = hex2bin_func(hexstr, leading_zeros, kwargs)

% HEX2BIN_FUNC  is the actual implementation, separated out so that it can be called via a loop.

% remove any spaces
clean = hexstr(hexstr ~= ' ');

% preallocate
binstr = repmat('X', 1, 4 * length(clean));
for i = 1:length(clean)
    % populate output
    binstr(4*i-3:4*i) = get_bin(clean(i));
end

% process extra options
switch leading_zeros
    case 'drop'
        ix = find(binstr == '1', 1, 'first');
        binstr = binstr(ix:end);
    case 'keep'
        % nop
    otherwise
        % should not be possible to get here based on arguments validation
        error('matspace:hex2bin:BadOption', 'Unexpected option string of "%s"', leading_zeros);
end

if kwargs.group ~= 0
    binstr = add_pad(binstr, kwargs.group);
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

%% Subfunctions - mustBeTwoMult(x)
function mustBeTwoMult(x)
% validates the grouping options
if ~any(x == [0 2 4 8 16 32])
    eidType = 'matspace:hex2bin:badGrouping';
    msgType = 'Output must be grouped by 0, 2, 4, 8, 16 or 32 bits.';
    throwAsCaller(MException(eidType, msgType));
end

%% Subfunctions - mustBeBinaryStr
function mustBeHexStr(x)
% validates the allowed binary string characters, either 0, 1 or space

% hard-coded values
temp = '0123456789 ABCDEFabcdef';
allowed_chars = temp(:);

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
    throwAsCaller(MException('matspace:hex2bin:BadChars', ...
        'The following characters are not allowed in the input "%s".', extra));
end