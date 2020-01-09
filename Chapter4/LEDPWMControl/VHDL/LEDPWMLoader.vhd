--------------------------------------------------------------------------------
-- Allows us to load the LED PWM's using a PIPE In
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LEDPWMLoader is
  generic
  (
    PERIOD_IN_CLK_CYCLES:std_logic_vector(15 downto 0):=(7=>'1',others=>'0')  
  );
  port
  (
    clk: in std_logic;
    pwm_val:in std_logic_vector(15 downto 0);
    write:in std_logic;
    leds: out std_logic_vector(7 downto 0)
  );
end;

architecture rtl of LEDPWMLoader is
  signal sig_leds:std_logic_vector(7 downto 0);
  signal sig_pwm_loads:std_logic_vector(7 downto 0):=(others=>'0');
  signal sig_pwm_val:std_logic_vector(15 downto 0):=(others=>'0');
  signal sig_selector:natural range 0 to 7:=0;
begin
  leds<=not sig_leds; -- LED Is on when a logic zero
  
  sequencer:process(clk)
  begin
    if rising_edge(clk) then
      sig_pwm_loads<=(others=>'0');
      if write='1' then
        if sig_selector=7 then
          sig_selector<=0;
        else
          sig_selector<=sig_selector+1;
        end if;

        sig_pwm_loads(sig_selector)<='1';
        sig_pwm_val<=pwm_val;
      end if;
    end if;
  end process;

  pwm0:entity work.PWM generic map(PERIOD_IN_CLK_CYCLES=>PERIOD_IN_CLK_CYCLES)
                       port map(clk=>clk,val=>sig_pwm_val,ld=>sig_pwm_loads(0),pwm=>sig_leds(0));

  pwm1:entity work.PWM generic map(PERIOD_IN_CLK_CYCLES=>PERIOD_IN_CLK_CYCLES)
                       port map(clk=>clk,val=>sig_pwm_val,ld=>sig_pwm_loads(1),pwm=>sig_leds(1));

  pwm2:entity work.PWM generic map(PERIOD_IN_CLK_CYCLES=>PERIOD_IN_CLK_CYCLES)
                       port map(clk=>clk,val=>sig_pwm_val,ld=>sig_pwm_loads(2),pwm=>sig_leds(2));

  pwm3:entity work.PWM generic map(PERIOD_IN_CLK_CYCLES=>PERIOD_IN_CLK_CYCLES)
                       port map(clk=>clk,val=>sig_pwm_val,ld=>sig_pwm_loads(3),pwm=>sig_leds(3));

  pwm4:entity work.PWM generic map(PERIOD_IN_CLK_CYCLES=>PERIOD_IN_CLK_CYCLES)
                       port map(clk=>clk,val=>sig_pwm_val,ld=>sig_pwm_loads(4),pwm=>sig_leds(4));

  pwm5:entity work.PWM generic map(PERIOD_IN_CLK_CYCLES=>PERIOD_IN_CLK_CYCLES)
                       port map(clk=>clk,val=>sig_pwm_val,ld=>sig_pwm_loads(5),pwm=>sig_leds(5));

  pwm6:entity work.PWM generic map(PERIOD_IN_CLK_CYCLES=>PERIOD_IN_CLK_CYCLES)
                       port map(clk=>clk,val=>sig_pwm_val,ld=>sig_pwm_loads(6),pwm=>sig_leds(6));

  pwm7:entity work.PWM generic map(PERIOD_IN_CLK_CYCLES=>PERIOD_IN_CLK_CYCLES)
                       port map(clk=>clk,val=>sig_pwm_val,ld=>sig_pwm_loads(7),pwm=>sig_leds(7));
end;

-- EOF -------------------------------------------------------------------------
