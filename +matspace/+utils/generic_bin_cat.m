function generic_bin_cat(savename,location,filenums)

% GENERIC_BIN_CAT  concatenates binary files with numbered filenames.
%
% Summary:
%     This function reads a series of numbered binary files specified by
%     the input and writes the data into one output file thus creating a concatenated
%     file with all the data from the input files.
%
% Input:
%                             where N = number of files
%     savename        : (row) full file path of the desired output file [char]
%     location        : (row) directory and filename of desired input files [char]
%     filenums        : (Nx1) file numbers of files to be combined, in the desired order [num]
%     /input_###.bin  : (file) generic binary file with 3 digit numbering scheme
%                             'input_' or the appropriate file name should be part of location
%
% Output:
%     /output.bin     : (file) generic binary file with 3 digit numbering scheme
%                              'output' file name is specified by savename
%
% Prototype:
%     % make input files
%     fid1 = fopen('input_001.bin','w','ieee-be');
%     fwrite(fid1,ones(5,1),'uint32');
%     fclose(fid1);
%     fid2 = fopen('input_002.bin','w','ieee-be');
%     fwrite(fid1,ones(5,1)*2,'uint32');
%     fclose(fid2);
%     fid3 = fopen('input_003.bin','w','ieee-be');
%     fwrite(fid1,ones(5,1)*3,'uint32');
%     fclose(fid3);
%
%     % setup args
%     savename = 'catbin.bin';
%     location = [pwd,filesep,'input_'];
%     filenums = 1:3;
%
%     % execute concatenation
%     matspace.utils.generic_bin_cat(savename,location,filenums)
%
%     % confirm execution
%     fid4 = fopen(savename,'r','ieee-be');
%     catdata = fread(fid4,inf,'uint32');
%     fclose(fid4);
%     disp(catdata);
%
%     % clean up files
%     delete('input_001.bin');
%     delete('input_002.bin');
%     delete('input_003.bin');
%     delete('catbin.bin');
%
% Change Log:
%     1.  Written by Matt Beck in April 2010.
%     2.  Updated by David C. Stauffer in Apr 2013 to distinguish between files it can't find and
%         files it can't read.
%     3.  Incorporated by David C. Stauffer into matspace in Nov 2016.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

% display status
disp(['Starting "', savename,'" concatenation ...']);
% open output file
fid = fopen(savename,'w','ieee-be');
% throw warning if the file open has problems, else continue processing
if fid == -1
    warning('GARSE:openBinFiles','Unable to open "%s" binary file.',savename);
else
    % loop through files
    for i = 1:length(filenums)
        % alias this file
        this_file = [location,num2str(filenums(i),'%03i'),'.bin'];
        if ~exist(this_file,'file')
            % throw warning if file doesn't exist
            warning('matspace:findBinFiles','\nUnable to find "%s" binary file.',this_file);
        else
            % display progress
            fprintf([' Appending file ',num2str(filenums(i)),' ...']);
            % open file
            tempfid = fopen(this_file,'r','ieee-be');
            if tempfid == -1
                % throw warning if unable to open
                warning('matspace:openBinFiles','\nUnable to open "%s" binary file.',this_file);
            else
                % read input file data
                temp = fread(tempfid,inf,'*uint8');
                % close input file
                fclose(tempfid);
                % write data to output file
                fwrite(fid,temp,'uint8');
                fprintf(' done. \n');
            end
        end
    end
    % close output file
    fclose(fid);
    disp('... done.');
end