----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_OneWireSendBit is end;

architecture sim of tb_OneWireSendBit is
  signal clk:std_logic;
  signal bitv:std_logic;
  signal start:std_logic;
  signal done:std_logic;
  signal one_wire:std_logic;
begin
  uut:entity work.OneWireSendBit generic map(CLKS_PER_MICROSECOND=>100)
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
    bitv<='0';
    start<='0';
    wait for 10 us;
    
    -- send a logic 0 bit
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';
    
    -- send a logic 1 bit
    bitv<='1';
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';
    
    -- send a logic 0 bit
    bitv<='0';
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';
  
    -- send a logic 1 bit
    bitv<='1';
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';
  
    wait;
  end process;




end sim;
