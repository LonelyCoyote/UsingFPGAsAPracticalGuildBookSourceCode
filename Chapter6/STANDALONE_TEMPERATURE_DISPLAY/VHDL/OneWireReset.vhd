----------------------------------------------------------------------------------
-- one component of the one wire interface, this implements the standard one
-- wire reset timing and gets the acknowledgment from one or more devices
-- on the 1 wire bus
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity OneWireReset is
  generic
  (
    CLKS_PER_MICROSECOND:natural:=48
  );
  port
  (
    clk:in std_logic;
    reset: in std_logic;  -- one shot to start the reset
    done: out std_logic;
    devices_present:out std_logic;  -- high when we find a device present low otherwise
    
    -- To FPGA IO
    one_wire:inout std_logic
  );
end;

architecture rtl of OneWireReset is
  constant HOLD_LOW:natural:=CLKS_PER_MICROSECOND*480;
  constant READ_ACK:natural:=CLKS_PER_MICROSECOND*550;
  constant FINISH:natural:=CLKS_PER_MICROSECOND*960;
  signal clk_counter:natural range 0 to FINISH:=0;
  signal sig_done:std_logic:='1';
  signal sig_devices_present:std_logic:='0';
  signal sig_one_wire:std_logic:='1';
  signal sig_one_wire_read:std_logic;
begin
  done<=sig_done;
  devices_present<=sig_devices_present;
  one_wire<='Z' when sig_one_wire='1' else '0';
  
  syncro:entity work.ThreeStageClkSync port map(clk=>clk,asyncsig=>one_wire,syncsig=>sig_one_wire_read);
  
  process(clk)
  begin
    if rising_edge(clk) then
      sig_done<='1';
      if reset='1' and clk_counter=0 then
        sig_devices_present<='0';
        clk_counter<=1;
        sig_done<='0';
      elsif clk_counter>0 then
        sig_done<='0';
        
        if clk_counter<HOLD_LOW then
          sig_one_wire<='0';
        else
          sig_one_wire<='1';
        end if;
        
        if clk_counter=READ_ACK+3 then
          sig_devices_present<=not sig_one_wire_read;
        end if;
        
        if clk_counter=FINISH then
          sig_done<='1';
          clk_counter<=0;
        else
          clk_counter<=clk_counter+1;
        end if;
    
      end if;
    end if;
  end process;
end;

-- EOF -------------------------------------------------------------------------