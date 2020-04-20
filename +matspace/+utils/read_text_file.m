function [lines] = read_text_file(filename)

% READ_TEXT_FILE  reads the given text file into a string array
%
% Input:
%     filename : (string) specifying the name of the file to write [char]
%     text : (string) text to write to the file [char]
%
% Output:
%     None
%
% Prototype:
%     filename = fullfile(matspace.paths.get_root_dir(), '+matspace', '+utils', 'calculate_bin.m');
%     lines = matspace.utils.read_text_file(filename);
%
%     % clean-up
%     delete(filename);
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2020.

% open file for writing
fid = fopen(filename, 'rt');
if fid == -1
    error('matspace:BadFileOpen', 'Unable to open "%s" for reading.', filename);
end

% initialize the output
lines = strings(0, 1);

% read the data line by line
this_line = fgetl(fid);
while ischar(this_line)
    % append the last line read
    lines(end+1, 1) = this_line; %#ok<AGROW>
    % get a new line, note that this return -1 when no more text is available, thus breaking the loop
    this_line = fgetl(fid);
end

% close file
fclose(fid);