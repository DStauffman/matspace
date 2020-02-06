function [] = write_text_file(filename, text)

% check if simple character array and if so, convert to string array

% open file for writing
fid = fopen(filename, 'wt');
if fid == -1
    error('dstauffman:BadFileOpen', 'Unable to open "%s" for writing.', filename);
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