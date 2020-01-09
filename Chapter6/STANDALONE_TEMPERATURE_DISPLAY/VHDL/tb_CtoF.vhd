----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_CtoF is end;

architecture sim of tb_CtoF is
  signal Cin:std_logic_vector(11 downto 0);
  signal Fout:std_logic_vector(11 downto 0);
  signal FoutInt:std_logic_vector(7 downto 0);
begin
  FoutInt<=Fout(11 downto 4);
  uut:entity work.CtoF port map(Cin=>Cin,Fout=>Fout);
  
  process
  begin
    Cin<=x"000";
    wait for 50 ns;
    Cin<=x"140";
    wait for 50 ns;
    Cin<=x"640";
    wait;
  end process;
  


end;
