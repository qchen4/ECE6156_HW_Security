----------------------------------------------------------------------------------
-- Author:          Taimour Wehbe, taimour.wehbe@gatech.edu
-- 
-- Create Date:     16:47:10 08/24/2018 
-- Design Name:     hash_checker_test
-- Module Name:     hash_checker_test
-- Target Devices:  Digilent Zedboard Development Board
-- Tool versions:   Vivado v2017.2.1
-- Description: 
--
--      This is a testbench file that tests a wrapper file of the GV_SHA256 engine along with a comparator module used to check
--      the generated hashes against a database of valid hashes.
--      
--      THE LOGIC IN THIS TESTBENCH IS CURRENTLY INCORRECT AND COPIED AS IS FROM LAB 1. YOU HAVE TO MODIFY LINES OF CODE
--      IN THIS FILE AS YOU DEEM NECESSARY TO ADAPT THIS TESTBENCH TO THE NEW TOP LEVEL DESIGN
--      
--
------------------------------ COPYRIGHT NOTICE -----------------------------------------------------------------------
--                                                                   
--      This file is part of the code assigned in Lab 2 of ECE 4823/8873 Advanced Hardware-Oriented Security and Trust
--      at the Georgia Institute of Technology
--                                                                   
--      Author(s):      Taimour Wehbe, taimour.wehbe@gatech.edu
--                      Hardware/Software Codesign for Security Group
--      
--      Copyright (C) 2018 Georgia Institute of Technology
--      ---------------------------------------------------
--      
-----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
    Generic (   
        CLK_PERIOD : time := 10 ns;                     -- clock period for pclk_i (default 100MHz)
        START_DELAY : time := 200 ns                    -- start delay between each run
    );
end testbench;

architecture behavior of testbench is 

    --=============================================================================================
    -- Constants
    --=============================================================================================
    -- clock period
    constant PCLK_PERIOD : time := CLK_PERIOD;          -- parallel high-speed clock
    
    --=============================================================================================
    -- Signals for state machine control
    --=============================================================================================

    --=============================================================================================
    -- Signals for internal operation
    --=============================================================================================
    --- clock signals ---
    signal pclk             : std_logic := '1';                 -- 100MHz clock
    signal dut_ce           : std_logic;
    -- input data
    signal dut_di           : std_logic_vector (31 downto 0);   -- big endian input message words
    signal dut_bytes        : std_logic_vector (1 downto 0);    -- valid bytes in input word
    -- start/end commands
    signal dut_start        : std_logic;                        -- reset the processor and start a new hash
    signal dut_end          : std_logic;                        -- marks end of last block data input
    -- handshake
    signal dut_di_req       : std_logic;                        -- requests data input for next word
    signal dut_di_wr        : std_logic;                        -- high for di_i write, low for hold
    signal dut_error        : std_logic;                        -- signalizes error. output data is invalid
    signal dut_do_valid     : std_logic;                        -- when high, the output is valid
    -- Expected behavior signal
    signal dut_expected_behavior : std_logic;  -- NEW: Added for result comparison

    -- testbench control signals
    signal words            : natural;
    signal blocks           : natural;
    signal test_case        : natural;
begin

    --=============================================================================================
    -- INSTANTIATION FOR THE DEVICE UNDER TEST
    --=============================================================================================
	Inst_hash_checker: entity work.hash_checker(rtl)  -- CHANGED: Using hash_checker instead of gv_sha256
        port map(
            clk_i => pclk,
            ce_i => dut_ce,
            di_i => dut_di,
            bytes_i => dut_bytes,
            start_i => dut_start,
            end_i => dut_end,
            di_req_o => dut_di_req,
            di_wr_i => dut_di_wr,
            error_o => dut_error,
            do_valid_o => dut_do_valid,
            expected_behavior_o => dut_expected_behavior  -- NEW: Connecting comparison result
        );


    --=============================================================================================
    -- CLOCK GENERATION
    --=============================================================================================
    pclk_proc: process is
    begin
        loop
            pclk <= not pclk;
            wait for PCLK_PERIOD / 2;
        end loop;
    end process pclk_proc;
    --=============================================================================================
    -- TEST BENCH STIMULI
    --=============================================================================================
    -- This testbench exercises the SHA256 toplevel with the NIST-FIPS-180-4 test vectors.
    --
    tb1 : process is
        variable count_words  : natural := 0;
        variable count_blocks : natural := 0;
        variable temp_di      : unsigned (31 downto 0) := (others => '0');
    begin
        wait for START_DELAY; -- wait until global set/reset completes
        -------------------------------------------------------------------------------------------
        -- test vector 1
        -- src: NIST-FIPS-180-4 
        -- msg := "abc" 
        -- hash:= BA7816BF 8F01CFEA 414140DE 5DAE2223 B00361A3 96177A9C B410FF61 F20015AD
        test_case <= 1;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"61626300";
        dut_bytes <= b"11";
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- Replace all Hx assertions with single result check
        assert dut_expected_behavior = '1' report "test #1 failed - Valid hash not detected" severity error;

        
        -------------------------------------------------------------------------------------------
        -- test vector 2
        -- src: NIST-FIPS-180-4 
        -- msg := "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
        -- hash:= 248D6A61 D20638B8 E5C02693 0C3E6039 A33CE459 64FF2167 F6ECEDD4 19DB06C1
        test_case <= 2;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        wait until pclk'event and pclk = '1';   -- 'begin' pulse minimum width is one clock
        wait for 25 ns;                         -- TEST: stretch 'begin' pulse
        dut_start <= '0';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';
        dut_bytes <= b"00";
        dut_di <= x"61626364";
        wait until pclk'event and pclk = '1';
        dut_di <= x"62636465";
        wait until pclk'event and pclk = '1';
        dut_di <= x"63646566";
        wait until pclk'event and pclk = '1';
        dut_di <= x"64656667";
        wait until pclk'event and pclk = '1';
        dut_di <= x"65666768";
        wait until pclk'event and pclk = '1';
        dut_di <= x"66676869";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6768696A";
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';                      -- TEST: slow inputs with 'wr_i' handshake
        wait until pclk'event and pclk = '1';
        dut_di <= x"68696A6B";
        wait until pclk'event and pclk = '1';
        dut_di <= x"696A6B6C";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6A6B6C6D";
        dut_bytes <= b"01";                     -- induce ERROR
        wait until pclk'event and pclk = '1';
        dut_di <= x"6B6C6D6E";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6C6D6E6F";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6D6E6F70";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6E6F7071";
        dut_end <= '1';
        wait until pclk'event and pclk = '1';   -- 'end' pulse minimum width is one clock
        dut_bytes <= b"01";                     -- TEST: change 'bytes' value after END
        wait for 75 ns;                         -- TEST: stretch 'end' pulse
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;
        -------------------------------------------------------------------------
        -- restart test #2: force error by stretching the write strobe
        dut_ce <= '0';
        test_case <= 0;
        wait until pclk'event and pclk = '1';
        test_case <= 2;
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        wait until pclk'event and pclk = '1';   -- 'begin' pulse minimum width is one clock
        wait for 25 ns;                         -- TEST: stretch 'begin' pulse
        dut_start <= '0';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';
        dut_bytes <= b"00";
        dut_di <= x"61626364";
        wait until pclk'event and pclk = '1';
        dut_di <= x"62636465";
        wait until pclk'event and pclk = '1';
        dut_di <= x"63646566";
        wait until pclk'event and pclk = '1';
        dut_di <= x"64656667";
        wait until pclk'event and pclk = '1';
        dut_di <= x"65666768";
        wait until pclk'event and pclk = '1';
        dut_di <= x"66676869";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6768696A";
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';                      -- TEST: slow inputs with 'wr_i' handshake
        wait until pclk'event and pclk = '1';
        dut_di <= x"68696A6B";
        wait until pclk'event and pclk = '1';
        dut_di <= x"696A6B6C";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6A6B6C6D";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6B6C6D6E";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6C6D6E6F";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6D6E6F70";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6E6F7071";
        wait for 75 ns;
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;
        -------------------------------------------------------------------------
        -- restart test #2
        dut_ce <= '0';
        test_case <= 0;
        wait until pclk'event and pclk = '1';
        test_case <= 2;
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"61626364";
        dut_bytes <= b"00";
        wait until pclk'event and pclk = '1';   -- 'begin' pulse minimum width is one clock
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        wait until pclk'event and pclk = '1';
        dut_di <= x"62636465";
        wait until pclk'event and pclk = '1';
        dut_di <= x"63646566";
        wait until pclk'event and pclk = '1';
        dut_di <= x"64656667";
        wait until pclk'event and pclk = '1';
        dut_di <= x"65666768";
        wait until pclk'event and pclk = '1';
        dut_di <= x"66676869";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6768696A";
        wait until pclk'event and pclk = '1';
        dut_di <= x"68696A6B";
        wait until pclk'event and pclk = '1';
        dut_di <= x"696A6B6C";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6A6B6C6D";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6B6C6D6E";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6C6D6E6F";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6D6E6F70";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6E6F7071";
        dut_end <= '1';
        wait until pclk'event and pclk = '1';   -- 'end' pulse minimum width is one clock
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- First run (with induced error)
        assert dut_expected_behavior = '0' report "test #2 failed - Invalid hash accepted" severity error;
        

        -------------------------------------------------------------------------------------------
        -- test vector 3
        -- src: NIST-ADDITIONAL-SHA256
        -- #1) 1 byte 0xbd
        -- msg := x"bd"
        -- hash:= 68325720 aabd7c82 f30f554b 313d0570 c95accbb 7dc4b5aa e11204c0 8ffe732b
        test_case <= 3;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"bd000000";
        dut_bytes <= b"01";
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        assert dut_expected_behavior = '1' 
            report "Test #3 (1-byte 0xbd) failed - Valid hash not detected" 
            severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 4
        -- src: NIST-ADDITIONAL-SHA256
        -- #2) 4 bytes 0xc98c8e55
        -- msg := x"c98c8e55"
        -- hash:= 7abc22c0 ae5af26c e93dbb94 433a0e0b 2e119d01 4f8e7f65 bd56c61c cccd9504
        test_case <= 4;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"c98c8e55";
        dut_bytes <= b"00";
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        dut_di_wr <= '1';
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        assert dut_expected_behavior = '1' report "test #4 failed - Valid hash not detected" severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 5
        -- src: NIST-ADDITIONAL-SHA256
        -- #3) 55 bytes of zeros
        -- msg := 55 x"00"
        -- hash:= 02779466 cdec1638 11d07881 5c633f21 90141308 1449002f 24aa3e80 f0b88ef7
        test_case <= 5;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"00000000";
        dut_bytes <= b"00";
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '1';
        dut_bytes <= b"11";
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        assert dut_expected_behavior = '1' report "test #5 failed - Valid hash not detected" severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 6
        -- src: NIST-ADDITIONAL-SHA256
        -- #8) 1000 bytes of 0x41 'A'
        -- msg := 1000 x"41"
        -- hash:= c2e68682 3489ced2 017f6059 b8b23931 8b6364f6 dcd835d0 a519105a 1eadd6e4
        test_case <= 6;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_bytes <= b"00";
        dut_di <= x"41414141";
        count_words := 0;
        words <= count_words;
        count_blocks := 0;
        blocks <= count_blocks;
        loop
            wait until dut_di_req = '1';
            wait until pclk'event and pclk = '1';
            dut_di_wr <= '1';
            loop
                wait until pclk'event and pclk = '1';
                count_words := count_words + 1;
                words <= count_words;
                exit when words = 15;
            end loop;
            dut_di_wr <= '0';
            count_words := 0;
            words <= count_words;
            count_blocks := count_blocks + 1;
            blocks <= count_blocks;
            exit when blocks = 14;
        end loop;
        count_words := 0;
        words <= count_words;
        wait until dut_di_req = '1';
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';
        loop
            wait until pclk'event and pclk = '1';
            count_words := count_words + 1;
            words <= count_words;
            exit when words = 8;
        end loop;
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        assert dut_expected_behavior = '1' report "test #6 failed - Valid hash not detected" severity error;


        assert false report "End Simulation" severity warning; -- stop simulation
    end process tb1;
    --  End Test Bench 
END;
