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

-- Modified for ECE4823 lab assignment by Yu-Cheng Chen
-- Copyright (C) 2021 Georgia Institue of Technology

library ieee;
use ieee.std_logic_1164.all;

entity gfmult_by2 is
	port (
		input_byte : in std_logic_vector(7 downto 0);
		output_byte : out std_logic_vector(7 downto 0)
	);
end gfmult_by2;

architecture behavioral of gfmult_by2 is
	signal shifted_byte : std_logic_vector(7 downto 0);
	signal conditional_xor : std_logic_vector(7 downto 0);
begin
	shifted_byte <= input_byte(6 downto 0) & "0";
	conditional_xor <= "000" & input_byte(7) & input_byte(7) & "0" & input_byte(7) & input_byte(7);
	output_byte <= shifted_byte xor conditional_xor;
	
end architecture behavioral;

