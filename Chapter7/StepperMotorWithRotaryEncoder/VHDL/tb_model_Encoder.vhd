----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_model_Encoder is end;

architecture sim of tb_model_Encoder is
  signal clk:std_logic;
  signal dir:std_logic;
  signal A:std_logic;
  signal B:std_logic;
begin
  uut:entity work.model_Encoder generic map(CLKS_PER_PULSE=>100)
    port map(clk=>clk,dir=>dir,A=>A,B=>B);
    
    clk_gen:process
    begin
      clk<='0';
      wait for 5 ns;
      clk<='1';
      wait for 5 ns;
    end process;
    
    stim_proc:process
    begin
      dir<='0';
      
      wait for 100 us;
      
      dir<='1';
      
      
      
      wait;
    end process;


end sim;
