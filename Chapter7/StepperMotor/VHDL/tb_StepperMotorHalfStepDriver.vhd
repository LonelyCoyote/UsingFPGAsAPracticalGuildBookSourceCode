----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity tb_StepperMotorHalfStepDriver is end;

architecture sim of tb_StepperMotorHalfStepDriver is
  signal clk:std_logic;
  signal step:std_logic;
  signal dir:std_logic;
  signal enabled:std_logic;
  signal ph1:std_logic;
  signal ph2:std_logic;
  signal ph3:std_logic;
  signal ph4:std_logic;
begin

  uut:entity work.StepperMotorHalfStepDriver port map(clk=>clk,step=>step,dir=>dir,enabled=>enabled,
    ph1=>ph1,ph2=>ph2,ph3=>ph3,ph4=>ph4);
    
  clk_gen:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  stim:process
  begin
    enabled<='1';
    dir<='1';
    step<='0';
    
    wait for 50 ns;
    
    for x in 0 to 50 loop
      wait until rising_edge(clk);
      step<='1';
      wait until rising_edge(clk);
      step<='0';
      wait for 50 ns;
    end loop;
    
    wait for 200 ns;
    
    dir<='0';
    for x in 0 to 50 loop
      wait until rising_edge(clk);
      step<='1';
      wait until rising_edge(clk);
      step<='0';
      wait for 50 ns;
    end loop;
    
    
  
    wait;
  end process;

end;
