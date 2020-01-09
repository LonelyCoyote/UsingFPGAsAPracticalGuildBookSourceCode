----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity tb_StepperMotorDriver is end;

----------------------------------------------------------------------------------
architecture sim of tb_StepperMotorDriver is
  signal clk:std_logic;
  signal step:std_logic;
  signal dir:std_logic;
  signal enabled:std_logic;
  signal ph1:std_logic;
  signal ph2:std_logic;
  signal ph3:std_logic;
  signal ph4:std_logic;
begin

  uut:entity work.StepperMotorDriver port map(clk=>clk,step=>step,dir=>dir,enabled=>enabled,
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
    
    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;
    

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;

    dir<='0';

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;

    wait until rising_edge(clk);
    step<='1';
    wait until rising_edge(clk);
    step<='0';
    wait for 50 ns;
  
    wait;
  end process;
  

end sim;
