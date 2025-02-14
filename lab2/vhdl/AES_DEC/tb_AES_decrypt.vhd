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
  
  test_process: process
    file key_file: text open read_mode is "Key.txt";
    file cipher_file: text open read_mode is "Ciphertextin.txt";
    file plaintext_file: text open read_mode is "Plaintextin.txt";
    variable key_line, cipher_line, plaintext_line: line;
    variable key_vec, cipher_vec, expected_vec: std_logic_vector(127 downto 0);
    variable test_count: integer := 0;
    variable error_count: integer := 0;
  begin
    reset <= '0';
    k_valid <= '0';
    c_valid <= '0';
    wait for clk_period;
    reset <= '1';

    while not endfile(key_file) loop
      readline(key_file, key_line);
      hread(key_line, key_vec);
      readline(cipher_file, cipher_line);
      hread(cipher_line, cipher_vec);
      readline(plaintext_file, plaintext_line);
      hread(plaintext_line, expected_vec);

      test_count := test_count + 1;
      
      wait until ready='1';
      key <= key_vec;
      cipher <= cipher_vec;
      k_valid <= '1';
      c_valid <= '1';
      
      wait for clk_period;
      k_valid <= '0';
      c_valid <= '0';
      
      wait until out_valid='1';
      wait for 1 ns; -- Delta delay
      
      if expected_vec /= text_out then
        report "Test case " & integer'image(test_count) & " failed!";
        report "Expected: " & to_hstring(expected_vec);
        report "Received: " & to_hstring(text_out);
        error_count := error_count + 1;
      end if;
    end loop;

    if error_count = 0 then
      report "All " & integer'image(test_count) & " test cases passed!";
    else
      report integer'image(error_count) & "/" & integer'image(test_count) & " test cases failed!";
    end if;
    
    assert false report "Simulation completed" severity failure;
    wait;
  end process;
end beh_tb_AES_decrypt;