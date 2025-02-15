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
	  
	  wait until ready='1';
	  cipher<=x"17adab5b1678deedc84d54a302858c54";
	  c_valid<='1';
	  
	  wait for clk_period;
	  c_valid<='0';
	  
	  wait until out_valid='1';
	  wait for 1 ns;
	  if(x"48656c6c6f2c204145532d4c61627321" /= text_out) then 
	     write(LW,string'("Decryption Error!!!"));
	     write(LW,string'("   Expected : 0x48656c6c6f2c204145532d4c61627321 Received : 0x"));
		 hwrite(LW,text_out);
	     writeline(output,LW);
		 error:=1;
	  end if; 

	  -- Test 2
	  wait until ready='1';
	  k_valid<='1';
	  key<=x"3c4fcf098815f7aba6d2c3d4e5f60718";
	  wait for clk_period;
	  k_valid<='0';
	  
	  wait until ready='1';
	  cipher<=x"609bf1cd737f9b8c6b7fcd078ab9c0c9";
	  c_valid<='1';
	  
	  wait for clk_period;
	  c_valid<='0';
	  
	  wait until out_valid='1';
	  wait for 1 ns;
	  if(x"53656375726520796f75722064617461" /= text_out) then 
	     write(LW,string'("Decryption Error!!!"));
	     write(LW,string'("   Expected : 0x53656375726520796f75722064617461 Received : 0x"));
		 hwrite(LW,text_out);
	     writeline(output,LW);
		 error:=1;
	  end if; 
	  
	  -- Test 3
	  wait until ready='1';
	  k_valid<='1';
	  key<=x"00112233445566778899aabbccddeeff";
	  wait for clk_period;
	  k_valid<='0';
	  
	  wait until ready='1';
	  cipher<=x"aff3e0f4f44dd7bfedb9d51f75d3a0db";
	  c_valid<='1';
	  
	  wait for clk_period;
	  c_valid<='0';
	  
	  wait until out_valid='1';
	  wait for 1 ns;
	  if(x"41455320656e6372797074696f6e2121" /= text_out) then 
	     write(LW,string'("Decryption Error!!!"));
	     write(LW,string'("   Expected : 0x41455320656e6372797074696f6e2121 Received : 0x"));
		 hwrite(LW,text_out);
	     writeline(output,LW);
		 error:=1;
	  end if;	  
	  
	  -- Test 4
	  wait until ready='1';
	  k_valid<='1';
	  key<=x"ffeeddccbbaa99887766554433221100";
	  wait for clk_period;
	  k_valid<='0';
	  
	  wait until ready='1';
	  cipher<=x"be95adc1d9c3330335f6919bda03536d";
	  c_valid<='1';
	  
	  wait for clk_period;
	  c_valid<='0';
	  
	  wait until out_valid='1';
	  wait for 1 ns;
	  if(x"43727970746f67726170687931323334" /= text_out) then 
	     write(LW,string'("Decryption Error!!!"));
	     write(LW,string'("   Expected : 0x43727970746f67726170687931323334 Received : 0x"));
		 hwrite(LW,text_out);
	     writeline(output,LW);
		 error:=1;
	  end if;

	  -- Test 5
	  wait until ready='1';
	  k_valid<='1';
	  key<=x"aabbccddeeff00112233445566778899";
	  wait for clk_period;
	  k_valid<='0';
	  
	  wait until ready='1';
	  cipher<=x"0679cb48d7a681ce322741c1b8ff3503";
	  c_valid<='1';
	  
	  wait for clk_period;
	  c_valid<='0';
	  
	  wait until out_valid='1';
	  wait for 1 ns;
	  if(x"54657374206d65737361676520233432" /= text_out) then 
	     write(LW,string'("Decryption Error!!!"));
	     write(LW,string'("   Expected : 0x54657374206d65737361676520233432 Received : 0x"));
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