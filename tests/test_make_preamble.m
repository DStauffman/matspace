classdef test_make_preamble < matlab.unittest.TestCase %#ok<*PROP>
    
    % Tests the make_preamble function with the following cases:
    %     Nominal
    %     Different size
    %     Minipage
    %     Short caption
    
    properties
        caption,
        label,
        cols
    end
    
    methods(TestMethodSetup)
        function initialize(self)
            self.caption = 'This caption';
            self.label   = 'tab:this_label';
            self.cols    = 'lcc';
        end
    end

    methods(Test)
        function test_nominal(self)
            out = make_preamble(self.caption, self.label, self.cols);
            self.assertIn('    \\caption{This caption}%', out);
            self.assertIn('    \\label{tab:this_label}', out);
            self.assertIn('    \\begin{tabular}{lcc}', out);
            self.assertIn('    \\small', out);
        end

        function test_size(self)
        out = make_preamble(self.caption, self.label, self.cols, size='\\footnotesize')
        self.assertIn('    \\footnotesize', out)
        self.assertNotIn('    \\small', out)
        end

        function test_minipage(self)
        out = make_preamble(self.caption, self.label, self.cols, use_mini=True)
        self.assertIn('    \\begin{minipage}{\\linewidth}', out)
        self.assertIn('        \\begin{tabular}{lcc}', out)
        end

        function test_short_cap(self)
        out = make_preamble(self.caption, self.label, self.cols, short_cap='Short cap')
        self.assertIn('    \caption[Short cap]{This caption}%', out)
        self.assertNotIn('    \caption{This caption}%', out)
        end

        function test_numbered_false1(self)
        out = make_preamble(self.caption, self.label, self.cols, numbered=False)
        self.assertIn('    \\caption*{This caption}%', out)
        end

        function test_numbered_false2(self)
        with self.assertRaises(AssertionError):
            make_preamble(self.caption, self.label, self.cols, short_cap='Short cap', numbered=False)
        end
    end
end