----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity OneWireSendByte is
  generic
  (
    CLKS_PER_MICROSECOND:natural:=48
  );
  port
  (
    clk:in std_logic;
    byte:in std_logic_vector(7 downto 0);
    start:in std_logic;
    done:out std_logic;
    
    -- To FPGA IO
    one_wire:inout std_logic
  );
end;

architecture rtl of OneWireSendByte is
  signal sig_done:std_logic:='1';
begin
  done<=sig_done;
  
  imp:block
    signal sig_bitv:std_logic:='0';
    signal sig_bit_start:std_logic:='0';
    signal sig_bit_done:std_logic;
    type statemachine is (WAIT_FOR_START,SEND_BIT_PH1,SEND_BIT_CLK_DELAY,SEND_BIT_PH2);
    signal state:statemachine:=WAIT_FOR_START;
    
  begin
    process(clk)
      variable bit_counter:natural range 0 to 7:=0;
    begin
      if rising_edge(clk) then
        sig_done<='0';
        sig_bit_start<='0';
        case state is
          ----------------------------------------------------------------------
          when WAIT_FOR_START=>
            sig_done<='1';
            if start='1' then
              sig_done<='0';
              state<=SEND_BIT_PH1;
            end if;
          ----------------------------------------------------------------------
          when SEND_BIT_PH1=>
            sig_bitv<=byte(bit_counter);
            sig_bit_start<='1';
            state<=SEND_BIT_CLK_DELAY;
            
          ----------------------------------------------------------------------
          -- PIPE LINING ADDS AN EXTRA CLOCK CYCLE
          when SEND_BIT_CLK_DELAY=>
            state<=SEND_BIT_PH2;
          
          ----------------------------------------------------------------------
          when SEND_BIT_PH2=>
            if sig_bit_done='1' then
              if bit_counter=7 then
                bit_counter:=0;
                state<=WAIT_FOR_START;
              else
                bit_counter:=bit_counter+1;
                state<=SEND_BIT_PH1;
              end if;
            end if;          
        end case;
      end if;
    end process;
  
  uut:entity work.OneWireSendBit generic map(CLKS_PER_MICROSECOND=>CLKS_PER_MICROSECOND)
    port map(clk=>clk,
             bitv=>sig_bitv,
             start=>sig_bit_start,
             done=>sig_bit_done,
             one_wire=>one_wire);
  end block;
end;

-- EOF -------------------------------------------------------------------------




















