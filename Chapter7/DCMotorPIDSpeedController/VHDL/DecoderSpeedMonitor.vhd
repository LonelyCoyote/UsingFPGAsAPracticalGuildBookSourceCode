----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


----------------------------------------------------------------------------------
entity DecoderSpeedMonitor is
  generic
  (
    GATE_TIME_IN_CLK_CYCLES:natural:=480
  );
  port
  (
    clk:in std_logic;
    current_speed:out std_logic_vector(15 downto 0):=(others=>'0');  -- signed
    A:in std_logic;
    B:in std_logic
  );
end;

----------------------------------------------------------------------------------
architecture rtl of DecoderSpeedMonitor is
  signal sig_decode_count:std_logic_vector(15 downto 0);
  signal sig_clr_decoder:std_logic:='0';
begin
  process(clk)
    variable counter:natural range 1 to GATE_TIME_IN_CLK_CYCLES:=1;
  begin
    if rising_edge(clk) then
      sig_clr_decoder<='0';
      if counter=GATE_TIME_IN_CLK_CYCLES then
        current_speed<=sig_decode_count;
        sig_clr_decoder<='1';
        counter:=1;
      else
        counter:=counter+1;
      end if;
    end if;
  end process;
  
  dcdr:entity work.Decoder port map(clk=>clk,counter=>sig_decode_count,clear_counter=>sig_clr_decoder,
    A=>A,B=>B);
  
end;

----------------------------------------------------------------------------------

