classdef test_load_check < matlab.unittest.TestCase %#ok<*PROP>

% Tests the load_check function with the following cases:
%     Nominal, load whole file
%     Ask for specific variables
%     Ask for some extra variables that don't exist
%     Call with mismatched arguments (should error)

    properties
        x,
        y,
        filename,
        out,
    end

    methods (TestClassSetup)
        function initialize(self)
            self.x = 5;
            self.y = 2;
            self.filename = 'temp.mat';
            self.out = struct('x', self.x, 'y', self.y);
            x = self.x;
            y = self.y;
            save(self.filename, 'x', 'y');
        end
    end

    methods (TestClassTeardown)
        function delete_file(self)
            if exist(self.filename, 'file')
                delete(self.filename);
            end
        end
    end

    methods (Test)
        function test_no_args(self)
            out = matspace.utils.load_check(self.filename);
            self.verifyEqual(out, self.out);
        end

        function test_with_args(self)
            [x, y] = matspace.utils.load_check(self.filename, 'x', 'y');
            self.verifyEqual(x, self.x);
            self.verifyEqual(y, self.y);
        end

        function test_extra_args(self)
            [y, z] = self.verifyWarning(@() matspace.utils.load_check(self.filename, 'y', 'z'), 'MATLAB:load:variableNotFound');
            self.verifyEqual(y, self.y);
            self.verifyEmpty(z);
        end

        function test_mismatch_args(self)
            self.verifyError(@() matspace.utils.load_check(self.filename, 'x', 'y', 'z'), 'load_check:IOMismatch');
        end
    end
end