function [a2r] = ARCSEC2RAD()

% ARCSEC2RAD  returns a constant scalar to convert arcseconds to radians.

import matspace.const.DEG2RAD
import matspace.const.ONE_HOUR

a2r = 1 / ONE_HOUR * DEG2RAD;