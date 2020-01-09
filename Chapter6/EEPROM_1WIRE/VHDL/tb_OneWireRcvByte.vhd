----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_OneWireRcvByte is end;

----------------------------------------------------------------------------------
architecture sim of tb_OneWireRcvByte is
  signal clk:std_logic;
  signal byte:std_logic_vector(7 downto 0):=(others=>'Z');
  signal start:std_logic;
  signal done:std_logic;
  signal one_wire:std_logic:='Z';
begin
  uut:entity work.OneWireRcvByte generic map(CLKS_PER_MICROSECOND=>100)
    port map(clk=>clk,byte=>byte,start=>start,done=>done,one_wire=>one_wire);

  gen_clk:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  imp:process
  begin
    start<='0';
    
    wait for 50 us;
    
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';
    wait for 50 us;
    
    -- do it again except hold the bus low
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    one_wire<='0';
    wait until done='1';
    wait for 50 us;


    
    wait;
  end process;

end;

-- EOF -------------------------------------------------------------------------


















