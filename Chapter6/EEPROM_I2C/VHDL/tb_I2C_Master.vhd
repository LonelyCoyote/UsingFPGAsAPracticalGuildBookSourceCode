----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_I2C_Master is end;

architecture sim of tb_I2C_Master is
  signal clk:std_logic;
  signal load:std_logic;
  signal done:std_logic;
  signal reset:std_logic;
  signal start:std_logic;
  signal stop:std_logic;
  signal s_data_in:std_logic_vector(7 downto 0);
  signal s_data_out:std_logic_vector(7 downto 0);
  signal nack:std_logic;
  
  signal SCK:std_logic:='U';
  signal SDA:std_logic:='U';
begin
  uut:entity work.I2C_Master generic map(CLOCKS_PER_TRANSITION=>50)
    port map (
      clk=>clk,
      load=>load,
      done=>done,
      reset=>reset,
      start=>start,
      stop=>stop,
      s_data_in=>s_data_in,
      s_data_out=>s_data_out,
      nack=>nack,
      SCK=>SCK,
      SDA=>SDA
      );
      
  clk_gen:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  stim:process
  begin
    s_data_in<=x"AA";
    reset<='0';
    start<='1';
    stop<='0';
    load<='0';
    
    wait for 100 ns;
    wait until rising_edge(clk);
    load<='1';
    wait until rising_edge(clk);
    load<='0';
    
    wait until done='1';
    
    s_data_in<=x"55";
    start<='0';
    stop<='0';
    wait until rising_edge(clk);
    load<='1';
    wait until rising_edge(clk);
    load<='0';

    wait until done='1';
    
    -- do a restart with receive
    s_data_in<=x"A1";
    start<='1';
    stop<='0';
    wait until rising_edge(clk);
    load<='1';
    wait until rising_edge(clk);
    load<='0';

    wait until done='1';
    
    -- read one byte with stop
    start<='0';
    stop<='1';
    wait until rising_edge(clk);
    load<='1';
    wait until rising_edge(clk);
    load<='0';
    
    wait;
  end process;

end;
