classdef test_setup_dir < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the setup_dir function with the following cases:
    %     Empty string
    %     Create folder
    %     Nested folder
    %     Clean-up folder
    %     CLean-up partial
    %     Clean-up recursively
    %     String input

    properties
        filename,
        folder,
        subdir,
        subfile,
        text,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.folder   = fullfile(matspace.paths.get_tests_dir(), 'temp_dir');
            self.subdir   = fullfile(matspace.paths.get_tests_dir(), 'temp_dir', 'temp_dir2');
            self.filename = fullfile(self.folder, 'temp_file.txt');
            self.subfile  = fullfile(self.subdir, 'temp_file.txt');
            self.text     = 'Hello, World!\n';
        end
    end

    methods (TestMethodTeardown)
        function teardown(self)
            if isfile(self.filename)
                delete(self.filename);
            end
            if isfile(self.subfile)
                delete(self.subfile);
            end
            if isfolder(self.subdir)
                rmdir(self.subdir);
            end
            if isfolder(self.folder)
                rmdir(self.folder);
            end
        end
    end

    methods (Test)
        function test_empty(~)
            matspace.utils.setup_dir('');
        end

        function test_nominal(self)
            self.verifyFalse(isfolder(self.folder));
            matspace.utils.setup_dir(self.folder);
            self.verifyTrue(isfolder(self.folder));
        end

        function test_nested_folder(self)
            self.verifyFalse(isfolder(self.subdir));
            matspace.utils.setup_dir(self.subdir);
            self.verifyTrue(isfolder(self.subdir));
        end

        function test_clean_up_folder(self)
            matspace.utils.setup_dir(self.folder);
            matspace.utils.write_text_file(self.filename, self.text);
            self.verifyTrue(isfile(self.filename));
            matspace.utils.setup_dir(self.folder);
            self.verifyFalse(isfile(self.filename));
        end

        function test_clean_up_partial(self)
            matspace.utils.setup_dir(self.folder);
            matspace.utils.write_text_file(self.filename, '');
            matspace.utils.setup_dir(self.subdir);
            matspace.utils.write_text_file(self.subfile, '');
            self.verifyTrue(isfile(self.filename));
            self.verifyTrue(isfile(self.subfile));
            matspace.utils.setup_dir(self.folder, false);
            self.verifyFalse(isfile(self.filename));
            self.verifyTrue(isfile(self.subfile));
        end

        function test_clean_up_recursively(self)
            matspace.utils.setup_dir(self.subdir);
            matspace.utils.write_text_file(self.subfile, self.text);
            self.verifyTrue(isfile(self.subfile));
            matspace.utils.setup_dir(self.folder, true);
            self.verifyFalse(isfile(self.subfile));
            self.verifyFalse(isfolder(self.subdir));
        end

        function test_dont_wipe(self)
            matspace.utils.setup_dir(self.subdir);
            matspace.utils.write_text_file(self.subfile, self.text);
            matspace.utils.write_text_file(self.filename, self.text);
            self.verifyTrue(isfile(self.subfile));
            self.verifyTrue(isfile(self.filename));
            matspace.utils.setup_dir(self.folder, false, false);
            self.verifyTrue(isfile(self.subfile));
            self.verifyTrue(isfile(self.filename));
        end

        function test_string(self)
            str = string(self.folder);
            self.verifyFalse(isfolder(self.folder));
            matspace.utils.setup_dir(str);
            self.verifyTrue(isfolder(self.folder));
        end
        
        function test_string_array(self)
            str_array = string({self.folder, self.subdir});
            if verLessThan('matlab', '9.8')  % R2020A
                exp_error = 'MATLAB:functionValidation:NotVector';
            else
                exp_error = 'MATLAB:validation:IncompatibleSize';
            end
            self.verifyError(@() matspace.utils.setup_dir(str_array), exp_error);
        end
    end
end