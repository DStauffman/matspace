function cor = cor_prn(prn1,prn2,shift,form)

% COR_PRN  is the correlation of PRN codes with an optional shift.
%
% Input:
%     prn1  : psuedo-random number stream 1
%     prn2  : psuedo-random number stream 2
%     shift : bit shift between codes
%     form  : 'zero-one' or 'one-one'
%
% Output:
%     cor   : correlation
%
% Prototype:
%     prn   = generate_prn(1);
%     shift = 0:1022;
%     cor   = cor_prn(prn,prn,shift,'zero-one');
%
% See Also:
%     generate_prn, get_prn_bits
%
% Notes:
%     1.  Calling with the same PRN twice will give the auto-correlation.
%
% Change Log:
%     1.  Written by David C. Stauffer in Jan 2009.
%     2.  Moved to gps subfolder in Feb 2009.
%     3.  Incorporated into DStauffman Matlab tools in Nov 2016.

switch form
    case 'zero-one'
        % change PRNs from (0,1) to (1,-1)
        prn1 = 1*(prn1==0) + -1*(prn1==1);
        prn2 = 1*(prn2==0) + -1*(prn2==1);
    case 'one-one'
        % nop
    otherwise
        error('dstauffman:GpsUnexpectedForm', 'Unexpected form: "%s"', form);
end

cor = zeros(size(shift));
% loop through different shift values
for i = 1:length(shift)
    % shift prn2
    prn2s = bsr(prn2,shift(i));

    % initialize output
    temp = sum(prn1.*prn2s);

    % scale correlation by number of samples
    cor(i) = temp/1023;
end