----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity model_Encoder is
  generic
  (
    CLKS_PER_PULSE:natural:=100
  );
  port
  (
    clk:in std_logic;
    dir:in std_logic;
    A:out std_logic;
    B:out std_logic
  );
end model_Encoder;

----------------------------------------------------------------------------------
architecture rtl of model_Encoder is
  signal sig_A:std_logic:='0';
  signal sig_B:std_logic:='0';
  type lookupTable is array (0 to 3) of std_logic_vector(1 downto 0);
  constant Table:lookupTable:=(
                                    b"00",
                                    b"10",
                                    b"11",
                                    b"01"
                                  );
begin
  A<=sig_A when dir='1' else not sig_A;
  B<=sig_B;
  
  process(clk)
    variable counter:natural range 0 to 3:=0;
    variable clk_counter:natural range 1 to CLKS_PER_PULSE;
  begin
    if rising_edge(clk) then
      sig_A<=Table(counter)(0);
      sig_B<=Table(counter)(1);
      if clk_counter=CLKS_PER_PULSE then
        clk_counter:=1;
        if counter=3 then
          counter:=0;
        else
          counter:=counter+1;
        end if;
      else
        clk_counter:=clk_counter+1;
      end if;
    end if;
  end process;

end rtl;


----------------------------------------------------------------------------------

