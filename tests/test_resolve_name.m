classdef test_resolve_name < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the bin2hex function with the following cases:
    %     Good name
    %     Nominal (Windows)
    %     Nominal (Unix)
    %     String array
    %     Cell array
    %     Different replacements (x3)
    %     Newlines

    properties
        bad_name,
        good_name,
        exp_win,
        exp_unix,
        class_name,
        exp_class_win,
        exp_class_unix,
        exp_no_class_win,
        exp_no_class_unix,
        exp_warning,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.bad_name = "Bad name /\ <>!.png";
            self.good_name = "Good name - Nice job.txt";
            self.exp_win = "Bad name __ __!.png";
            self.exp_unix = "Bad name _\ <>!.png";
            self.class_name = "(U//FOUO) Test file [\deg].txt";
            self.exp_class_win = "(U__FOUO) Test file [_deg].txt";
            self.exp_class_unix = "(U__FOUO) Test file [\deg].txt";
            self.exp_no_class_win = "Test file [_deg].txt";
            self.exp_no_class_unix = "Test file [\deg].txt";
            self.exp_warning = 'matspace:plotting:storeFigIllegalChars';
        end
    end

    methods (Test)
        function test_good_name(self)
            new_name = matspace.plotting.resolve_name(self.good_name);
            self.verifyEqual(new_name, self.good_name);
            new_name = matspace.plotting.resolve_name(char(self.good_name));
            self.verifyEqual(new_name, char(self.good_name));
        end

        function test_mocks_windows(self)
            import matlab.unittest.fixtures.PathFixture
            import matlab.unittest.fixtures.SuppressedWarningsFixture
            self.applyFixture(SuppressedWarningsFixture('MATLAB:dispatcher:nameConflict'));
            self.applyFixture(PathFixture(fullfile(matspace.paths.get_root_dir(), 'mocks', 'force_win')));
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(self.bad_name), self.exp_warning);
            self.verifyEqual(new_name, self.exp_win);
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(char(self.bad_name)), self.exp_warning);
            self.verifyEqual(new_name, char(self.exp_win));
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(self.class_name), self.exp_warning);
            self.verifyEqual(new_name, self.exp_no_class_win);
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(self.class_name, strip_classification=false), self.exp_warning);
            self.verifyEqual(new_name, self.exp_class_win);
        end

        function test_mocks_unix(self)
            import matlab.unittest.fixtures.PathFixture
            import matlab.unittest.fixtures.SuppressedWarningsFixture
            self.applyFixture(SuppressedWarningsFixture('MATLAB:dispatcher:nameConflict'));
            self.applyFixture(PathFixture(fullfile(matspace.paths.get_root_dir(), 'mocks', 'force_unix')));
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(self.bad_name), self.exp_warning);
            self.verifyEqual(new_name, self.exp_unix);
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(char(self.bad_name)), self.exp_warning);
            self.verifyEqual(new_name, char(self.exp_unix));
            new_name = matspace.plotting.resolve_name(self.class_name);
            self.verifyEqual(new_name, self.exp_no_class_unix);
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(self.class_name, strip_classification=false), self.exp_warning);
            self.verifyEqual(new_name, self.exp_class_unix);
        end

        function test_nominal_win(self)
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(self.bad_name, force_win=true), self.exp_warning);
            self.verifyEqual(new_name, self.exp_win);
        end
    
        function test_nominal_unix(self)
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(self.bad_name, force_win=false), self.exp_warning);
            self.verifyEqual(new_name, self.exp_unix);
        end

        function test_string_array(self)
            new_names = self.verifyWarning(@() matspace.plotting.resolve_name([self.good_name, self.bad_name]), self.exp_warning);
            if ispc
                exp = [self.good_name, self.exp_win];
            else
                exp = [self.good_name, self.exp_unix];
            end
            self.verifyEqual(new_names, exp);
        end

        function test_cell_array(self)
            new_names = self.verifyWarning(@() matspace.plotting.resolve_name({char(self.good_name), char(self.bad_name)}), self.exp_warning);
            if ispc
                exp = {char(self.good_name), char(self.exp_win)};
            else
                exp = {char(self.good_name), char(self.exp_unix)};
            end
            self.verifyEqual(new_names, exp);
        end
    
        function test_different_replacements(self)
            bad_name = 'new <>:"/\|?*text';
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(bad_name, force_win=true, rep_token='X'), self.exp_warning);
            self.verifyEqual(new_name, 'new XXXXXXXXXtext');
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(bad_name, force_win=true, rep_token=''), self.exp_warning);
            self.verifyEqual(new_name, 'new text');
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(string(bad_name), force_win=true, rep_token="YY"), self.exp_warning);
            self.verifyEqual(new_name, "new YYYYYYYYYYYYYYYYYYtext");
        end
    
        function test_newlines(self)
            bad_name = "Hello" + newline + "World.jpg";
            new_name = self.verifyWarning(@() matspace.plotting.resolve_name(bad_name), self.exp_warning);
            self.verifyEqual(new_name, "Hello_World.jpg");
        end
    end
end