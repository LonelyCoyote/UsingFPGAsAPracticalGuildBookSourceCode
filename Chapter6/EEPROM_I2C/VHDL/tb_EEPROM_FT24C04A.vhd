----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_EEPROM_FT24C04A is end;

architecture sim of tb_EEPROM_FT24C04A is
  signal clk:std_logic;
  signal address:std_logic_vector(8 downto 0);
  signal data_in:std_logic_vector(7 downto 0);
  signal data_out:std_logic_vector(7 downto 0);
  signal read_write:std_logic;
  signal nack:std_logic;
  signal start:std_logic;
  signal done:std_logic;
  signal A0:std_logic:='0';
  signal A1:std_logic:='0';
  
  signal SCK:std_logic;
  signal SDA:std_logic;
begin
  clk_gen:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  stim_proc:process
  begin
    -- Write some data to the EEPROM
    address<=b"010101101";
    data_in<=x"A5";
    read_write<='0';
    start<='0';
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';
    
    wait for 100 ns;
    
    -- Read some data to the EEPROM
    address<=b"010101101";
    data_in<=x"5A";
    read_write<='1';
    start<='0';
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';
    
    
    
    wait;
  end process;

  uut:entity work.EEPROM_FT24C04A generic map(I2C_CLOCKS_PER_TRANSITION=>100)
    port map
    (
      clk=>clk,
      address=>address,
      data_in=>data_in,
      data_out=>data_out,
      read_write=>read_write,
      nack=>nack,
      start=>start,
      done=>done,
      A0=>A0,
      A1=>A1,
      SCK=>SCK,
      SDA=>SDA
    );

end;
