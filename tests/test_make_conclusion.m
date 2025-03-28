classdef test_make_conclusion < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the make_conclusion function with the following cases:
    %     Nominal
    %     Minipage

    methods(Test)
        function test_nominal(self)
            out = matspace.latex.make_conclusion();
            self.verifyEqual(out, ["        \bottomrule"; "    \end{tabular}"; "\end{table}"; ""]);
        end

        function test_minipage(self)
            out = matspace.latex.make_conclusion(true);
            self.verifyEqual(out, ["            \bottomrule"; "        \end{tabular}"; ...
                "    \end{minipage}"; "\end{table}"; ""]);
        end
    end
end