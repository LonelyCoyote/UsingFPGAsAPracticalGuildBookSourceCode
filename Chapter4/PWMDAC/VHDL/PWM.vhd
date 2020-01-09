--------------------------------------------------------------------------------
-- Implement a simple PWM (16 bit capable)
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--------------------------------------------------------------------------------
entity PWM is
  generic
  (
    PERIOD_IN_CLK_CYCLES:std_logic_vector(15 downto 0):=(7=>'1',others=>'0')
  );
  port
  (
    clk:in std_logic;
    val:in std_logic_vector(15 downto 0);
    ld:in std_logic;  -- one shot to load the value
    pwm:out std_logic
  );
end PWM;

--------------------------------------------------------------------------------
architecture rtl of PWM is
  signal sig_pwm:std_logic:='0';
  signal sig_val:std_logic_vector(15 downto 0):=(others=>'0');
begin
  pwm<=sig_pwm;

  -- Load PWM value upon ld high
  load:process(clk)
  begin
    if rising_edge(clk) then
      if ld='1' then
        sig_val<=val;
      end if;
    end if;
  end process;
  
  -- PWM main process
  pwm_imp:block
    signal sig_counter:std_logic_vector(15 downto 0):=(0=>'1',others=>'0');
    signal sig_current_val:std_logic_vector(15 downto 0):=(others=>'0');
  begin
    count:process(clk)
    begin
      if rising_edge(clk) then
        sig_counter<=std_logic_vector(unsigned(sig_counter)+1);
        if sig_counter=PERIOD_IN_CLK_CYCLES then
          sig_counter<=(0=>'1',others=>'0');
          sig_current_val<=sig_val;
        end if;
      end if;
    end process;
    
    gen_pwm:process(clk)
    begin
      if rising_edge(clk) then
        if sig_counter<=sig_current_val then
          sig_pwm<='1';
        else
          sig_pwm<='0';
        end if;
      end if;
    end process;
  end block;
end rtl;






