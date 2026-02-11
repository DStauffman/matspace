% Checks code for mlint warnings

% folder information
package_root = matspace.paths.get_root_dir();
library_root = fullfile(package_root, '+matspace');

% find all files
all_files = dir(fullfile(library_root, '**', '*.m'));

total_funcs = 0;
found_probs = 0;

% run code checks
for i = 1:length(all_files)
    this_file = fullfile(all_files(i).folder, all_files(i).name);
    info = checkcode(this_file, '-struct');
    if ~isempty(info)
        total_funcs = total_funcs + 1;
        fprintf(1, 'Checking <a href="matlab: matlab.desktop.editor.openAndGoToLine(''%s'', %d);">%s</a>\n', ...
            this_file, info(1).line, this_file);
        for j = 1:length(info)
            found_probs = found_probs + 1;
            this_note = info(j);
            fprintf(1, '    Line %i, %s\n', this_note.line, this_note.message);
        end
    end
end

if total_funcs > 0
    fprintf(1, '\n%i files contained a total of %i issues.\n', total_funcs, found_probs);
    throw(MException('matspace:codeChecks', 'Code checks found problems in the source.'));
end