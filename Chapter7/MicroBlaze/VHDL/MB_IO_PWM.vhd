----------------------------------------------------------------------------------
-- Micro-Blaze IO Controlled PWM
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MB_IO_PWM is
  generic
  (
    IO_ADDRESS:std_logic_vector(31 downto 0);
    PERIOD_IN_CLK_CYCLES:std_logic_vector(15 downto 0)
  );
  port
  (
    clk: in std_logic;
    address: in std_logic_vector(31 downto 0);
    write_strobe: in std_logic;
    read_strobe: in std_logic;
    write_val:in std_logic_vector(31 downto 0);
    read_val:inout std_logic_vector(31 downto 0);
    pwm: out std_logic
  );
end MB_IO_PWM;

architecture rtl of MB_IO_PWM is
  signal sig_write:std_logic;
  signal sig_read:std_logic;
  signal sig_read_val:std_logic_vector(31 downto 0):=(others=>'0');
begin
  addr_decode:entity work.AddressDecoder
  generic map(WRITE_ADDRESS=>IO_ADDRESS,READ_ADDRESS=>IO_ADDRESS,WRITABLE=>'1',READABLE=>'1')
  port map
  (
    address=>address,
    data_in=>sig_read_val,
    data_out=>read_val,
    write_strobe_all=>write_strobe,
    read_strobe_all=>read_strobe,
    write_strobe=>sig_write,
    read_strobe=>sig_read
  );
  
  -- allow the processor to verify this entity works by at least wrapping around
  -- the value written to the PWM back to the output bus
  process(clk)
  begin
    if rising_edge(clk) then
      if sig_write='1' then
        sig_read_val(15 downto 0)<=write_val(15 downto 0);
      end if;
    end if;
  end process;
  
  pwm1:entity work.PWM generic map(PERIOD_IN_CLK_CYCLES=>PERIOD_IN_CLK_CYCLES)
  port map(clk=>clk,val=>write_val(15 downto 0),ld=>sig_write,pwm=>pwm);

end rtl;

















