----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_DegreesToPWMValue is end;

architecture sim of tb_DegreesToPWMValue is
  signal degreesIn:std_logic_vector(15 downto 0);
  signal pwm_result:std_logic_vector(31 downto 0);
begin
  uut:entity work.DegreesToPWMValue port map(degreesIn=>degreesIn,pwm_result=>pwm_result);

  stim:process
  begin
    -- Move to 50 degrees
    degreesIn<=x"3200";
    wait for 1 us;
    
    -- Move to -50 degrees
    degreesIn<=not x"31FF";
    wait for 1 us;
  
    -- Move to 60 degrees
    degreesIn<=x"3C00";  
    wait for 1 us;
    
    -- Move to -60 degrees
    degreesIn<=not x"3BFF";
    wait for 1 us;
    
    -- Move to 45.5 degrees
    degreesIn<=x"2D80";
    wait for 1 us;
    
    -- Test bind limits
    -- move 90 should automatically move to 60 max
    degreesIn<=x"5A00";
    wait for 1 us;
    
    -- move to negative 90 should automatically move to 60 max
    degreesIn<=not x"59FF";
    wait for 1 us;
    
    
    
  
  
    wait;
  end process;



end;
