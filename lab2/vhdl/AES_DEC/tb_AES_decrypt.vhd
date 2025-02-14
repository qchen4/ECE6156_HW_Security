--************************************************************
--Copyright 2015, Ganesh Hegde < ghegde@opencores.org >      
--                                                           
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


--This file is a test bench for AES decryption IP.
--*************************************************************

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

entity tb_AES_decrypt is 
end tb_AES_decrypt;

architecture beh_tb_AES_decrypt of tb_AES_decrypt is
	component AES_decrypter
	port (
		  cipher: in std_logic_vector(127 downto 0);
		  text_out: out std_logic_vector(127 downto 0);
		  key: in std_logic_vector(127 downto 0);
		  k_valid,c_valid: in std_logic;--Asserted when either key, cipher is valid
		  ready:out std_logic;--Asserted high when IP is ready to accept the data(key or Cipher)
		  out_valid: out std_logic;--out_valid:Asserted high when decrypted cipher is on the bus
		  clk,reset: in std_logic
		);
    end component;
   
   constant clk_period: time := 10 ns;
   signal reset,clk:std_logic;
   signal cipher,text_out: std_logic_vector(127 downto 0);
   signal key:std_logic_vector(127 downto 0);
   signal k_valid,c_valid,out_valid:std_logic;
   signal ready:std_logic;
   
   
begin
    uut:AES_decrypter
	port map(cipher=>cipher,text_out=>text_out,key=>key,k_valid=>k_valid,c_valid=>c_valid,out_valid=>out_valid,clk=>clk,reset=>reset,ready=>ready);
	
  clk_process:process
  begin
     clk<='1';
     wait for clk_period/2;
     clk<='0';
	 wait for clk_period/2;
  end process;
  
	tb_process:process
    variable LW : line;
	variable error: integer:=0;
	begin
      reset<='1';
	  k_valid<='0';
	  c_valid<='0';
	  
	  wait for 5*clk_period;
	  reset<='0';
	  
	  wait for clk_period;
	  
	  if(ready/='1') then
	  wait until ready='1';	  
	  end if;
	  k_valid<='1';
	  key<=x"2b7e151628aed2a6abf7158809cf4f3c";
	  
	  wait for clk_period;
	  k_valid<='0';
	  
	  --Test 1
	  
	  wait until ready='1';
      --Plain text : 0x3243f6a8885a308d313198a2e0370734
	  cipher<=x"3925841d02dc09fbdc118597196a0b32";
	  c_valid<='1';
	  
	  wait for clk_period;
	  c_valid<='0';
	  
	  wait until out_valid='1';
	  wait for 1 ns;
	  if(x"3243f6a8885a308d313198a2e0370734" /= text_out) then 
	     write(LW,string'("Decryption Error!!!"));
	     write(LW,string'("   Expected : 0x3243f6a8885a308d313198a2e0370734 Received : 0x"));
		 hwrite(LW,text_out);
	     writeline(output,LW);
		 error:=1;
	  end if; 

	  --Test 2
	  
	  wait until ready='1';
	  --Plain Text : 0x54686973206973206120736563726574
	  cipher<=x"65bf63df7687d1c1b38eda29d416666d";
	  c_valid<='1';
	  
	  wait for clk_period;
	  c_valid<='0';
	  
	  wait until out_valid='1';
	  wait for 1 ns; --Delta delay
	  if(x"54686973206973206120736563726574" /= text_out) then 
	     write(LW,string'("Decryption Error!!!"));
	     write(LW,string'("   Expected : 0x54686973206973206120736563726574 Received : 0x"));
		 hwrite(LW,text_out);
	     writeline(output,LW);
		 error:=1;
	  end if; 
	  
	  --Test 3
	  
	  wait until ready='1';
	  --Plain Text : 0xCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
	  cipher<=x"7e9e9ed1c91b46e545bc1c2399f7def9";
	  c_valid<='1';
	  
	  wait for clk_period;
	  c_valid<='0';

	  wait until out_valid='1';
	  wait for 1 ns;
	  if(x"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC" /= text_out) then 
	     write(LW,string'("Decryption Error!!!"));
	     write(LW,string'("   Expected : 0xCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC Received : 0x"));
		 hwrite(LW,text_out);
	     writeline(output,LW);
		 error:=1;
	  end if;	  
	  
	  if(error = 0) then
	     write(LW,string'("********************************************"));
		 writeline(output,LW); 	
	     write(LW,        string'("            All test case passed!!!         "));
		 writeline(output,LW);
	     write(LW,string'("********************************************"));
		 writeline(output,LW);		 
	  else
	    write(LW,string'("********************************************"));
		writeline(output,LW);
        write(LW,        string'("         Some test case failed!!!!          "));
		writeline(output,LW);
	    write(LW,string'("********************************************"));
		writeline(output,LW);
      end if;	  
	
      assert false report"This is end of simulation not test failure!!!" severity failure;	--End simulation
	  
	wait;  
	end process;
	

end beh_tb_AES_decrypt;