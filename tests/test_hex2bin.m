classdef test_hex2bin < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the hex2bin function with the following cases:
    %     Nominal
    %     Drop leading zeros
    %     lower case hex
    %     padded every four
    %     padded every eight
    %     single char hex
    %     single string hex
    %     empty x2
    %     mulitple options
    %     cell array
    %     string array
    %     bad inputs x3

    properties
        bin,
        bin2,
        hex
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.bin = '0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111';
            self.hex = '0123 4567 89AB CDEF';
            self.bin2 = self.bin(self.bin ~= ' ');
        end
    end

    methods (Test)
        function test_nominal(self)
            bin = hex2bin(self.hex);
            self.verifyEqual(bin, self.bin2);
        end

        function test_drop(self)
            bin = hex2bin(self.hex, 'drop');
            self.verifyEqual(bin, self.bin2(8:end));
        end

        function test_lower(self)
            bin = hex2bin(lower(self.hex));
            self.verifyEqual(bin, self.bin2);
        end

        function test_pad4(self)
            bin = hex2bin(self.hex, 'pad4');
            self.verifyEqual(bin, self.bin);
        end

        function test_pad8(self)
            bin = hex2bin(self.hex, 'pad8');
            temp = self.bin;
            temp(5:10:end) = [];
            self.verifyEqual(bin, temp);
        end

        function test_short_hex1(self)
            small_hex = self.hex(self.hex ~= ' ');
            for i = 1:length(small_hex)
                bin = hex2bin(small_hex(i));
                self.verifyEqual(bin, self.bin2(4*i-3:4*i));
            end
        end

        function test_short_hex2(self)
            small_hex = self.hex(self.hex ~= ' ');
            for i = 1:length(small_hex)
                bin = hex2bin(string(small_hex(i)));
                self.verifyEqual(bin, string(self.bin2(4*i-3:4*i)));
            end
        end

        function test_empty_hex1(self)
            bin = hex2bin('');
            self.verifyEqual(bin, '');
        end

        function test_empty_hex2(self)
            bin = hex2bin([], 'pad4');
            self.verifyEqual(bin, '');
        end

        function test_multiple_options(self)
            bin = hex2bin('0 1ff0', 'pad4', 'drop');
            self.verifyEqual(bin, '1 1111 1111 0000');
        end

        function test_multiple_hexes1(self)
            bin = hex2bin({self.hex, '0', 'F0'});
            self.verifyEqual(bin, {self.bin2, '0000', '11110000'});
        end

        function test_multiple_hexes2(self)
            bin = hex2bin(string({self.hex, '0', 'F0'}));
            self.verifyEqual(bin, string({self.bin2, '0000', '11110000'}));
        end

        function test_bad_input_sizes(self)
            self.verifyError(@() hex2bin(), 'MATLAB:minrhs');
        end

        function test_bad_chars(self)
            self.verifyError(@() hex2bin('01-EF'), 'ssc:hex2bin:BadChars');
        end

        function test_bad_options(self)
            self.verifyError(@() hex2bin(self.hex, 'bad_option'), 'ssc:hex2bin:BadOption');
        end
    end
end