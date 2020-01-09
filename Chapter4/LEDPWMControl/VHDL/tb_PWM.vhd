
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_PWM is end;

architecture sim of tb_PWM is
  signal clk:std_logic;
  signal val:std_logic_vector(15 downto 0);
  signal ld:std_logic;
  signal pwm:std_logic;
begin
  uut:entity work.PWM generic map(PERIOD_IN_CLK_CYCLES=>x"0010") port map(clk=>clk,val=>val,ld=>ld,pwm=>pwm);
  
  clk_gen:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  main_proc:process
  begin
    val<=x"0000";
    ld<='0';
    wait until rising_edge(clk);
    ld<='1';
    wait until rising_edge(clk);
    ld<='0';
    
    wait for 1 us;    
    val<=x"0001";
    ld<='0';
    wait until rising_edge(clk);
    ld<='1';
    wait until rising_edge(clk);
    ld<='0';

    wait for 1 us;    
    val<=x"0008";
    ld<='0';
    wait until rising_edge(clk);
    ld<='1';
    wait until rising_edge(clk);
    ld<='0';

    wait for 1 us;    
    val<=x"000F";
    ld<='0';
    wait until rising_edge(clk);
    ld<='1';
    wait until rising_edge(clk);
    ld<='0';


    wait for 1 us;    
    val<=x"0010";
    ld<='0';
    wait until rising_edge(clk);
    ld<='1';
    wait until rising_edge(clk);
    ld<='0';

    wait for 1 us;    
    val<=x"0001";
    ld<='0';
    wait until rising_edge(clk);
    ld<='1';
    wait until rising_edge(clk);
    ld<='0';

    wait for 1 us;    
    val<=x"0000";
    ld<='0';
    wait until rising_edge(clk);
    ld<='1';
    wait until rising_edge(clk);
    ld<='0';


    wait;
  end process;


end;
