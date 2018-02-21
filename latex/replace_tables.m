function [new_text] = replace_tables(old_text, tables)

% REPLACE_TABLES  replaces the existing LaTeX tables in old_text, with those in the structure tables.
%
% Prototype:
%     TBD

% initialize the output
new_text = old_text;
% find the existing tables
old_tables = parse_tables(old_text);
old_fields = fieldnames(old_tables);
% reverse sort the tables
final_lines = cellfun(@(x) old_tables.(x).final, old_fields);
[~, ix_sorted] = sort(final_lines, 'descend');
% loop through and replace tables
for i = 1:length(ix_sorted)
    this_key = old_fields{i};
    this_table = old_tables.(this_key);
    if isfield(this_key, tables)
        new_text = [new_text(1:this_table.start), tables.(this_key).text, new_text(this_table.final+1:end)];
    end
end