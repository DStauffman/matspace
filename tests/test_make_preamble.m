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
            self.verifyTrue(any(strcmp(out,'    \caption{This caption}%')));
            self.verifyTrue(any(strcmp(out,'    \label{tab:this_label}')));
            self.verifyTrue(any(strcmp(out,'    \begin{tabular}{lcc}')));
            self.verifyTrue(any(strcmp(out,'    \small')));
        end

        function test_size(self)
            out = make_preamble(self.caption, self.label, self.cols, 'Size', '\footnotesize');
            self.verifyTrue(any(strcmp(out,'    \footnotesize')));
            self.verifyFalse(any(strcmp(out,'    \small')));
        end

        function test_minipage(self)
            out = make_preamble(self.caption, self.label, self.cols, 'UseMini', true);
            self.verifyTrue(any(strcmp(out,'    \begin{minipage}{\linewidth}')));
            self.verifyTrue(any(strcmp(out,'        \begin{tabular}{lcc}')));
        end

        function test_short_cap(self)
            out = make_preamble(self.caption, self.label, self.cols, 'ShortCap', 'Short cap');
            self.verifyTrue(any(strcmp(out,'    \caption[Short cap]{This caption}%')));
            self.verifyFalse(any(strcmp(out,'    \caption{This caption}%')));
        end

        function test_numbered_false1(self)
            out = make_preamble(self.caption, self.label, self.cols, 'Numbered', false);
            self.verifyTrue(any(strcmp(out,'    \caption*{This caption}%')));
        end

        function test_numbered_false2(self)
            self.verifyError(@() make_preamble(self.caption, self.label, self.cols, 'ShortCap', ...
                'Short cap', 'Numbered', false), '', 'Only numbered captions can have short versions.');
        end
    end
end