function [] = write_text_file(filename, text)

% check if simple character array and if so, convert to string array
%
% Input:
%     filename : (string) specifying the name of the file to write [char]
%     text : (string) text to write to the file [char]
%
% Output:
%     None
%
% Prototype:
%     filename = 'temp_file.txt';
%     text = ["Some text"; "Another Line"];
%     matspace.utils.write_text_file(filename, text);
%
%     % clean-up
%     delete(filename);
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

% open file for writing
fid = fopen(filename, 'wt');
if fid == -1
    error('matspace:BadFileOpen', 'Unable to open "%s" for writing.', filename);
end

% check or simple character array case
if ischar(text)
    % write out all at once
    fprintf(fid, '%s', text);
else
    % if cell or string array, then write line by line
    for i = 1:length(text)-1
        fprintf(fid, '%s\n', text{i});
    end
    fprintf(fid, '%s', text{end});
end

% close file
fclose(fid);