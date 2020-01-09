library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_LEDPWMLoader is end;

architecture sim of tb_LEDPWMLoader is
  signal clk:std_logic;
  signal pwm_val:std_logic_vector(15 downto 0);
  signal write:std_logic;
  signal leds:std_logic_vector(7 downto 0);
begin
  uut:entity work.LEDPWMLoader generic map(PERIOD_IN_CLK_CYCLES=>x"0010") port map(clk=>clk,pwm_val=>pwm_val,write=>write,leds=>leds);
  
  gen_clk:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  stim:process
  begin
    pwm_val<=x"0000";
    write<='0';
    
    wait for 50 ns;
    
    wait until falling_edge(clk);
    pwm_val<=x"0001";
    write<='1';
    wait until falling_edge(clk);

    pwm_val<=x"0002";
    wait until falling_edge(clk);

    pwm_val<=x"0003";
    wait until falling_edge(clk);

    pwm_val<=x"0004";
    wait until falling_edge(clk);

    pwm_val<=x"0005";
    wait until falling_edge(clk);

    pwm_val<=x"0006";
    wait until falling_edge(clk);

    pwm_val<=x"0007";
    wait until falling_edge(clk);

    pwm_val<=x"0008";
    wait until falling_edge(clk);
    write<='0';
    pwm_val<=x"0000";

    wait;

  end process;


end;
