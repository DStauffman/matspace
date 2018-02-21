function [tables] = parse_tables(text)

% PARSE_TABLES  parses the given text for the location of any LaTeX tables.

% initialize output
tables = struct();
% initialize modes
within = false;
% loop through text
for ix = 1:length(text)
    this_line = text{ix};
    if ~within
        if strcmp(this_line,'\\begin{table}[H]')
            this_start = ix;
            within = true;
        end
    else
        temp = strfind(this_line, '\\label{tab:');
        if ~isempty(temp)
            table_end = strfind(this_line, '}');
            assert(~isempty(table_end));
            this_name = this_line(temp+length('\\label{tab:'):table_end-1);
            continue
        end
        temp = strfind(this_line, '\\end{table}');
        if ~isempty(temp)
            this_final = ix;
            within = false;
            this_text = text(this_start:this_final);
            assert(~isfield(tables, this_name));
            tables.(this_name) = struct('name', ['tab:',this_name], 'start', this_start, ...
                'final', this_final, 'text', this_text);
        end
    end
end