----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_OneWireTemperatureSensor_MAX31820 is end;

architecture sim of tb_OneWireTemperatureSensor_MAX31820 is
  signal clk:std_logic;
  signal init:std_logic;
  signal start:std_logic;
  signal done:std_logic;
  signal EightDotFour:std_logic_vector(11 downto 0);
  
  signal one_wire:std_logic:='Z';
begin
  uut:entity work.OneWireTemperatureSensor_MAX31820
    generic map(CLKS_PER_MICROSECOND=>20)
    port map(clk=>clk,init=>init,start=>start,done=>done,EightDotFour=>EightDotFour,one_wire=>one_wire);

  clk_gen:process
  begin
    clk<='0';
    wait for 2 ns;
    clk<='1';
    wait for 2 ns;
  end process;
  
  stim_proc:process
  begin
    init<='0';
    start<='0';
    
    wait for 1 us;
    
    -- test init of device
    wait until rising_edge(clk);
    init<='1';
    wait until rising_edge(clk);
    init<='0';
    
    wait until done='1';
    
    -- test measurement 1
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    
    wait for 1 ms;
    one_wire<='H';
    
    wait until done='1';
    one_wire<='Z';
    
    -- test measurement 2
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    
    wait for 1 ms;
    one_wire<='H';
    
    wait until done='1';
    one_wire<='Z';




    wait;
    
  end process;
  
  

end;


