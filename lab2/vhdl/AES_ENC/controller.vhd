-- VHDL implementation of AES
-- Copyright (C) 2019  Hosein Hadipour
--This source file may be used and distributed without  
--restriction provided that this copyright statement is not 
--removed from the file and that any derivative work contains
--the original copyright notice and the associated disclaimer.
--
--This source is distributed in the hope that it will be
--useful, but WITHOUT ANY WARRANTY; without even the implied
--warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
--PURPOSE.  See the GNU Lesser General Public License for more
--details.
--
--You should have received a copy of the GNU Lesser General
--Public License along with this source; if not, download it
--from http://www.opencores.org/lgpl.shtml
--
--*************************************************************
-- Modified for ECE4823 lab assignment by Yu-Cheng Chen
-- Copyright (C) 2021 Georgia Institue of Technology

library ieee;
use ieee.std_logic_1164.all;

entity controller is
	port (
		clk : in std_logic;
		rst : in std_logic;
		rconst : out std_logic_vector(7 downto 0);
		is_final_round : out std_logic;
		done : out std_logic
	);
end controller;

architecture behavioral of controller is
	signal reg_input : std_logic_vector(7 downto 0);
	signal reg_output : std_logic_vector(7 downto 0);
	signal feedback : std_logic_vector(7 downto 0);
begin
	reg_input <= x"01" when rst = '0' else feedback;
	reg_inst : entity work.reg
		generic map(
			size => 8
		)
		port map(
			clk => clk,
			d   => reg_input,
			q   => reg_output
		);
	--	register_with_reset : process(clk) is
	--	begin
	--		if rising_edge(clk) then
	--			if (rst = '0') then 
	--				reg_output <= x"01";				
	--			else 
	--				reg_output <= feedback;
	--			end if;
	--		end if;
	--    end process register_with_reset;

	gfmult_by2_inst : entity work.gfmult_by2
		port map(
			input_byte  => reg_output,
			output_byte => feedback
		);
	rconst <= reg_output;
	is_final_round <= '1' when reg_output = x"36" else '0';
	done <= '1' when reg_output = x"6c" else '0';
end architecture behavioral;
