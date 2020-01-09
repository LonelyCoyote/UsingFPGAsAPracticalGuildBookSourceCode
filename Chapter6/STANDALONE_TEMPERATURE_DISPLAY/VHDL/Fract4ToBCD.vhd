----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Fract4ToBCD is
  port
  (
    fract4:in std_logic_vector(3 downto 0);
    tenths:out std_logic_vector(3 downto 0);
    hundreths:out std_logic_vector(3 downto 0)
  );
end Fract4ToBCD;

architecture rtl of Fract4ToBCD is
  type lookupTable is array(0 to 15) of std_logic_vector(3 downto 0);
  constant hundrethsLookup:lookupTable:=
  (x"0",x"6",x"3",x"9",x"5",x"1",x"8",x"4",x"0",x"6",x"3",x"8",x"5",x"1",x"8",x"4");   
  constant tenthsLookup:lookupTable:=
  (x"0",x"0",x"1",x"1",x"2",x"3",x"3",x"4",x"5",x"5",x"6",x"6",x"7",x"8",x"8",x"9");

begin
  tenths<=tenthsLookup(to_integer(unsigned(fract4)));
  hundreths<=hundrethsLookup(to_integer(unsigned(fract4)));

end rtl;
