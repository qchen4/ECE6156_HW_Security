-- VHDL implementation of AES
-- Copyright (C) 2019  Hosein Hadipour
-- This source file may be used and distributed without  
-- restriction provided that this copyright statement is not 
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
--
--*************************************************************
-- Modified for ECE4823 lab assignment by Yu-Cheng Chen
-- Copyright (C) 2021 Georgia Institue of Technology

library ieee;
use ieee.std_logic_1164.all;

entity test_enc is 
end test_enc;

architecture behavior of test_enc is
	component aes_enc
		port(
			clk        : in  std_logic;
			rst        : in  std_logic;
			key        : in  std_logic_vector(127 downto 0);
			plaintext  : in  std_logic_vector(127 downto 0);
			ciphertext : out std_logic_vector(127 downto 0);
			done       : out std_logic
		);		
	end component aes_enc;	
	-- Input signals
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal plaintext : std_logic_vector(127 downto 0);
	signal key : std_logic_vector(127 downto 0);	
	
	-- Output signals
	signal done : std_logic;
	signal ciphertext : std_logic_vector(127 downto 0);	
	
	-- Clock period definition
	constant clk_period : time := 10 ns;

	type test_case is record
		key        : std_logic_vector(127 downto 0);
		plaintext  : std_logic_vector(127 downto 0);
		ciphertext : std_logic_vector(127 downto 0);
	end record;

	type test_case_array is array (natural range <>) of test_case;
	constant test_cases : test_case_array := (
		-- Test Case 1 (Reversed from C version)
		(
			key        => x"3c4fcf098815f7aba6d2ae2816157e2b",  -- C key1 reversed
			plaintext  => x"217362614c2d534541202c6f6c656848",  -- Plaintext1 reversed
			ciphertext => x"548c8502a3544dc8edde78165babad17"   -- Ciphertext1 reversed
		),
		-- Test Case 2
		(
			key        => x"1807f6e5d4c3d2a6abf7158809cf4f3c",  -- C key2 reversed
			plaintext  => x"61746164207275756f79206563726553",  -- Plaintext2 reversed
			ciphertext => x"c9c0b98a07cd7f6b8c9b7f73cdf19b60"   -- Ciphertext2 reversed
		),
		-- Test Case 3
		(
			key        => x"ffeeddccbbaa99887766554433221100",  -- C key3 reversed
			plaintext  => x"21216e6f6974707972636e6520534541",  -- Plaintext3 reversed
			ciphertext => x"dba0d3751fd5b9edbfd74df4f4e0f3af"   -- Ciphertext3 reversed
		),
		-- Test Case 4 (Fixed length)
		(
			key        => x"00ffeeddccbbaa998877665544332211",  -- C key4 reversed
			plaintext  => x"343332317968706172676f7470797243",  -- Plaintext4 reversed (full 16 bytes)
			ciphertext => x"6d5303da9b91f6350333c3d9c1ad95be"   -- Ciphertext4 reversed
		),
		-- Test Case 5
		(
			key        => x"99887766554433221100ffeeddccbbaa",  -- C key5 reversed
			plaintext  => x"323433206567617373656d2074736554",  -- Plaintext5 reversed
			ciphertext => x"0335ffb8c1412732ce81a6d748cb7906"   -- Ciphertext5 reversed
		)
	);

begin
	enc_inst : aes_enc
		port map(
			clk        => clk,
			rst        => rst,
			key        => key,
			plaintext  => plaintext,
			ciphertext => ciphertext,
			done       => done
		);	
	-- clock process definitions
	clk_process : process is
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process clk_process;
	
	-- Modified simulation process
	sim_proc : process is
		variable error_count : natural := 0;
	begin
		rst <= '0';
		wait for clk_period;
		rst <= '1';

		for i in test_cases'range loop
			-- Apply test case
			plaintext <= test_cases(i).plaintext;
			key <= test_cases(i).key;
			
			-- Reset sequencing from original testbench
			rst <= '0';
			wait for clk_period;
			rst <= '1';
			
			-- Wait for completion
			wait until done = '1';
			wait for clk_period/2;
			
			-- Check result
			if ciphertext /= test_cases(i).ciphertext then
				report "Test case " & integer'image(i+1) & " failed!" severity error;
				report "Expected: " & to_hstring(test_cases(i).ciphertext);
				report "Received: " & to_hstring(ciphertext);
				error_count := error_count + 1;
			end if;
			
			wait for clk_period*2;  -- Inter-testcase delay
		end loop;

		-- Final report
		if error_count = 0 then
			report "All " & integer'image(test_cases'length) & " test cases passed!";
		else
			report integer'image(error_count) & "/" & integer'image(test_cases'length) & " test cases failed!";
		end if;
		
		assert false report "Simulation complete" severity failure;
		wait;
	end process sim_proc;
	
end architecture behavior;

