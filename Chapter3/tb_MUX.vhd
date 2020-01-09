----------------------------------------------------------------------------------
-- MUX Test Bench
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity tb_MUX is end tb_MUX;

architecture sim of tb_MUX is
  signal sig_b:std_logic_vector(1 downto 0):=(others=>'0');
  signal sig_s:std_logic_vector(3 downto 0):=(others=>'0');
  signal sig_out:std_logic;
  signal sig_clk:std_logic;
  signal sig_ref:std_logic:='1';
begin
  uut:entity work.MUX port map(s=>sig_s,b=>sig_b,output=>sig_out);
  
  clk:process
  begin
    sig_clk<='0';
    wait for 5 ns;
    sig_clk<='1';
    wait for 5 ns;
  end process;
  
  train:process(sig_clk)
  begin
    if(rising_edge(sig_clk)) then
      sig_s(0)<=sig_ref;
      sig_s(1)<=sig_s(0);
      sig_s(2)<=sig_s(1);
      sig_s(3)<=sig_s(2);
      sig_ref<=sig_s(3);
    end if;
  end process;
  
  selector:process(sig_ref)
  begin
    if(rising_edge(sig_ref)) then
      sig_b<=std_logic_vector(unsigned(sig_b)+1);  
    end if;
  end process;

end sim;

-- EOF --------------------------------------------------------------------------