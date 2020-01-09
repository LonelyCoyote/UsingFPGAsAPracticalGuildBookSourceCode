----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2019 12:56:53 PM
-- Design Name: 
-- Module Name: BCDTo7Segment - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BCDTo7Segment is
  port
  (
    bcd:in std_logic_vector(3 downto 0);
    sevenSegment:out std_logic_vector(6 downto 0)
  );
end;

architecture rtl of BCDTo7Segment is
  type lookUp is array(0 to 9) of std_logic_vector(6 downto 0);
  constant sevenseglookUp:lookUp:=(
    b"1111110",  -- 0
    b"0110000",  -- 1
    b"1101101",  -- 2
    b"1111001",  -- 3
    b"0110011",  -- 4
    b"1011011",  -- 5
    b"1011111",  -- 6
    b"1110000",  -- 7
    b"1111111",  -- 8
    b"1111011"   -- 9
  );
begin
  sevenSegment<=sevenseglookUp(to_integer(unsigned(bcd)));
end;

-- EOF -------------------------------------------------------------------------


