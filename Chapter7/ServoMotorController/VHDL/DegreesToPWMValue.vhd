----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
-- Conversion factors:
-- using signed number -60.0 to +60.0 using 16 bit number we can span
-- use 8.8 bit signed number or 7.8 maximum to span either direction
-- maximum positive:
-- 0x3C00 positive (15,360)
-- 0xC400 negative (-15,361)
-- Conversion from angle to pwm:
-- PWM mid range 1500us 600us up 600us down
-- at 48Mhz clock: 28,800 up and 28,800 down with center at 72,000
-- Constant for conversion 28,800/15360 = 1.875
-- Constant 1.3 format : 1.111
----------------------------------------------------------------------------------
entity DegreesToPWMValue is
  port
  (
    degreesIn:in std_logic_vector(15 downto 0);  -- signed 7.8
    pwm_result:out std_logic_vector(31 downto 0)
  );
end DegreesToPWMValue;

architecture rtl of DegreesToPWMValue is
  constant centerPWM:std_logic_vector(31 downto 0):=x"00011940";
  signal sig_pwm_result:std_logic_vector(31 downto 0):=centerPWM;
begin
  pwm_result<=sig_pwm_result;
  
  process(degreesIn)
    constant conversionFactor:std_logic_vector(3 downto 0):=x"F";  -- 1.3 fixed point
    constant centerPWM:std_logic_vector(31 downto 0):=x"00011940";
    variable negative:std_logic:='0';
    variable convert:std_logic_vector(19 downto 0);
  begin
  
    negative:=degreesIn(15);
      convert:=(others=>'0');
    if negative='0' then
      convert(15 downto 0):=degreesIn;
    else
      convert(15 downto 0):=std_logic_vector(unsigned(not degreesIn)+1);
    end if;
    
    convert:=convert and x"0FFFF";

    -- Force limits between +60 and -60 to not damage the motor
    if convert>x"03C00" then
      convert:=x"03C00";
    end if;
    
    convert:=std_logic_vector(unsigned(convert(15 downto 0))*unsigned(conversionFactor));
    
    convert(15 downto 0):=convert(18 downto 3);
    convert(19 downto 16):=(others=>'0');
    
    
    if negative='1' then
      sig_pwm_result<=std_logic_vector(unsigned(centerPWM)- unsigned(convert));
    else
      sig_pwm_result<=std_logic_vector(unsigned(centerPWM)+unsigned(convert));
    end if;
    
    
  end process;


end rtl;
