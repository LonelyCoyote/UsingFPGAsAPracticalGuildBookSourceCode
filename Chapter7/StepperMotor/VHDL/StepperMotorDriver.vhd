----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


----------------------------------------------------------------------------------
entity StepperMotorDriver is
  port
  (
    clk:in std_logic;
    step:in std_logic;  -- one shot to move one step forward/backward
    dir:in std_logic; -- the direction we want to move in
    enabled:in std_logic;   -- low to disengage the stepper motor (free run)
    ph1:out std_logic;      -- to coil 1 of motor
    ph2:out std_logic;      -- to coil 2 of motor
    ph3:out std_logic;      -- to coil 3 of motor
    ph4:out std_logic       -- to coil 4 of motor
  );
end StepperMotorDriver;

----------------------------------------------------------------------------------
architecture rtl of StepperMotorDriver is
  signal sig_ph1:std_logic:='0';
  signal sig_ph2:std_logic:='0';
  signal sig_ph3:std_logic:='0';
  signal sig_ph4:std_logic:='0';
  signal sig_ring:std_logic_vector(3 downto 0):=b"0000";
begin
  ph1<=sig_ph1 when enabled='1' else '0';
  ph2<=sig_ph2 when enabled='1' else '0';
  ph3<=sig_ph3 when enabled='1' else '0';
  ph4<=sig_ph4 when enabled='1' else '0';
  sig_ph1<=sig_ring(0);
  sig_ph2<=sig_ring(1);
  sig_ph3<=sig_ring(2);
  sig_ph4<=sig_ring(3);
  
  process(clk)
    variable phase:natural range 0 to 3:=3;
  begin
    if rising_edge(clk) then
      if step='1' then
        if dir='1' then
          if phase=3 then
            phase:=0;
          else 
            phase:=phase+1;
          end if;
        else
          if phase=0 then
            phase:=3;
          else
            phase:=phase-1;
          end if;
        end if;
        
        sig_ring<=(others=>'0');
        sig_ring(phase)<='1';
        
      end if;
    end if;
  end process;
  
  
  


end rtl;
