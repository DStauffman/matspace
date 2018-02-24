function [new_text] = replace_tables(old_text, tables)

% REPLACE_TABLES  replaces the existing LaTeX tables in old_text, with those in the structure tables.
%
% Prototype:
%     TBD

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