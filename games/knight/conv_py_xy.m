function [ix] = conv_py_xy(board_size, x, y)

ix = sub2ind(board_size, x+1, y+1);