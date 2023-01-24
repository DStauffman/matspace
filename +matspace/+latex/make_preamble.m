function [out] = make_preamble(caption, label, cols, kwargs)

% MAKE_PREAMBLE  writes the table header and preamble.
%
% Input:
%     caption : (row) string specifying the table caption
%     label : (row) string specifying the reference label for table
%     cols : (row) string specifying the LaTeX string describing columns
%     size : |opt| (row) string specifying the size of the text within the table, default is '\small',
%     from {'\tiny', '\scriptsize', '\footnotesize', '\small', '\normalsize', '\large',
%           '\Large', '\LARGE', '\huge', '\Huge'}
%     use_mini : (scalar) true/false flag for whether to build the table as a minipage or not [bool], default is false
%     short_cap : |opt| (row) string, if not empty, used as optional caption argument for List of Tables caption, default is ""
%
% Output:
%     out : (1xN) of string, LaTeX text to build the table header, where each entry in the list is a row of text in the document.
%
% Prototype:
%     out = matspace.latex.make_preamble('Table Caption', 'tab:this_label', 'lcc');
%     assert(all(out(1:4) == ["\begin{table}[H]"; "    \small"; "    \centering"; "    \caption{Table Caption}%"]));
%
% Change Log:
%     1.  Ported from Python to Matlab by David C. Stauffer in January 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

%% Arguments
arguments
    caption (1, :) char
    label (1, :) char
    cols (1, :) char
    kwargs.Size (1, :) char {mustBeMember(kwargs.Size, {'\tiny', '\scriptsize', '\footnotesize', '\small', '\normalsize',...
    '\large', '\Large', '\LARGE', '\huge', '\Huge'})} = '\small';
    kwargs.UseMini (1, 1) logical = false;
    kwargs.ShortCap (1, :) char = '';
    kwargs.Numbered (1, 1) logical = true;
end

% create some convenient aliases
size      = kwargs.Size;
use_mini  = kwargs.UseMini;
short_cap = kwargs.ShortCap;
numbered  = kwargs.Numbered;

%% Process
% create caption string
if isempty(short_cap)
    if numbered
        cap_str = ['    \caption{', caption '}%'];
    else
        cap_str = ['    \caption*{', caption, '}%'];
    end
else
    assert(numbered, 'Only numbered captions can have short versions.');
    cap_str = ['    \caption[', short_cap, ']{', caption, '}%'];
end
% build table based on minipage or not
if ~use_mini
    out = string({'\begin{table}[H]'; ['    ',size]; '    \centering'; cap_str; ...
        ['    \label{', label, '}']; ['    \begin{tabular}{', cols, '}']; '        \toprule'});
else
    out = string({'\begin{table}[H]'; ['    ',size]; '    \centering'; cap_str; ...
        ['    \label{', label, '}']; '    \begin{minipage}{\linewidth}'; '        \centering'; ...
        ['        \begin{tabular}{', cols, '}']; '            \toprule'});
end