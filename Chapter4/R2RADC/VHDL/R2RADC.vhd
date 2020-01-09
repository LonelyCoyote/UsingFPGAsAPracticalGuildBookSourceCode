----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity R2RADC is
  generic
  (
    -- Warning: Do not make this value less than 3 clock cycles!
    -- The feedback is triple registered to the clock to avoid metastability
    -- so you must wait those three clock cycles at a minimum
    NUMBER_OF_CLOCKS_BETWEEN_BIT_CHECKS:natural:=100
  );
  port
  (
    clk:in std_logic;
    convert:in std_logic; -- one shot to initiate a conversion
    done: out std_logic;  -- transitions high when the conversion is completed
    value: out std_logic_vector(7 downto 0);  -- value of the conversion
    dac: out std_logic_vector(7 downto 0);  -- wire to R2R ladder
    feedback:in std_logic  -- wire to comparator
  );
end;

----------------------------------------------------------------------------------
architecture rtl of R2RADC is
  signal sig_done:std_logic:='1';
  signal sig_value:std_logic_vector(7 downto 0):=(others=>'0');
begin
  done<=sig_done;
  value<=sig_value;
  
  --------------------------------------------------------------------------------
  imp:block
    signal sig_load_dac:std_logic:='0';
    signal sig_dac_in:std_logic_vector(7 downto 0):=(others=>'0');
    signal sig_sync_feedback:std_logic;
    type states is (WAIT_FOR_START,SET_BIT,DELAY,CHECK_BIT,DONE);
    signal state:states:=WAIT_FOR_START;
  begin
    imp_proc:process(clk)
      variable bit_number:natural range 0 to 7:=7;
      variable delay_count:natural range 0 to NUMBER_OF_CLOCKS_BETWEEN_BIT_CHECKS:=0;
    begin
      if rising_edge(clk) then
        sig_load_dac<='0';
        sig_done<='0';
        case state is
          ------------------------------------------------------------------------
          when WAIT_FOR_START =>
            sig_dac_in<=(others=>'0');
            bit_number:=7;
            sig_done<='1';
            if convert='1' then
              state<=SET_BIT;
              sig_done<='0';
            end if;
          
          ------------------------------------------------------------------------
          when SET_BIT =>
            sig_dac_in(bit_number)<='1';
            sig_load_dac<='1';
            state<=DELAY;
            delay_count:=1;
            
          ------------------------------------------------------------------------
          when DELAY =>
            if delay_count=NUMBER_OF_CLOCKS_BETWEEN_BIT_CHECKS then
              state<=CHECK_BIT;
            else
              delay_count:=delay_count+1;
            end if;
            
          ------------------------------------------------------------------------
          when CHECK_BIT =>
            if sig_sync_feedback='1' then
              sig_dac_in(bit_number)<='0';
              sig_load_dac<='1';
            end if;
            
            if bit_number=0 then
              state<=DONE;
            else
              bit_number:=bit_number-1;
              state<=SET_BIT;
            end if;

          ------------------------------------------------------------------------
          when DONE =>
            sig_value<=sig_dac_in;
            state<=WAIT_FOR_START;
        
        end case;
      end if;
    end process;
  
  dac_imp:entity work.R2RDAC port map(clk=>clk,load=>sig_load_dac,val=>sig_dac_in,
                                      dac_out=>dac);
                                      
  sync_feedback:entity work.ThreeStageClkSync port map(clk=>clk,asyncsig=>feedback,
                                                        syncsig=>sig_sync_feedback);
  
  
  
  end block;


end;
