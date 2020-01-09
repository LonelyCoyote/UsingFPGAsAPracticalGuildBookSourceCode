----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity OneWireRcvBit is
  generic
  (
    CLKS_PER_MICROSECOND:natural:=48
  );
  port
  (
    clk:in std_logic;
    bitv:out std_logic;  -- value of the bit
    start:in std_logic;
    done:out std_logic;
    
    -- To FPGA IO 
    one_wire:inout std_logic
  );
end;

architecture rtl of OneWireRcvBit is
  constant READ_HOLD_LOW:natural:=CLKS_PER_MICROSECOND*6;
  constant READ_SAMPLE_TIME:natural:=CLKS_PER_MICROSECOND*15;
  constant TOTAL_BIT_TIME:natural:=CLKS_PER_MICROSECOND*70;
  signal sig_bitv:std_logic:='0';
  signal sig_done:std_logic:='1';
  signal sig_one_wire:std_logic:='1';
  signal clk_counter:natural range 0 to TOTAL_BIT_TIME:=0;
  signal sig_one_wire_read:std_logic;
begin
  bitv<=sig_bitv;
  done<=sig_done;
  one_wire<='Z' when sig_one_wire='1' else '0';
  
  process(clk)
  begin
    if rising_edge(clk) then
      sig_done<='1';
      sig_one_wire<='1';
      if start='1' and clk_counter=0 then
        sig_done<='0';
        clk_counter<=1;
      elsif clk_counter>0 then
        sig_done<='0';
        
        -- pulse line low to initiate read
        if clk_counter<READ_HOLD_LOW then
          sig_one_wire<='0';  
        end if;
        
        -- grab bit at sample point
        if clk_counter=READ_SAMPLE_TIME+3 then
          sig_bitv<=sig_one_wire_read;
        end if;
        
        -- wait for bit time to complete
        if clk_counter=TOTAL_BIT_TIME then
          clk_counter<=0;
        else
          clk_counter<=clk_counter+1;
        end if;
        
      end if;
    end if;
  end process;
  
syncro:entity work.ThreeStageClkSync port map(clk=>clk,asyncsig=>one_wire,syncsig=>sig_one_wire_read);



end rtl;

-- EOF -------------------------------------------------------------------------













