----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity ADC_TLV1549 is
  generic
  (
    CLKS_PER_MICROSECOND:natural:=48
  );
  port
  (
    clk:in std_logic;
    start:in std_logic;
    done:out std_logic;
    adc_val:out std_logic_vector(9 downto 0);
    
    -- TO FPGA IO
    adc_clk:out std_logic;
    adc_data:in std_logic;
    adc_ncs:out std_logic
  );
end;

----------------------------------------------------------------------------------
architecture rtl of ADC_TLV1549 is
  signal sig_done:std_logic:='1';
  signal sig_adc_val:std_logic_vector(9 downto 0):=(others=>'0');
  signal sig_adc_clk:std_logic:='0';
  signal sig_adc_ncs:std_logic:='1';
  signal sig_adc_data:std_logic;
begin
  done<=sig_done;
  adc_val<=sig_adc_val;
  adc_ncs<=sig_adc_ncs;
  adc_clk<=sig_adc_clk;
  
  sync:entity work.ThreeStageClkSync port map(clk=>clk,asyncsig=>adc_data,syncsig=>sig_adc_data);
  
  imp:block
    constant STATE_MACHINE_TRANSITION_CLK_COUNT:natural:=CLKS_PER_MICROSECOND/2;
    constant STATE_MACHINE_CS_BEFORE_CLK_COUNT:natural:=CLKS_PER_MICROSECOND*3/2;
    constant STATE_MACHINE_ADC_CONVERSION_CLK_COUNT:natural:=CLKS_PER_MICROSECOND*21;
    type statemachine is (WAIT_FOR_START,CS_LOW_BEFORE_START,CLK_LO,CLK_HI,HOLD_CS_LO,WAIT_FOR_NEXT_CONVERSION_TO_COMPLETE);
    signal state:statemachine:=WAIT_FOR_START;
  begin
    process(clk)
      variable counter:natural range 1 to STATE_MACHINE_ADC_CONVERSION_CLK_COUNT:=1;
      variable bit_counter:natural range 0 to 9:=9;
    begin
      if rising_edge(clk) then
        sig_done<='0';
        sig_adc_ncs<='1';
        sig_adc_clk<='0';

        case state is
          ------------------------------------------------------------------------
          when WAIT_FOR_START=>
            sig_done<='1';
            if start='1' then
              sig_done<='0';
              state<=CS_LOW_BEFORE_START;
            end if;
          
          ------------------------------------------------------------------------
          when CS_LOW_BEFORE_START=>
            sig_adc_ncs<='0';
            if counter=STATE_MACHINE_CS_BEFORE_CLK_COUNT then
              counter:=1;
              sig_adc_val(bit_counter)<=sig_adc_data;
              state<=CLK_LO;
            else
              counter:=counter+1;
            end if;
          
          ------------------------------------------------------------------------
          when CLK_LO=>
            sig_adc_ncs<='0';
            if counter=STATE_MACHINE_TRANSITION_CLK_COUNT then
              counter:=1;
              sig_adc_val(bit_counter)<=sig_adc_data;
              state<=CLK_HI;
            else
              counter:=counter+1;
            end if;

          ------------------------------------------------------------------------
          when CLK_HI=>
            sig_adc_ncs<='0';
            sig_adc_clk<='1';
            if counter=STATE_MACHINE_TRANSITION_CLK_COUNT then
              counter:=1;
              if bit_counter=0 then
                bit_counter:=9;
                state<=HOLD_CS_LO;
              else
                bit_counter:=bit_counter-1;
                state<=CLK_LO;
              end if;
            else
              counter:=counter+1;
            end if;
            
          ------------------------------------------------------------------------
          when HOLD_CS_LO=>
            sig_adc_ncs<='0';
            if counter=STATE_MACHINE_TRANSITION_CLK_COUNT then
              counter:=1;
              state<=WAIT_FOR_NEXT_CONVERSION_TO_COMPLETE;
            else
              counter:=counter+1;
            end if;
          
          ------------------------------------------------------------------------
          when WAIT_FOR_NEXT_CONVERSION_TO_COMPLETE=>
            if counter=STATE_MACHINE_ADC_CONVERSION_CLK_COUNT then
              counter:=1;
              state<=WAIT_FOR_START;
            else
              counter:=counter+1;
            end if;
        end case;
      end if;
    end process;
  end block;
end;
