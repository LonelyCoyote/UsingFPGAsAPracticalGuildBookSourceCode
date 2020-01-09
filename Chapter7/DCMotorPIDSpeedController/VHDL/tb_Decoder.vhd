----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Decoder is end;

architecture sim of tb_Decoder is
  signal clk:std_logic;
  signal dir:std_logic;
  signal counter:std_logic_vector(15 downto 0);
  signal A:std_logic;
  signal B:std_logic;
  signal clear_counter:std_logic:='0';
begin
  enc:entity work.model_Encoder generic map(CLKS_PER_PULSE=>100)
    port map(clk=>clk,dir=>dir,A=>A,B=>B);
  
  dec:entity work.Decoder port map(clk=>clk,counter=>counter,clear_counter=>clear_counter,A=>A,B=>B);
  
  clk_gen:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  stim:process
  begin
    dir<='0';
    
    wait for 1 ms;
    
    dir<='1';

    wait;
  end process;



end;
