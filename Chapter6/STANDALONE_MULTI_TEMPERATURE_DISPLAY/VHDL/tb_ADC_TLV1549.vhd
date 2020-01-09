----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ADC_TLV1549 is end;

architecture sim of tb_ADC_TLV1549 is
  signal clk:std_logic;
  signal start:std_logic;
  signal done:std_logic;
  signal adc_val:std_logic_vector(9 downto 0);
  signal adc_clk:std_logic;
  signal adc_data:std_logic;
  signal adc_ncs:std_logic;
begin
  uut:entity work.ADC_TLV1549 
    generic map(CLKS_PER_MICROSECOND=>50)
    port map(clk=>clk,
              start=>start,
              done=>done,
              adc_val=>adc_val,
              adc_clk=>adc_clk,
              adc_data=>adc_data,
              adc_ncs=>adc_ncs);

  clk_gen:process
  begin
    clk<='0';
    wait for 10 ns;
    clk<='1';
    wait for 10 ns;
  end process;
  
  stim:process
  begin
    start<='0';
    adc_data<='1';
    wait for 50 ns;
    
    wait until rising_edge(clk);
    start<='1';
    wait until rising_edge(clk);
    start<='0';
    
    
  
    wait;
  end process;


end sim;
