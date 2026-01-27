% Example script for generating plots using the matspace library.
%
% Change Log:
%     1.  Written by David C. Stauffer in May 2015.
%     2.  Translated into Matlab by David C. Stauffer in January 2026.

%% Create some fake data
% random data
data = rand(10, 10);
% normalize the random data
data(:) = matspace.utils.unit(data, 1);
% labels for the plot
labels = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
% make some symmetric data
sym = data;
num = size(sym, 1);
for j = 1:num
    for i = 1:num
        if i == j
            sym(i, j) = 1;
        elseif i > j
            sym(i, j) = data(j, i);
        else
            % no-op
        end
    end
end
% create opts
opts = matspace.plotting.Opts();

% %% Create the plots
fig1 = matspace.plotting.plot_correlation_matrix(data, labels, opts=opts);
fig2 = matspace.plotting.plot_correlation_matrix(sym, labels, opts=opts);
