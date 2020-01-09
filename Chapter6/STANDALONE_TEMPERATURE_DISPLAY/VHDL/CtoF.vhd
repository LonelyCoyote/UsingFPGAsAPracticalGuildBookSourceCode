----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CtoF is
  port
  (
    Cin:in std_logic_vector(11 downto 0); -- In has 4 bits fractional part
    Fout:out std_logic_vector(11 downto 0) -- Out has 4 bit fractional part
  );
end CtoF;

architecture rtl of CtoF is
  -- fixed point arithmetic 9/5 or 1.8 with 8 bits fractional part
  constant NineOverFive:std_logic_vector(8 downto 0):=b"111001101";
  signal sigIntermediate:std_logic_vector(20 downto 0);
begin
  sigIntermediate<=std_logic_vector(unsigned(CIn)*unsigned(NineOverFive));
  Fout<=std_logic_vector(unsigned(sigIntermediate(19 downto 8))+512);

end rtl;
