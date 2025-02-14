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
		-- Some test vectors taken from pages 215, and 216 of the main AES specification		
		--p = 3243f6a8885a308d313198a2e0370734                     Plaintext 1
		--k = 2b7e151628aed2a6abf7158809cf4f3c			   128-bit key
		--c = 3925841d02dc09fbdc118597196a0b32                     Ciphertext 1
		-- Initialize Inputs
		plaintext <= x"340737e0a29831318d305a88a8f64332";
		key <= x"3c4fcf098815f7aba6d2ae2816157e2b";
		rst <= '0';
		-- Hold reset state for one cycle		
		wait for clk_period * 1;
		rst <= '1';
		wait until done = '1';
		wait for clk_period/2;			
		if (ciphertext = x"320b6a19978511dcfb09dc021d842539") then
			report "---------- Passed ----------";
		else
			report "---------- Failed ----------";
		end if;
		report "---------- Output must be: -------";
		report "320b6a19978511dcfb09dc021d842539";		
		--------------------------------------------
		-- Initialize Inputs
		--p = 54686973206973206120736563726574              	   Plaintext 2
		--k = 2b7e151628aed2a6abf7158809cf4f3c			   128-bit key
		--c = 65bf63df7687d1c1b38eda29d416666d	                   Ciphertext 2 		
		plaintext <= x"74657263657320612073692073696854";
		key <= x"3c4fcf098815f7aba6d2ae2816157e2b";
		rst <= '0';
		-- Hold reset state for one cycle		
		wait for clk_period * 1;
		rst <= '1';
		wait until done = '1';
		wait for clk_period/2;			
		if (ciphertext = x"6d6616d429da8eb3c1d18776df63bf65") then
			report "---------- Passed ----------";
		else
			report "---------- Failed ----------";
		end if;
		report "---------- Output must be: -------";
		report "6d6616d429da8eb3c1d18776df63bf65";
		wait;
	end process sim_proc;
	
end architecture behavior;

