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

entity add_round_key is
	port (
		input1 : in std_logic_vector(127 downto 0);
		input2 : in std_logic_vector(127 downto 0);
		output : out std_logic_vector(127 downto 0)
	);
end add_round_key;

architecture rtl of add_round_key is
	
begin
	output <= input1 xor input2;		
end architecture rtl;
