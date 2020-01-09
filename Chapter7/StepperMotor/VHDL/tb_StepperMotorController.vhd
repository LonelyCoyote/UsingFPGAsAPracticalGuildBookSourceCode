----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_StepperMotorController is end;

architecture sim of tb_StepperMotorController is
  signal clk:std_logic;
  signal dir:std_logic;
  signal pulses_to_move:std_logic_vector(15 downto 0);
  signal microseconds_between_pulses_lo_word:std_logic_vector(15 downto 0);
  signal microseconds_between_pulses_hi_word:std_logic_vector(3 downto 0);
  signal enabled:std_logic;
  signal continuous:std_logic;
  signal start:std_logic;
  signal done:std_logic;
  
  signal ph1:std_logic;
  signal ph2:std_logic;
  signal ph3:std_logic;
  signal ph4:std_logic;
begin
  clk_gen:process
  begin
    clk<='0';
      wait for 5 ns;
    clk<='1';
      wait for 5 ns;
  end process;
  
  stim:process
  begin
    dir<='1';
    pulses_to_move<=x"000F";
    continuous<='0';
    enabled<='1';
    microseconds_between_pulses_lo_word<=x"0002";
    microseconds_between_pulses_hi_word<=x"0";
    start<='0';
    
    wait for 50 ns;
    
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    
    wait until done='1';
    
    dir<='0';
    pulses_to_move<=x"0008";
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    
    wait until done='1';    
    
    continuous<='1';
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    
    wait for 500 us;
    
    continuous<='0';
    
  
    wait;
  end process;

  uut:entity work.StepperMotorController generic map(CLKS_PER_MICROSECOND=>100)
    port map(clk=>clk,dir=>dir,pulses_to_move=>pulses_to_move,
      microseconds_between_pulses_lo_word=>microseconds_between_pulses_lo_word,
      microseconds_between_pulses_hi_word=>microseconds_between_pulses_hi_word,
      enabled=>enabled,continuous=>continuous,start=>start,done=>done,
      ph1=>ph1,ph2=>ph2,ph3=>ph3,ph4=>ph4); 

end;
