function [OPTIONS] = create_options()

% CREATE_OPTIONS  creates the default options, and serves as guide for the possible values

% load previous game
opt = cell(3,1);
opt{1} = 'Yes';
opt{2} = 'No';
opt{3} = 'Ask';
OPTIONS.load_previous_game = opt{1};

% player names
OPTIONS.name_white = 'Player 1';
OPTIONS.name_black = 'Player 2';

% winning moves
OPTIONS.plot_winning_moves = true;

% save options for later
save('options.mat','OPTIONS');