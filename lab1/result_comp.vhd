----------------------------------------------------------------------------------
-- Author:          Taimour Wehbe, taimour.wehbe@gatech.edu
-- 
-- Create Date:     16:04:02 08/24/2018 
-- Design Name:     result_comp
-- Module Name:     result_comp
-- Target Devices:  Digilent Zedboard Development Board
-- Tool versions:   Vivado v2017.2.1
-- Description: 
--
--      This is a comparator file that compares generated hash values to a database of hashes and declares an alarm if the generated
--      value is not present in the database. The alarm signal in this file is the ouput signal "comp_result".
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


entity result_comp is
    -- KEEP THE SAME PORT DECLARATIONS FOR THIS MODULE AS IS
    port (
        -- hash value
        H0_i : in std_logic_vector (31 downto 0);
        H1_i : in std_logic_vector (31 downto 0);
        H2_i : in std_logic_vector (31 downto 0);
        H3_i : in std_logic_vector (31 downto 0);
        H4_i : in std_logic_vector (31 downto 0);
        H5_i : in std_logic_vector (31 downto 0);
        H6_i : in std_logic_vector (31 downto 0);
        H7_i : in std_logic_vector (31 downto 0);
        -- output signal indicating whether the generated hash value matched any hash in the database
        comp_result : out std_logic
    );                      
end result_comp;

architecture behavioral of result_comp is
    -- CREATE ANY NEEDED SIGNALS FOR YOUR DESIGN HERE
begin
    --=============================================================================================
    -- Behavioral logic
    --=============================================================================================
    
    -- IN THIS SECTION, YOU NEED TO IMPLEMENT THE NEEDED LOGIC TO COMPARE THE GENERATED HASH VALUE
    -- (COMING AS AN INPUT INTO THIS MODULE) TO THE FOLLOWING SET OF LEGITIMATE HASHES
    --     VALID HASH 1: x"BA7816BF 8F01CFEA 414140DE 5DAE2223 B00361A3 96177A9C B410FF61 F20015AD"
    --     VALID HASH 2: x"68325720 aabd7c82 f30f554b 313d0570 c95accbb 7dc4b5aa e11204c0 8ffe732b"
    --     VALID HASH 3: x"7abc22c0 ae5af26c e93dbb94 433a0e0b 2e119d01 4f8e7f65 bd56c61c cccd9504"
    
    -- IF THE GENERATED HASH MATCHES ANY OF THE ABOVE VALUES, THE comp_result OUTPUT SIGNAL SHOULD
    -- BE ASSERTED, OTHERWISE A BINARY VALUE OF '0' SHOULD BE OUTPUT

    
    -- Comparison logic for valid hashes
    comp_result <= '1' when (
        -- Valid Hash 1: "abc" hash
        (H0_i = x"BA7816BF" and H1_i = x"8F01CFEA" and H2_i = x"414140DE" and H3_i = x"5DAE2223" and
         H4_i = x"B00361A3" and H5_i = x"96177A9C" and H6_i = x"B410FF61" and H7_i = x"F20015AD") or
        
        -- Valid Hash 2: 1-byte 0xbd hash 
        (H0_i = x"68325720" and H1_i = x"AABD7C82" and H2_i = x"F30F554B" and H3_i = x"313D0570" and
         H4_i = x"C95ACCBB" and H5_i = x"7DC4B5AA" and H6_i = x"E11204C0" and H7_i = x"8FFE732B") or
        
        -- Valid Hash 3: 4-byte 0xc98c8e55 hash
        (H0_i = x"7ABC22C0" and H1_i = x"AE5AF26C" and H2_i = x"E93DBB94" and H3_i = x"433A0E0B" and
         H4_i = x"2E119D01" and H5_i = x"4F8E7F65" and H6_i = x"BD56C61C" and H7_i = x"CCCD9504")
    ) else '0';
    
    
end behavioral;

