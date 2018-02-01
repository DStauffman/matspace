function [out] = make_preamble(caption, label, cols, varargin)

% MAKE_PREAMBLE  writes the table header and preamble.
%
% Input
%     caption : (row) string specifying the table caption
%     label : (row) string specifying the reference label for table
%     cols : (row) string specifying the LaTeX string describing columns
%     size : |opt| (row) string specifying the size of the text within the table, default is '\\small',
%     from {'\\tiny', '\\scriptsize', '\\footnotesize', '\\small', '\\normalsize', '\\large',
%           '\\Large', '\\LARGE', '\\huge', '\\Huge'}
%     use_mini : (scalar) true/false flag for whether to build the table as a minipage or not [bool], default is false
%     short_cap : |opt| (row) string, if not empty, used as optional caption argument for List of Tables caption, default is ""
%
% Output
%     out : (1xN) of string, LaTeX text to build the table header, where each entry in the list is a row of text in the document.
%
% Prototype
%     out = make_preamble('Table Caption', 'tab:this_label', 'lcc');
%     disp(out);
%     % gives: "\\begin{table}[H]"    "    \\small"    "    \\centering"    "    \\caption{Table Caption}%" ...
%
% Change Log
%     1.  Ported from Python to Matlab by David C. Stauffer in January 2018.

%% Parse Inputs
% create parser
p = inputParser;
% create some validation functions
func_size_is_valid = @(x) any(strcmp(x, {'\\tiny', '\\scriptsize', '\\footnotesize', '\\small', '\\normalsize',...
    '\\large', '\\Large', '\\LARGE', '\\huge', '\\Huge'}));
% set options
addRequired(p, 'Caption', @ischar);
addRequired(p, 'Label', @ischar);
addRequired(p, 'Cols', @ischar);
addParameter(p, 'Size', '\\small', func_size_is_valid);
addParameter(p, 'UseMini', false, @islogical);
addParameter(p, 'ShortCap', '', @ischar);
addParameter(p, 'Numbered', true, @islogical);
% do parse
parse(p, caption, label, cols, varargin{:});
% create some convenient aliases
size      = p.Results.Size;
use_mini  = p.Results.UseMini;
short_cap = p.Results.ShortCap;
numbered  = p.Results.Numbered;

%% Process
% create caption string
if isempty(short_cap)
    if numbered
        cap_str = ['    \\caption{', caption '}%'];
    else
        cap_str = ['    \\caption*{', caption, '}%'];
    end
else
    assert(numbered, 'Only numbered captions can have short versions.');
    cap_str = ['    \\caption[', short_cap, ']{', caption, '}%'];
end
% build table based on minipage or not
if ~use_mini
    out = string({'\\begin{table}[H]', ['    ',size], '    \\centering', cap_str, ...
        ['    \\label{', label, '}'], ['    \\begin{tabular}{', cols, '}'], '        \\toprule'});
else
    out = string({'\\begin{table}[H]', ['    ',size], '    \\centering', cap_str, ...
        ['    \\label{', label, '}'], '    \\begin{minipage}{\\linewidth}', '        \\centering', ...
        ['        \\begin{tabular}{', cols, '}'], '            \\toprule'});
end