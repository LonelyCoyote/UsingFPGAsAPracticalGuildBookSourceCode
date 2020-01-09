----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_DisplayFixedPointOn7Segment is end;

architecture sim of tb_DisplayFixedPointOn7Segment is
  signal clk:std_logic;
  signal EigthDotFour:std_logic_vector(11 downto 0);
  signal A:std_logic;
  signal B:std_logic;
  signal C:std_logic;
  signal D:std_logic;
  signal E:std_logic;
  signal F:std_logic;
  signal G:std_logic;
  signal DP:std_logic;
  signal Digit1:std_logic;
  signal Digit2:std_logic;
  signal Digit3:std_logic;
  signal Digit4:std_logic;
begin
  uut:entity work.DisplayFixedPointOn7Segment generic map(CLKS_BETWEEN_DIGIT_UPDATES=>10)
  port map(clk=>clk,EigthDotFour=>EigthDotFour,A=>A,B=>B,C=>C,D=>D,E=>E,F=>F,G=>G,DP=>DP,
  Digit1=>Digit1,Digit2=>Digit2,Digit3=>Digit3,Digit4=>Digit4);
 
  gen_clk:process
  begin
    clk<='0';
    wait for 10 ns;
    clk<='1';
    wait for 10 ns;
  end process;
  
  stim:process
  begin
  EigthDotFour<=b"00011010_1000";
  wait for 1 us;
  EigthDotFour<=b"00011011_1100";
  wait for 1 us;
  EigthDotFour<=b"00011110_1110";
  wait for 1 us;
  EigthDotFour<=b"00011111_1111";
  
  
  wait;
  end process;




end;
