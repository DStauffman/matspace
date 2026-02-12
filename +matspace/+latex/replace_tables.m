function [new_text] = replace_tables(old_text, tables)

% REPLACE_TABLES  replaces the existing LaTeX tables in old_text, with those in the structure tables.
%
% Input:
%     old_text : Text that contains latex tables
%     tables : struct with information about any table that are found
%
% Output:
%     new_Text : Text with table values replaced
%
% Prototype:
%     style_guide = fullfile(matspace.paths.get_root_dir(), 'docs', 'Style_Guide', 'Style_Guide.tex');
%     old_text = matspace.utils.read_text_file(style_guide);
%     tables = matspace.latex.parse_tables(old_text);
%     new_text = matspace.latex.replace_tables(old_text, tables);
%
% See Also:
%     matspace.latex.parse_tables
%
% Change Log:
%     1.  Ported from Python to Matlab by David C. Stauffer in January 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

arguments
    old_text string {mustBeVector}
    tables struct
end

% Imports
import matspace.latex.parse_tables

% initialize the output
new_text = old_text;
% find the existing tables
old_tables = parse_tables(old_text);
% reverse sort the tables
[~, ix_sorted] = sort([old_tables(:).final], 'descend');
% loop through and replace tables
for ix = ix_sorted
    this_table = old_tables(ix);
    ix_table = find(arrayfun(@(x) strcmp(this_table.name, x.name), tables), 1, 'first');
    if ~isempty(ix_table)
        new_text = [new_text(1:this_table.start-1); tables(ix_table(1)).text; new_text(this_table.final+1:end)];
    end
end