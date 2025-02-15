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
	
	-- Simulation process
	sim_proc : process is
	begin
		-- Test Case 1
		plaintext <= x"217362614c2d534541202c6f6c6c6548";
		key <= x"3c4fcf098815f7aba6d2ae2816157e2b";
		rst <= '0';
		wait until rising_edge(clk);
		rst <= '1';
		wait until done = '1';
		wait until rising_edge(clk);
		if (ciphertext = x"548c8502a3544dc8edde78165babad17") then
			report "Test 1: Passed";
		else
			report "Test 1: Failed";
		end if;

		-- Test Case 2
		plaintext <= x"617461642072756f7920657275636553";
		key <= x"1807f6e5d4c3d2a6abf7158809cf4f3c";
		rst <= '0';
		wait until rising_edge(clk);
		rst <= '1';
		wait until done = '1';
		wait until rising_edge(clk);
		if (ciphertext = x"c9c0b98a07cd7f6b8c9b7f73cdf19b60") then
			report "Test 2: Passed";
		else
			report "Test 2: Failed";
		end if;

		-- Test Case 3
		plaintext <= x"21216e6f6974707972636e6520534541";
		key <= x"ffeeddccbbaa99887766554433221100";
		rst <= '0';
		wait until rising_edge(clk);
		rst <= '1';
		wait until done = '1';
		wait until rising_edge(clk);
		if (ciphertext = x"dba0d3751fd5b9edbfd74df4f4e0f3af") then
			report "Test 3: Passed";
		else
			report "Test 3: Failed";
		end if;

		-- Test Case 4
		plaintext <= x"343332317968706172676f7470797243";
		key <= x"00112233445566778899aabbccddeeff";
		rst <= '0';
		wait until rising_edge(clk);
		rst <= '1';
		wait until done = '1';
		wait until rising_edge(clk);
		if (ciphertext = x"6d5303da9b91f6350333c3d9c1ad95be") then
			report "Test 4: Passed";
		else
			report "Test 4: Failed";
		end if;

		-- Test Case 5
		plaintext <= x"323423206567617373656d2074736554";
		key <= x"99887766554433221100ffeeddccbbaa";
		rst <= '0';
		wait until rising_edge(clk);
		rst <= '1';
		wait until done = '1';
		wait until rising_edge(clk);
		if (ciphertext = x"0335ffb8c1412732ce81a6d748cb7906") then
			report "Test 5: Passed";
		else
			report "Test 5: Failed";
		end if;

		wait;
	end process sim_proc;
	
end architecture behavior;




