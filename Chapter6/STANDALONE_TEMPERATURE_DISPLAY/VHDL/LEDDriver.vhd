----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LEDDriver is
  port
  (
    on_off:in std_logic;  -- If the LED is to be on or off
    anode:out std_logic;  -- connect to Anode of LED
    cathode:out std_logic  -- connect to cathode of LED
  );
end;
architecture rtl of LEDDriver is
begin
  anode<='Z' when on_off='0' else '1';
  cathode<='Z' when on_off='0' else '0';
end;
