----------------------------------------------------------------------------------
-- There is not much to the R2R DAC, mainly just a clock, the input to the DAC
-- and a one shot load signal
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity R2RDAC is
  port
  (
    clk:in std_logic;
    load:in std_logic;  -- one shot
    val:in std_logic_vector(7 downto 0);
    dac_out:out std_logic_vector(7 downto 0)
  );
end R2RDAC;

----------------------------------------------------------------------------------
architecture rtl of R2RDAC is
  signal sig_dac_out:std_logic_vector(7 downto 0):=(others=>'0');
begin
  dac_out<=sig_dac_out;

  process(clk) 
  begin
    if rising_edge(clk) then
      if load='1' then
        sig_dac_out<=val;  
      end if;
    end if;
  end process;

end rtl;

-- EOF ---------------------------------------------------------------------------