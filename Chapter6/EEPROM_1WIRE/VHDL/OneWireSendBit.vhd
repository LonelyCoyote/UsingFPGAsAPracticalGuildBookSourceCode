----------------------------------------------------------------------------------
-- Sends one bit over one wire
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity OneWireSendBit is
  generic
  (
    CLKS_PER_MICROSECOND:natural:=48
  );
  port
  (
    clk:in std_logic;
    bitv:in std_logic;  -- value of the bit
    start:in std_logic;
    done:out std_logic;
    
    -- To FPGA IO 
    one_wire:inout std_logic
  );
end;

----------------------------------------------------------------------------------
architecture rtl of OneWireSendBit is
  constant HOLD_LOW_HI_BIT:natural:=CLKS_PER_MICROSECOND*6;
  constant HOLD_LOW_LO_BIT:natural:=CLKS_PER_MICROSECOND*60;
  constant TOTAL_BIT_TIME:natural:=CLKS_PER_MICROSECOND*70;
  signal sig_done:std_logic:='1';
  signal clk_counter:natural range 0 to TOTAL_BIT_TIME:=0;
  signal sig_one_wire:std_logic:='1';
begin
  done<=sig_done;
  one_wire<='Z' when sig_one_wire='1' else '0';

  
  process(clk)
  begin
    if rising_edge(clk) then
      sig_done<='1';
      sig_one_wire<='1';
      
      -- Wait for start
      if start='1' and clk_counter=0 then
        clk_counter<=1;
        sig_done<='0';
      -- started, do the transfer until clk_counter=0 again
      elsif clk_counter>0 then
        sig_done<='0';
        
        -- hold line low appropriate amount of time based on bit being transmitted
        if bitv='1' then
          if clk_counter<HOLD_LOW_HI_BIT then
            sig_one_wire<='0';    
          end if;
        else
          if clk_counter<HOLD_LOW_LO_BIT then
            sig_one_wire<='0';
          end if;
        end if;
        
        -- Reset after entire bit time has elapsed or increment counter
        if clk_counter=TOTAL_BIT_TIME then
          clk_counter<=0;
        else
          clk_counter<=clk_counter+1;
        end if;
        
      end if;
    end if;
  end process;


end;
