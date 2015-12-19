function moves = find_moves(position)

% FIND_MOVES finds the best current move.
%
% Currently this function is only trying to find a win in one move situation
%
% Input:
%     position : (6x6) current board position of all pieces
%
% Output:
%     moves         : (struct) potential moves
%         .white    : (struct) possible white moves
%             .x    : (1xN) vector of x locations on board [enum]
%             .y    : (1xN) vector of y locations on board [enum]
%             .quad : (1xN) vector of quadrants to rotate [enum]
%             .dir  : (1xN) vector of directions to spin [enum]
%             .pwr  : (1xN) vector of move power [num]
%         .black    : (struct) possible black moves
%             .x    : (1xN) vector of x locations on board [enum]
%             .y    : (1xN) vector of y locations on board [enum]
%             .quad : (1xN) vector of quadrants to rotate [enum]
%             .dir  : (1xN) vector of directions to spin [enum]
%             .pwr  : (1xN) vector of move power [num]
%
% Prototype:
%     position = reshape([0 0 0 0 0 0 0 1 0 1 1 1 zeros(1,24)],6,6);
%     moves    = find_moves(position);
%
% Written by David Stauffer in Feb 2010.

position = position(:);

% get WIN state
[PLAYER,WIN] = get_static_globals({'PLAYER','WIN'});

% get all possible rotation to win states
ONE_OFF = [...
    rotate_board(WIN,1,0),...
    rotate_board(WIN,2,0),...
    rotate_board(WIN,3,0),...
    rotate_board(WIN,4,0),...
    rotate_board(WIN,1,1),...
    rotate_board(WIN,2,1),...
    rotate_board(WIN,3,1),...
    rotate_board(WIN,4,1)];

% find any board combinations that have 4 of the pieces needed to win in one move, first:
% repeat position matrix to match all possible winning combinations
pos_big = repmat(position,1,size(ONE_OFF,2));

% cross reference two matrices with element-wise multiplication
test = pos_big .* ONE_OFF;

% find score
score = sum(test,1);

% find white and black rotate to win moves
rot_white = find(score >=  5);
rot_black = find(score <= -5);

% find white and black one off potentials
white = find(score >=  4 & score <  5);
black = find(score <= -4 & score > -5);

% see if the remaining piece is an open square
if ~isempty(white)
    pos_white = ONE_OFF(:,white);
    needed    = xor(pos_white,repmat(position,1,length(white)));
    free      = and(needed,repmat(~position,1,length(white)));
    ix_white  = white(any(free));
else
    ix_white  = [];
end
if ~isempty(black)
    pos_black = ONE_OFF(:,black);
    needed    = xor(pos_black,repmat(position,1,length(black)));
    free      = and(needed,repmat(~position,1,length(black)));
    ix_black  = black(any(free));
else
    ix_black  = [];
end

% find winning moves
% placement winning moves
[xwp,ywp,qwp,dwp] = get_move_from_one_off(position,ix_white,ONE_OFF);
[xbp,ybp,qbp,dbp] = get_move_from_one_off(position,ix_black,ONE_OFF);
% rotation only winning moves
[xwr,ywr,qwr,dwr] = get_move_from_one_off(position,rot_white,ONE_OFF);
[xbr,ybr,qbr,dbr] = get_move_from_one_off(position,rot_black,ONE_OFF);

% Add moves that are just a place anywhere and rotate to win
empty = find(position == PLAYER.none);
% white
pos_wr = repmat(empty,1,length(qwr));
xwr = mod(pos_wr(:)',6);
xwr(xwr == 0) = 6;
ywr = ceil(pos_wr(:)'/6);
qwr = repmat(qwr,length(empty),1);
qwr = qwr(:)';
dwr = repmat(dwr,length(empty),1);
dwr = dwr(:)';
% black
pos_br = repmat(empty,1,length(qbr));
xbr = mod(pos_br(:)',6);
xbr(xbr == 0) = 6;
ybr = ceil(pos_br(:)'/6);
qbr = repmat(qbr,length(empty),1);
qbr = qbr(:)';
dbr = repmat(dbr,length(empty),1);
dbr = dbr(:)';

% store output:
% white win moves
moves.white.x    = [xwp, xwr];
moves.white.y    = [ywp, ywr];
moves.white.quad = [qwp, qwr];
moves.white.dir  = [dwp, dwr];
moves.white.pwr  = 5*ones(size(moves.white.x));
% mark moves that are really a tie, instead of a win
moves.white.pwr(ismember([qwp+4*dwp,qwr+4*dwr],qbr+4*dbr)) = nan;
% resort ties at end
moves.white = resort_moves(moves.white);
% black win moves
moves.black.x    = [xbp, xbr];
moves.black.y    = [ybp, ybr];
moves.black.quad = [qbp, qbr];
moves.black.dir  = [dbp, dbr];
moves.black.pwr  = 5*ones(size(moves.black.x));
% mark moves that are really a tie, instead of a win
moves.black.pwr(ismember([qbp+4*dbp,qbr+4*dbr],qwr+4*dwr)) = nan;
% resort ties at end
moves.black = resort_moves(moves.black);


%% Subfunction 1
function [x,y,quad,dir] = get_move_from_one_off(position,ix,ONE_OFF)

% GET_MOVE_FROM_ONE_OFF turns the index into an X, Y, QUAD, and DIR

% get static globals
WIN = get_static_globals({'WIN'});

% preallocate x & y to NaNs in case the winning move is just a rotation
x = nan(size(ix));
y = x;

% find missing piece
pos_ix = and(xor(repmat(abs(position),1,length(ix)),ONE_OFF(:,ix)),ONE_OFF(:,ix));
any_ix = any(pos_ix);

% pull out element number
pos           = mod(find(pos_ix)',size(WIN,1));
pos(pos == 0) = size(WIN,1);
% convert element number to x & y coordinates
x(any_ix) = mod(pos,6);
x(x==0)   = 6;
y(any_ix) = ceil(pos/6);

% get quadrant and rotation number
% based on permutations of first quads 1,2,3,4, second left,right;
% then redo this in the opposite order
num = ceil(ix/size(WIN,2));

% pull out rotation direction
dir = zeros(size(ix));
dir(num < 5) = 1;

% pull out quadrant number
quad = mod(num,4);
quad(quad == 0) = 4;


%% Subfunction 2
function [moves_new] = resort_moves(moves_old)

% RESORT_MOVES  sorts the moves based on the pwr, such that ties are at the end

[sort_pwr,sort_ix] = sort(moves_old.pwr);

moves_new.x    = moves_old.x(sort_ix);
moves_new.y    = moves_old.y(sort_ix);
moves_new.quad = moves_old.quad(sort_ix);
moves_new.dir  = moves_old.dir(sort_ix);
moves_new.pwr  = moves_old.pwr(sort_ix);