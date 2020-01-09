----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity BinaryToBCD2 is
  port
  (
    binary_in:in std_logic_vector(7 downto 0);
    tens:out std_logic_vector(3 downto 0);
    ones:out std_logic_vector(3 downto 0)
  );
end;

----------------------------------------------------------------------------------
architecture rtl of BinaryToBCD2 is
  signal sig_tens:std_logic_vector(3 downto 0):=(others=>'0');
  signal sig_ones:std_logic_vector(3 downto 0):=(others=>'0');
begin
  tens<=sig_tens;
  ones<=sig_ones;
  process(binary_in)
    variable var_binary_in:std_logic_vector(7 downto 0):=(others=>'0');
    variable var_tens:std_logic_vector(3 downto 0):=(others=>'0');
    variable var_ones:std_logic_vector(3 downto 0):=(others=>'0');
  begin
    var_binary_in:=binary_in;
    var_tens:=(others=>'0');
    var_ones:=(others=>'0');
    
    for x in 0 to 7 loop
      if var_tens>b"0100" then
        var_tens:=std_logic_vector(unsigned(var_tens)+3);
      end if;
      
      if var_ones>b"0100" then
        var_ones:=std_logic_vector(unsigned(var_ones)+3);
      end if;

      var_tens:=var_tens(2 downto 0) & '0';
      var_tens(0):=var_ones(3);
      var_ones:=var_ones(2 downto 0) & '0';
      var_ones(0):=var_binary_in(7);
      var_binary_in:=var_binary_in(6 downto 0) & '0';
    
    end loop;
    
    sig_tens<=var_tens;
    sig_ones<=var_ones;
    
  end process;


end rtl;

-- EOF ------------------------------------------------------------------------
