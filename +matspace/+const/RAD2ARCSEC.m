function [r2a] = RAD2ARCSEC()

% RAD2ARCSEC  returns a constant scalar to convert radians to arcseconds.

import matspace.const.ONE_HOUR
import matspace.const.RAD2DEG

r2a = ONE_HOUR * RAD2DEG;