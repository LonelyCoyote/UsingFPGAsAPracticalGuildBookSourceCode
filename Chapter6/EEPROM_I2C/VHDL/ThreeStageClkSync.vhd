----------------------------------------------------------------------------------
-- Registers a asyncronous signal to the clock to eliminate metastability issues
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity ThreeStageClkSync is
  port
  (
    clk:in std_logic;
    asyncsig:in std_logic;
    syncsig:out std_logic
  );
end;

----------------------------------------------------------------------------------
architecture rtl of ThreeStageClkSync is
  signal sig_syncsig:std_logic:='0';
  signal sig_s1:std_logic:='0';
  signal sig_s2:std_logic:='0';
begin
  syncsig<=sig_syncsig;
  
  syncro:process(clk)
  begin
    if rising_edge(clk) then
      sig_s1<=asyncsig;
      sig_s2<=sig_s1;
      sig_syncsig<=sig_s2;
    end if;
  end process;
  
end;
