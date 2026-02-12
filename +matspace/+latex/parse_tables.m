function [tables] = parse_tables(text)

% PARSE_TABLES  parses the given text for the location of any LaTeX tables.
%
% Input:
%     text : Text to parse
%
% Output:
%     tables : struct with information about any table that are found
%
% Prototype:
%     style_guide = fullfile(matspace.paths.get_root_dir(), 'docs', 'Style_Guide', 'Style_Guide.tex');
%     text = matspace.utils.read_text_file(style_guide);
%     tables = matspace.latex.parse_tables(text);
%
% See Also:
%     matspace.latex.replace_tables
%
% Change Log:
%     1.  Ported from Python to Matlab by David C. Stauffer in January 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

arguments
    text string {mustBeVector}
end
text = convertCharsToStrings(text);

% initialize output
tables = struct('name', {}, 'start', {}, 'final', {}, 'text', {});
% initialize modes
within = false;
% loop through text
for ix = 1:length(text)
    this_line = text{ix};
    if ~within
        % start of table
        if strcmp(this_line,'\begin{table}[H]')
            this_start = ix;
            within = true;
        end
    else
        % label tag
        temp = strfind(this_line, '\label{tab:');
        if ~isempty(temp)
            table_end = strfind(this_line, '}');
            assert(~isempty(table_end));
            this_name = this_line(temp+length('\label{tab:'):table_end-1);
            continue
        end
        % end of table
        if contains(this_line, '\end{table}')
            this_final = ix;
            within = false;
            this_text = text(this_start:this_final);
            assert(~isfield(tables, this_name));
            tables(end+1) = struct('name', ['tab:',this_name], 'start', this_start, ...
                'final', this_final, 'text', this_text); %#ok<AGROW>
        end
    end
end