----------------------------------------------------------------------------------
-- Author:          Taimour Wehbe, taimour.wehbe@gatech.edu
-- 
-- Create Date:     14:52:35 08/24/2018 
-- Design Name:     hash_checker
-- Module Name:     hash_checker
-- Target Devices:  Digilent Zedboard Development Board
-- Tool versions:   Vivado v2017.2.1
-- Description: 
--
--      This is a top level file that acts as a wrapper for the GV_SHA256 engine.
--      
--      The goal of this top level design is to instantiate the SHA256 engine, pass input and output signals to it from the testbench
--      and compare any generated hash value against a list of predefined hashes.
--      
--      The top level module should have the same input and output pins as the gv_sha256 module except that the output SHA values
--      should not be passed along as outputs of the top level. Instead a single output pin should be used to signal whether a generated
--      hash is not present in the database of legitimate hashes. The said signal is referred to in this file as "expected_behavior_o"
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


entity hash_checker is
    port (
        -- clock and core enable
        clk_i : in std_logic := '0';                                    -- system clock
        ce_i : in std_logic := '0';                                     -- core clock enable
        -- input data
        di_i : in std_logic_vector (31 downto 0) := (others => '0');    -- big endian input message words
        bytes_i : in std_logic_vector (1 downto 0) := (others => '0');  -- valid bytes in input word
        -- start/end commands
        start_i : in std_logic := '0';                                  -- reset the engine and start a new hash
        end_i : in std_logic := '0';                                    -- marks end of last block data input
        -- handshake
        di_req_o : out std_logic;                                       -- requests data input for next word
        di_wr_i : in std_logic := '0';                                  -- high for di_i valid, low for hold
        error_o : out std_logic;                                        -- signalizes error. output data is invalid
        do_valid_o : out std_logic;                                     -- when high, the output is valid
        -- output signal indicating whether the generated hash value matched any hash in the database
        --     NOTICE THAT WE REMOVED THE 256-BIT HASH OUTPUT SIGNALS AND REPLACED THEM WITH A SINGLE SIGNAL
        --     INDICATING WHETHER OR NOT THE HASH MATCHES A CERTAIN SET OF VALUES
        expected_behavior_o : out std_logic
    );                      
end hash_checker;

architecture rtl of hash_checker is
    -- SIGNAL DECLARATIONS
    signal H0_i, H1_i, H2_i, H3_i : std_logic_vector(31 downto 0);
    signal H4_i, H5_i, H6_i, H7_i : std_logic_vector(31 downto 0);
begin
    --=============================================================================================
    -- INTERNAL COMPONENT INSTANTIATIONS AND CONNECTIONS
    --=============================================================================================

    -- gv_sha256 module instantiation
    
    -- IN THIS SECTION, YOU WILL NEED TO INSTANTIATE THE SHA256 MODULE SO THAT YOU CONNECT SOME OF
    -- ITS PINS TO THE INPUTS AND OUTPUTS OF THIS NEW TOP LEVEL MODULE AND OTHERS TO THE NEW COMPONENT
    -- THAT WE'RE INSTANTIATING BELOW
    
    
    -- result_comp module instantiation
    
    -- IN THIS SECTION, YOU WILL NEED TO INSTANTIATE AND CONNECT THE RESULT COMPARATOR MODULE WHICH
    -- YOU SHOULD HAVE CREATED BEFORE MODIFYING THIS FILE. THE RESULT COMPARATOR MODULE CHECKS THE
    -- GENERATED HASH THAT WAS CREATED BY THE GV_SHA256 MODULE ABOVE AGAINST A SET OF VALID HASHES

    
    -- Instantiate SHA256 core
    sha256_inst: entity work.gv_sha256
    port map(
        clk_i => clk_i,
        ce_i => ce_i,
        di_i => di_i,
        bytes_i => bytes_i,
        start_i => start_i,
        end_i => end_i,
        di_req_o => di_req_o,
        di_wr_i => di_wr_i,
        error_o => error_o,
        do_valid_o => do_valid_o,
        H0_o => H0_i,
        H1_o => H1_i,
        H2_o => H2_i,
        H3_o => H3_i,
        H4_o => H4_i,
        H5_o => H5_i,
        H6_o => H6_i,
        H7_o => H7_i
    );

    -- Instantiate result comparator
    result_comp_inst: entity work.result_comp
    port map(
        H0_i => H0_i,
        H1_i => H1_i,
        H2_i => H2_i,
        H3_i => H3_i,
        H4_i => H4_i,
        H5_i => H5_i,
        H6_i => H6_i,
        H7_i => H7_i,
        comp_result => expected_behavior_o
    );
    
    
end rtl;

