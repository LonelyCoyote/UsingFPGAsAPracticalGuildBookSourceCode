----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_OneWireRcvBit is end;

architecture sim of tb_OneWireRcvBit is
  signal clk:std_logic;
  signal bitv:std_logic;
  signal start:std_logic;
  signal done:std_logic;
  signal one_wire:std_logic:='Z';
begin
  uut:entity work.OneWireRcvBit generic map(CLKS_PER_MICROSECOND=>100)
    port map(clk=>clk,bitv=>bitv,start=>start,done=>done,one_wire=>one_wire);
    
  clk_gen:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  stim_proc:process
  begin
    start<='0';
    wait for 10 us;
    
    -- receive a high bit
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';
    
    -- receive a low bit
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait for 5 us;
    one_wire<='0';
    wait for 55 us;
    one_wire<='Z';
    wait until done='1';
  
    -- receive a high bit
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';
    
    -- receive a low bit
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait for 5 us;
    one_wire<='0';
    wait for 55 us;
    one_wire<='Z';
    wait until done='1';
  
    wait;
  end process;




end sim;
