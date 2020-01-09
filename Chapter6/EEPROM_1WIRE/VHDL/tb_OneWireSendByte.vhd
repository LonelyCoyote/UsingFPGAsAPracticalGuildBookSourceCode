----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_OneWireSendByte is end;

architecture sim of tb_OneWireSendByte is
  signal clk:std_logic;
  signal byte:std_logic_vector(7 downto 0);
  signal start:std_logic;
  signal done:std_logic;
  signal one_wire:std_logic:='Z';
begin
  uut:entity work.OneWireSendByte generic map(CLKS_PER_MICROSECOND=>100)
    port map(clk=>clk,byte=>byte,start=>start,done=>done,one_wire=>one_wire);

  clk_gen:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  imp:process
  begin
    byte<=x"00";
    start<='0';
    
    wait for 50 us;
    
    -- Send first byte 00
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';
    
    -- Send second byte AA
    byte<=x"AA";
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';
    
    -- Send third byte 55
    byte<=x"55";
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';

    -- Send fouth byte FF
    byte<=x"FF";
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    wait until done='1';
    wait for 50 us;
  
    wait;
  end process;


end;
