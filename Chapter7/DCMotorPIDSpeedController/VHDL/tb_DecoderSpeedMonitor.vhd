----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_DecoderSpeedMonitor is end;

architecture sim of tb_DecoderSpeedMonitor is
  signal clk:std_logic;
  signal dir:std_logic:='0';
  signal A:std_logic;
  signal B:std_logic;
  signal current_speed:std_logic_vector(15 downto 0);
  
begin
  encoder:entity work.model_Encoder generic map(CLKS_PER_PULSE=>10)
    port map(clk=>clk,dir=>dir,A=>A,B=>B);
  
  speed_monitor:entity work.DecoderSpeedMonitor generic map(GATE_TIME_IN_CLK_CYCLES=>1000)
    port map(clk=>clk,current_speed=>current_speed,A=>A,B=>B);
    
  gen_clk:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  stim_proc:process
  begin
    wait for 500 us;
    
    dir<='1';
    wait;
  end process;

end;
