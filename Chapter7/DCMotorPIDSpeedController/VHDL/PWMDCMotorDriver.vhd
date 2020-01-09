----------------------------------------------------------------------------------
-- For use with the L293D H Bridge Motor Controller chip from STMicroelectronics
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity PWMDCMotorDriver is
  generic
  (
    PERIOD_IN_CLK_CYCLES:std_logic_vector(15 downto 0):=(7=>'1',others=>'0')
  );
  port
  (
    clk:in std_logic;
    val:in std_logic_vector(15 downto 0); -- treat as signed number
    ld: in std_logic; -- one shot to load the value
    pwm1: out std_logic;
    pwm2: out std_logic
  );
end PWMDCMotorDriver;

----------------------------------------------------------------------------------
architecture rtl of PWMDCMotorDriver is
  signal sig_val1:std_logic_vector(15 downto 0):=(others=>'0');
  signal sig_val2:std_logic_vector(15 downto 0):=(others=>'0');
  signal sig_ld:std_logic:='0';
  
  signal sig_twos_complement:std_logic_vector(15 downto 0);
begin
  sig_twos_complement<=std_logic_vector(unsigned(not val)+1);

  process(clk)
  begin
    if rising_edge(clk) then
      sig_ld<='0';
      sig_val1<=(others=>'0');
      sig_val2<=(others=>'0');
      if ld='1' then
        sig_ld<='1';
        if val(15)='0' then
          sig_val1<=val;
        else
          sig_val2<=sig_twos_complement;
        end if;
      end if;
    end if;
  end process;

  pwm_1:entity work.PWM generic map(PERIOD_IN_CLK_CYCLES=>PERIOD_IN_CLK_CYCLES)
    port map(clk=>clk,val=>sig_val1,ld=>sig_ld,pwm=>pwm1);
    
  pwm_2:entity work.PWM generic map(PERIOD_IN_CLK_CYCLES=>PERIOD_IN_CLK_CYCLES)
    port map(clk=>clk,val=>sig_val2,ld=>sig_ld,pwm=>pwm2);

end rtl;

-- EOF ----------------------------------------------------------------------------
