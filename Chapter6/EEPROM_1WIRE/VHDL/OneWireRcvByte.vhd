----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity OneWireRcvByte is
  generic
  (
    CLKS_PER_MICROSECOND:natural:=48
  );
  port
  (
    clk:in std_logic;
    byte:out std_logic_vector(7 downto 0);
    start:in std_logic;
    done:out std_logic;
    
    -- To FPGA IO
    one_wire:inout std_logic
  );
end;

----------------------------------------------------------------------------------
architecture rtl of OneWireRcvByte is
  signal sig_byte:std_logic_vector(7 downto 0):=(others=>'0');
  signal sig_done:std_logic:='1';
begin
  byte<=sig_byte;
  done<=sig_done;
  
  imp:block
    signal sig_bitv:std_logic;
    signal sig_bit_start:std_logic:='0';
    signal sig_bit_done:std_logic;
    type statemachine is (WAIT_FOR_START,RCV_BIT_PH1,RCV_BIT_CLK_DELAY,RCV_BIT_PH2);
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
              state<=RCV_BIT_PH1;
            end if;
          ----------------------------------------------------------------------
          when RCV_BIT_PH1=>
            sig_bit_start<='1';
            state<=RCV_BIT_CLK_DELAY;
          ----------------------------------------------------------------------
          when RCV_BIT_CLK_DELAY=>
            state<=RCV_BIT_PH2;
          ----------------------------------------------------------------------
          when RCV_BIT_PH2=>
            if sig_bit_done='1' then
              sig_byte(bit_counter)<=sig_bitv;
              if bit_counter=7 then
                bit_counter:=0;
                state<=WAIT_FOR_START;
              else
                bit_counter:=bit_counter+1;
                state<=RCV_BIT_PH1;
              end if;
            end if;
        end case;
      end if;
    end process;

    bit_rcvr:entity work.OneWireRcvBit generic map(CLKS_PER_MICROSECOND=>CLKS_PER_MICROSECOND)
      port map(clk=>clk,bitv=>sig_bitv,start=>sig_bit_start,done=>sig_bit_done,one_wire=>one_wire);
  end block;
  


end;
