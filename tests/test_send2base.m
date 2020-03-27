classdef test_send2base < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the send_vars_to_workspace function with the following cases:
    %     function with normal inputs
    %     function with one input - cell array
    %     function with one input - char
    %     function with new string inputs
    %     function with no inputs
    %     function with exclusions
    %     function with caller workspace
    %     script with one input
    %     script with multiple inputs
    %     function with wildcards
    %     function with wildcards and exclusions

    properties
        test,
        name_one,
        name_two
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.test     = 123;
            self.name_one = '1';
            self.name_two = '2';
            evalin('base', 'clearvars name_one name_two test');
        end
    end

    methods (Test)
        function test_simple_1(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            sent_vars = send2base('test');
            self.verifyEqual(sent_vars, {'test'});
            self.verifyTrue(evalin('base', 'test == 123;'));
        end

        function test_simple_2(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            sent_vars = send2base('name_two');
            self.verifyEqual(sent_vars, {'name_two'});
            self.verifyTrue(evalin('base', 'strcmp(name_two, ''2'');'));
        end

        function test_multiple(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            sent_vars = send2base('test', 'name_one');
            self.verifyEqual(sent_vars, {'name_one', 'test'});
            self.verifyTrue(evalin('base', 'strcmp(name_one, ''1'');'));
            self.verifyTrue(evalin('base', 'test == 123;'));
        end

        function test_statment_1(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            send2base test
            self.verifyTrue(evalin('base', 'exist(''name_one'') == 0;'), 'name_one should not exist.');
            self.verifyTrue(evalin('base', 'exist(''name_two'') == 0;'), 'name_two should not exist.');
            self.verifyTrue(evalin('base', 'exist(''test'') == 1;'), 'test should exist.');
            self.verifyTrue(evalin('base', 'test == 123;'));
        end

        function test_statment_2(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            send2base test name_one
            self.verifyTrue(evalin('base', 'exist(''name_one'') == 1;'), 'name_one should exist.');
            self.verifyTrue(evalin('base', 'exist(''name_two'') == 0;'), 'name_two should not exist.');
            self.verifyTrue(evalin('base', 'exist(''test'') == 1;'), 'test should exist.');
            self.verifyTrue(evalin('base', 'strcmp(name_one, ''1'');'));
            self.verifyTrue(evalin('base', 'test == 123;'));
        end

        function test_wildcards_1(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            sent_vars = send2base('test*');
            self.verifyEqual(sent_vars, {'test'});
            self.verifyTrue(evalin('base', 'test == 123;'));
        end

        function test_wildcards_2(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            send2base test*
            self.verifyTrue(evalin('base', 'exist(''name_one'') == 0;'), 'name_one should not exist.');
            self.verifyTrue(evalin('base', 'exist(''name_two'') == 0;'), 'name_two should not exist.');
            self.verifyTrue(evalin('base', 'exist(''test'') == 1;'), 'test should exist.');
            self.verifyTrue(evalin('base', 'test == 123;'));
        end

        function test_wildcards_3(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            send2base name_*
            self.verifyTrue(evalin('base', 'exist(''name_one'') == 1;'), 'name_one should exist.');
            self.verifyTrue(evalin('base', 'exist(''name_two'') == 1;'), 'name_two should exist.');
            self.verifyTrue(evalin('base', 'exist(''test'') == 0;'), 'test should not exist.');
            self.verifyTrue(evalin('base', 'strcmp(name_one, ''1'');'));
            self.verifyTrue(evalin('base', 'strcmp(name_two, ''2'');'));
        end

        function test_case_sensitivity_1(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            self.verifyError(@() send2base('Test'), 'matspace:BadSendVarsName');
        end

        function test_case_sensitivity_2(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            sent_vars = send2base('Test*');
            self.verifyEmpty(sent_vars);
        end

        function test_exclude_1(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            sent_vars = send2base('test', '-exclude', 'name*');
            self.verifyEqual(sent_vars, {'test'});
            self.verifyTrue(evalin('base', 'test == 123;'));
        end

        function test_exclude_2(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            sent_vars = send2base('-exclude', 'name*', 'test');
            self.verifyEqual(sent_vars, {'test'});
            self.verifyTrue(evalin('base', 'test == 123;'));
        end

        function test_exclude_3(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            sent_vars = send2base('test', '-exclude', 'test');
            self.verifyEmpty(sent_vars);
        end

        function test_exclude_4(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            sent_vars = send2base('test', '-exclude', 'name*', 'name_one');
            self.verifyEqual(sent_vars, {'test'});
            self.verifyTrue(evalin('base', 'test == 123;'));
        end

        function test_exclude_5(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            sent_vars = send2base('test', '-exclude', {'tested', 'name*'});
            self.verifyEqual(sent_vars, {'test'});
            self.verifyTrue(evalin('base', 'test == 123;'));
        end

        function test_exclude_6(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            sent_vars = send2base('test', 'name_one', 'name_two', '-exclude', {'test*', 'name_one'});
            self.verifyEqual(sent_vars, {'name_two'});
            self.verifyTrue(evalin('base', 'strcmp(name_two, ''2'');'));
        end

        function test_pass_everything(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            send2base *
            self.verifyTrue(evalin('base', 'exist(''name_one'') == 1;'), 'name_one should exist.');
            self.verifyTrue(evalin('base', 'exist(''name_two'') == 1;'), 'name_two should exist.');
            self.verifyTrue(evalin('base', 'exist(''test'') == 1;'), 'test should exist.');
            self.verifyTrue(evalin('base', 'strcmp(name_one, ''1'');'));
            self.verifyTrue(evalin('base', 'strcmp(name_two, ''2'');'));
            self.verifyTrue(evalin('base', 'test == 123;'));
        end

        function test_exclude_everything(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            sent_vars = send2base('*', '-exclude', '*');
            self.verifyEmpty(sent_vars);
        end

        function test_bad_option(self)
            test = self.test; name_one = self.name_one; name_two = self.name_two; %#ok<NASGU>
            self.verifyError(@() send2base('Test', '-exclusions', 'name*'), 'matspace:BadSendVarsOption');
        end

    end
end