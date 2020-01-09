----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ServoController is
  port
  (
    clk:in std_logic;
    angleInDegrees:in std_logic_vector(15 downto 0);  -- Fixed point signed 7.8
    ld:in std_logic;  -- One shot to load the new angle
    
    ld_feedback:in std_logic; -- One shot to get the feedback voltage
    feedback:out std_logic_vector(15 downto 0); -- Feedback from Servo potentiometer bit 15=done
    
    -- TO FPGA IO
    adc_clk:out std_logic;
    adc_data:in std_logic;
    adc_ncs:out std_logic;
    servo_pwm:out std_logic
  );
  
end;
  
architecture rtl of ServoController is
begin
  feedback(14 downto 10)<=(others=>'0');

  adc:entity work.ADC_TLV1549 generic map(CLKS_PER_MICROSECOND=>48)
    port map(clk=>clk,start=>ld_feedback,done=>feedback(15),adc_val=>feedback(9 downto 0),
      adc_clk=>adc_clk,adc_data=>adc_data,adc_ncs=>adc_ncs);
      
  ctrlr:block
    signal sig_pwm:std_logic_vector(31 downto 0);
  begin
  hpPwm:entity work.HighPrecisionPWM generic map
    (PERIOD_IN_CLK_CYCLES=>x"00075300") -- 10ms, 480,000 clocks
    port map(clk=>clk,val_h=>sig_pwm(31 downto 16),val_l=>sig_pwm(15 downto 0),ld=>ld,pwm=>servo_pwm);
    
  deg2pwm:entity work.DegreesToPWMValue port map(degreesIn=>angleInDegrees,pwm_result=>sig_pwm); 
  end block;

end;


-- EOF --------------------------------------------------------------------------------



