----------------------------------------------------------------------------------
-- Author:          Kevin Hutto, khutto30@gatech.edu
-- 
-- Create Date:      
-- Design Name:     DE_10_hash_checker
-- Description: 
--
--      This is a top level file that acts as a wrapper for the hash_checker file.
--      
--      The goal of this top level design is to instantiate the SHA256 engine and compare a few predefined 
--      hash values against a list of predefined hashes.
--      
--      
--      
--
------------------------------ COPYRIGHT NOTICE -----------------------------------------------------------------------
--                                                                   
--      This file is part of the code assigned in Lab 2 of ECE 4823/8873 Advanced Hardware-Oriented Security and Trust
--      at the Georgia Institute of Technology
--                                                                   
--      Author(s):      Kevin Hutto, khutto30@gatech.edu
--                      Hardware/Software Codesign for Security Group
--      
--      Copyright (C) 2022 Georgia Institute of Technology
--      ---------------------------------------------------
--      
-----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DE_10_hash_checker is
    port (
        -- clock and core enable
        clk_i : in std_logic;                                    -- system clock
		resetn : in std_logic;
        output_valid_LED : out std_logic := '0';
		hash_selector_switch : in std_logic_vector(1 downto 0); -- connect the hash selector switches here
		start : in std_logic
    );                      
end DE_10_hash_checker;


architecture rtl of DE_10_hash_checker is




	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3); --ADD STATES AS REQUIRED
	
	-- Register to hold the current state
	signal state   : state_type;

	signal ce_i, start_i, end_i, di_req_o, di_wr_i, error_o, do_valid_o, expected_behavior_o : std_logic;
	signal bytes_i : std_logic_vector(1 downto 0);
	signal di_i : std_logic_vector(31 downto 0);

component hash_checker is
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
end component;



begin

--instatiation of the hash_checker file
	Inst_hash_checker : hash_checker port map(

		clk_i => clk_i, --We directly connect the hash_checker clk to the external clk
		ce_i => ce_i,
		di_i => di_i,
		bytes_i => bytes_i,
		start_i => start_i,
		end_i => end_i,
		di_req_o => di_req_o,
		di_wr_i => di_wr_i,
		error_o => error_o,
		do_valid_o => do_valid_o, 
		expected_behavior_o => expected_behavior_o
	);


--framework for the state machine. The four potential input values for the hashes to be used are :
-- hash 0: di_i <= x"61626300"; --Should give "legitimate" result
-- hash 1: di_i <= x"bd000000"; --Should give "legitimate" result
-- hash 2: di_i <= x"ffaaffaa"; --Should not give "legitimate" result
-- hash 3: di_i <= x"12345678"; --Should not give "legitimate" result

--INSERT LOGIC AS REQUIRED HERE TO COMPLETE THE TRANSITION OF STATES
	-- Logic to advance to the next state
	process (clk_i, resetn)
	begin
		if resetn = '0' then
			state <= s0;
		elsif (rising_edge(clk_i)) then
			case state is
				when s0=>
					if start = '0' then
						state <= s1;
					else
						state <= s0;
					end if;
					
				when s1=>
				--IMPLEMENT TRANSITION LOGIC
				when s2=>
				
				
				
				when s3 =>
			
			end case;
		end if;
	end process;
	
	--INSERT LOGIC AS REQUIRED HERE TO MANAGE INPUT AND OUTPUT VALUES
		process (state)
	begin
	
		case state is
			when s0 =>
				output_valid_LED <= '0';
				di_i <= x"00000000";
				ce_i <= '0';
				bytes_i <= "00";
				di_wr_i <= '0';
				start_i <= '0';
				end_i <= '0';
			when s1 =>
				output_valid_LED <= '0';
				di_wr_i <= '0';
				end_i <= '0';
				start_i <= '1';
				bytes_i <= "11";
				ce_i <= '1';
				if hash_selector_switch = "00" then
					di_i <= x"61626300";
				--finish the if statement and the next states
				end if;
				
			when s2 =>
				
			when s3 =>
				
		end case;
	end process;
	
	
end;