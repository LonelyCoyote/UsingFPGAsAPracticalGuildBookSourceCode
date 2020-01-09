library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_OneWireReset is end;

architecture sim of tb_OneWireReset is
  signal clk:std_logic;
  signal reset:std_logic;
  signal done:std_logic;
  signal devices_present:std_logic;
  signal one_wire:std_logic:='Z';
begin
  uut:entity work.OneWireReset generic map(CLKS_PER_MICROSECOND=>100)
  port map(clk=>clk,reset=>reset,done=>done,devices_present=>devices_present,one_wire=>one_wire);
  
  clk_gen:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  stim:process
  begin
    reset<='0';
    
    wait for 50 ns;
    wait until rising_edge(clk);
    reset<='1';
    wait until rising_edge(clk);
    reset<='0';
    
    wait for 500 us;
    one_wire<='0';
    wait for 60 us;
    one_wire<='Z';
    
    wait until done='1';
    
    -- Verify it can be used multiple times, check no device present
    wait for 300 us;
    
    wait for 50 ns;
    wait until rising_edge(clk);
    reset<='1';
    wait until rising_edge(clk);
    reset<='0';
    
    --wait for 500 us;
    --one_wire<='0';
    --wait for 60 us;
    --one_wire<='Z';
    
  
    wait;
  end process;




end sim;
