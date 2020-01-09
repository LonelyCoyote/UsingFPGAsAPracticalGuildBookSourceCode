----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity tb_R2RADC is end tb_R2RADC;

----------------------------------------------------------------------------------
architecture sim of tb_R2RADC is
  signal clk:std_logic;
  signal convert:std_logic;
  signal done:std_logic;
  signal value:std_logic_vector(7 downto 0);
  signal dac:std_logic_vector(7 downto 0);
  signal feedback:std_logic;
  
begin
  uut:entity work.R2RADC generic map(NUMBER_OF_CLOCKS_BETWEEN_BIT_CHECKS=>10)
    port map(clk=>clk,convert=>convert,done=>done,value=>value,dac=>dac,feedback=>feedback);
    
  gen_clk:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  stim:process
  begin
    convert<='0';
    feedback<='0';
    
    wait for 50 ns;
    
    -- Fire off a conversion where feedback stays low (that is we are under the target voltage)
    wait until rising_edge(clk);
    convert<='1';
    wait until rising_edge(clk);
    convert<='0';
    wait until done='1';
    wait for 50 ns;
  
    -- Fire off a conversion where feedback stays high (that is we are over the target voltage)
    feedback<='1';
    wait until rising_edge(clk);
    convert<='1';
    wait until rising_edge(clk);
    convert<='0';
    wait until done='1';
    wait for 50 ns;


    -- Fire off a conversion where feedback changes states a couple of times during the conversion
    feedback<='1';
    wait until rising_edge(clk);
    convert<='1';
    wait until rising_edge(clk);
    convert<='0';
    
    wait for 100 ns;
    feedback<='0';
    
    wait for 200 ns;
    feedback<='1';
    
    wait for 400 ns;
    feedback<='0';
    
    
    
    wait until done='1';
    wait for 50 ns;




    wait;
  end process;
  


end sim;
