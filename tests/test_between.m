classdef test_between < matlab.unittest.TestCase %#ok<*PROP>
    
    % Tests the between function with the following cases:
    %     Default behavior
    %     four arguments
    %     matrix scalar scalar
    %     matrix matrix scalar
    %     matrix scalar matrix
    %     scalar closed bounds
    %     bad number arguments (should error)
    %     bad boundaries (should error)
    
    methods (Test)
        function test_default(self)
            self.verifyTrue(between(5,4,6));
            self.verifyFalse(between(5,5,6));
            self.verifyFalse(between(5,4,5));
        end
        
        function test_four_args(self)
            % All four combinations specified explicitly:
            % (a,b)  (a,b] [a,b) [a,b]
            a = 0;
            b = 10;
            
            self.verifyTrue(between(0,a,b,[1 0]));
            self.verifyTrue(between(0,a,b,[1 1]));
            self.verifyFalse(between(0,a,b,[0 0]));
            self.verifyFalse(between(0,a,b,[0 1]));
            
            self.verifyFalse(between(10,a,b,[1 0]));
            self.verifyTrue(between(10,a,b,[1 1]));
            self.verifyFalse(between(10,a,b,[0 0]));
            self.verifyTrue(between(10,a,b,[0 1]));
        end
        
        function test_matrix_scalar_scalar(self)
            %      8     1     6
            %      3     5     7
            %      4     9     2
            c = magic(3);
            expectedResult = logical([0 0 1; 0 1 0; 1 0 0]);
            self.verifyEqual(between(c,3,7),expectedResult);
        end
        
        function test_matrix_matrix_scalar(self)
            %      8     1     6
            %      3     5     7
            %      4     9     2
            c = magic(3);
            expectedResult = logical([1 0 1; 1 1 1; 1 0 0]);
            self.verifyEqual(between(c,3+eye(3),8,[1 1]),expectedResult);
        end
        
        function test_matrix_scalar_matrix(self)
            %      8     1     6
            %      3     5     7
            %      4     9     2
            c = magic(3);
            expectedResult = logical([0 0 1; 1 1 1; 1 0 0]);
            self.verifyEqual(between(c,2,6+eye,[0 1]),expectedResult);
        end
        
        function test_scalar_closed_bound(self)
            self.verifyTrue(between(6,5,6,1));
            self.verifyFalse(between(6,5,6,0));
        end
        
        function test_bad_arg_list(self)
            self.verifyError(@() between(1,2), 'dstauffman:between:BadArgList');
        end
        
        function test_bad_boundaries(self)
            self.verifyError(@() between(1,2,3,[1 1 1]),'dstauffman:between:BadBoundarySpecification');
        end
    end
end