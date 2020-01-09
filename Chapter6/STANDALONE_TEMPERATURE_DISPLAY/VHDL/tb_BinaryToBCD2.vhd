----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity tb_BinaryToBCD2 is end;

architecture sim of tb_BinaryToBCD2 is
  signal binary_in:std_logic_vector(7 downto 0):=x"00";
  signal tens:std_logic_vector(3 downto 0);
  signal ones:std_logic_vector(3 downto 0);
begin
  uut:entity work.BinaryToBCD2 port map(binary_in=>binary_in,tens=>tens,ones=>ones);

  process
  begin
    
    binary_in<=(others=>'0');
      for x in 0 to 99 loop
      wait for 50 ns;
      binary_in<=std_logic_vector(unsigned(binary_in)+1);
    end loop;
    
        

    wait;  
  end process;
  

end sim;
