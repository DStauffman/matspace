function read_bit_stream(fid,nlines,reset)

% READ_BIT_STREAM  reads in a stream of bits and displays potential outputs.
%
% Summary:
%     Designed as a debug tool for use exploring unknown binary data.
%
% Input:
%     fid    : (scalar) file identifier [numeric]
%     nlines : (scalar) number of 64 bit fields to read [numeric]
%     reset  : (true/false) flag to go back to the original place in the file [bool]
%
% Output:
%     (NONE) - displays results to the command window
%
% Prototype:
%     fid    = fopen('test_file.bin','r','ieee-be');
%     nlines = 10;
%     reset  = false;
%     read_bit_stream(fid,nlines,reset);
%     fclose(fid);
%
% Change Log:
%     1.  Written by David C. Stauffer in May 2009.

%% Read bit stream
for i = 1:nlines
    % read as bit stream
    bin_str = zeros(1,64);
    % check for end of file
    fread(fid,1,'bit8');
    if feof(fid)
        disp('The end of the file was reached.');
        break
    else
        fseek(fid,-1,'cof');
    end
    for j = 1:64
        bin_str(j) = dec2bin(abs(fread(fid,1,'bit1')),1);
    end
    fseek(fid,-8,'cof');
    % read as uint32
    uin1 = fread(fid,1,'uint32');
    uin2 = fread(fid,1,'uint32');
    fseek(fid,-8,'cof');
    % read as int32
    int1 = fread(fid,1,'int32');
    int2 = fread(fid,1,'int32');
    fseek(fid,-8,'cof');
    % read as float32
    flt1 = fread(fid,1,'float32');
    flt2 = fread(fid,1,'float32');
    fseek(fid,-8,'cof');
    % read as double
    dble = fread(fid,1,'double');
    % display results
    disp([char(bin_str(1:32)),' ',char(bin_str(33:64)),' = ']);
    fprintf('uint32 = ');
    disp([uin1 uin2]);
    fprintf('int32  = ');
    disp([int1 int2]);
    fprintf('float  = ');
    disp([flt1 flt2]);
    fprintf('double = ');
    disp(dble);
end
if reset
    fseek(fid,-8*nlines,'cof');
end