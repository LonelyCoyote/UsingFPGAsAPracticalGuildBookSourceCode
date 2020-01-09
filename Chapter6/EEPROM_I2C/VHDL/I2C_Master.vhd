----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
entity I2C_Master is
  generic
  (
    CLOCKS_PER_TRANSITION:natural:=120
  );
  port
  (
    clk:in std_logic;
    load:in std_logic;  -- Initiate a transaction
    done:out std_logic; -- the transaction is completed
    reset:in std_logic; -- resets the state machine for inclomplete message
    start:in std_logic; -- start or restart
    stop:in std_logic;  -- last byte of transaction
    s_data_in:in std_logic_vector(7 downto 0);  -- may be address with r/w or data
    s_data_out:out std_logic_vector(7 downto 0);  -- if read operation data is here
    nack:out std_logic; -- high= slave did not ack
    
    -- To FPGA IO pins
    SCK:inout std_logic;
    SDA:inout std_logic
  );
end I2C_Master;

----------------------------------------------------------------------------------
architecture rtl of I2C_Master is
  signal sig_SCK:std_logic:='Z';
  signal sig_SDA:std_logic:='Z';
  signal sig_SCK_D:std_logic:='1';
  signal sig_SDA_D:std_logic:='1';
  signal sig_SCK_R:std_logic:='U';
  signal sig_SDA_R:std_logic:='U';
begin
  --------------------------------------------------------------------------------
  -- Setup equivalent of open drain on SDA and SCK provide readable and writable 
  -- Signals for the rest of the design
  SCK<=sig_SCK;
  SDA<=sig_SDA;
  sig_SCK<='Z' when sig_SCK_D='1' else '0';
  sig_SDA<='Z' when sig_SDA_D='1' else '0';
  sck_sync:entity work.ThreeStageClkSync port map(clk=>clk,asyncsig=>sig_SCK,syncsig=>sig_SCK_R);
  sda_sync:entity work.ThreeStageClkSync port map(clk=>clk,asyncsig=>sig_SDA,syncsig=>sig_SDA_R);
  
  imp:block
    type statemachine is (
                          INITIATE,
                          RESTART,
                          START_PH1,
                          START_PH2,
                          START_PH3,
                          SEND_BIT_PH1,
                          SEND_BIT_PH2,
                          SEND_BIT_PH2_CHECK,
                          SEND_BIT_PH3,
                          STOP_PH1,
                          STOP_PH2,
                          STOP_PH3,
                          RCV_BIT_PH1,
                          RCV_BIT_PH2,
                          RCV_BIT_PH2_READ,
                          RCV_BIT_PH3,
                          RCV_ACK_PH1,
                          RCV_ACK_PH2,
                          RCV_ACK_PH2_CHECK,
                          RCV_ACK_PH3,
                          SND_ACK_PH1,
                          SND_ACK_PH2,
                          SND_ACK_PH2_A,
                          SND_ACK_PH3,
                          DONE,
                          I2C_DELAY
                          );
    signal state:statemachine:=INITIATE;
    signal state_after_delay:statemachine:=INITIATE;
    signal msg_initiated_read:std_logic:='0';
    signal msg_initiated_write:std_logic:='0';
    signal sig_done:std_logic:='1';
    signal sig_nack:std_logic:='1';
    signal sig_s_data_out:std_logic_vector(7 downto 0):=(others=>'0');
  begin
    done<=sig_done;
    nack<=sig_nack;
    s_data_out<=sig_s_data_out;
    
    
    impp:process(clk)
      variable clk_counter:natural range 1 to CLOCKS_PER_TRANSITION:=1;
      variable bit_counter:natural range 0 to 7:=7;
    begin
      if rising_edge(clk) then
        -- default logic when state machine does not override
        sig_done<='0';
        
        ------------------------------------------------------------------------
        -- Handle bus reset
        ------------------------------------------------------------------------
        if reset='1' then
          state<=INITIATE;
          msg_initiated_read<='0';
          msg_initiated_write<='0';
          sig_SCK_D<='1';
          sig_SDA_D<='1';
          sig_done<='1';
        end if;
        
        case state is
          
          ----------------------------------------------------------------------
          -- Wait for initiation of next byte or address
          ----------------------------------------------------------------------
          when INITIATE=>
            sig_done<='1';  -- default until we start
            if load='1' then
              sig_done<='0';
              if start='1' then
                state<=START_PH1;
                msg_initiated_write<='0';
                msg_initiated_read<='0';
              else
                if msg_initiated_write='1' then
                  state<=SEND_BIT_PH1;
                elsif msg_initiated_read='1' then
                  state<=RCV_BIT_PH1;
                end if;
              end if;
            end if;
          
          ----------------------------------------------------------------------
          when RESTART=>
            sig_SCK_D<='1';
            state<=I2C_DELAY;
            state_after_delay<=START_PH2;
          
          ----------------------------------------------------------------------
          when START_PH1=>
            if sig_SCK_R='0' then -- detect a restart
              sig_SDA_D<='1';
              state<=I2C_DELAY;
              state_after_delay<=RESTART;
            else
              sig_SCK_D<='1';
              state<=I2C_DELAY;
              state_after_delay<=START_PH2;
            end if;
            
          ----------------------------------------------------------------------
          when START_PH2=>
            sig_SDA_D<='0';
            state<=I2C_DELAY;
            state_after_delay<=START_PH3;
            
          ----------------------------------------------------------------------
          when START_PH3=>
            sig_SCK_D<='0';
            state<=I2C_DELAY;
            if s_data_in(0)='0' then
              msg_initiated_write<='1';
            else
              msg_initiated_read<='1';
            end if;
            state_after_delay<=SEND_BIT_PH1;
        
          ----------------------------------------------------------------------
          when SEND_BIT_PH1=>
            sig_SDA_D<=s_data_in(bit_counter);
            state<=I2C_DELAY;
            state_after_delay<=SEND_BIT_PH2;
            
          ----------------------------------------------------------------------
          when SEND_BIT_PH2=>
            sig_SCK_D<='1';
            state<=I2C_DELAY;
            state_after_delay<=SEND_BIT_PH2_CHECK;
            
          ----------------------------------------------------------------------
          -- We can verify the clock remains high here if we want to
          ----------------------------------------------------------------------
          when SEND_BIT_PH2_CHECK=>         
            state<=I2C_DELAY;
            state_after_delay<=SEND_BIT_PH3;
            
          ----------------------------------------------------------------------
          when SEND_BIT_PH3=>
            sig_SCK_D<='0';
            state<=I2C_DELAY;
            if bit_counter=0 then
              state_after_delay<=RCV_ACK_PH1;
              bit_counter:=7;
            else
              bit_counter:=bit_counter-1;
              state_after_delay<=SEND_BIT_PH1; 
            end if;
          
          ----------------------------------------------------------------------
          when STOP_PH1=>
            sig_SDA_D<='0';
            state<=I2C_DELAY;
            state_after_delay<=STOP_PH2;
            
          ----------------------------------------------------------------------
          when STOP_PH2=>
            sig_SCK_D<='1';
            state<=I2C_DELAY;
            state_after_delay<=STOP_PH3;
          
          ----------------------------------------------------------------------
          when STOP_PH3=>
            sig_SDA_D<='1';
            state<=I2C_DELAY;
            state_after_delay<=INITIATE;
            msg_initiated_read<='0';
            msg_initiated_write<='0';
          
          ----------------------------------------------------------------------
          when RCV_BIT_PH1=>
            sig_SDA_D<='1';
            state<=I2C_DELAY;
            state_after_delay<=RCV_BIT_PH2;
          
          ----------------------------------------------------------------------
          when RCV_BIT_PH2=>
            sig_SCK_D<='1';
            state<=I2C_DELAY;
            state_after_delay<=RCV_BIT_PH2_READ;

          ----------------------------------------------------------------------
          when RCV_BIT_PH2_READ=>
            state<=I2C_DELAY;
            state_after_delay<=RCV_BIT_PH3;
            sig_s_data_out(bit_counter)<=sig_SDA_R;

          ----------------------------------------------------------------------
          when RCV_BIT_PH3=>
            sig_SCK_D<='0';
            state<=I2C_DELAY;
            if bit_counter=0 then
              state_after_delay<=SND_ACK_PH1;
              bit_counter:=7;
            else
              bit_counter:=bit_counter-1;
              state_after_delay<=RCV_BIT_PH1; 
            end if;
          
          ----------------------------------------------------------------------
          when RCV_ACK_PH1=>
            sig_SDA_D<='1';
            state<=I2C_DELAY;
            state_after_delay<=RCV_ACK_PH2;
          
          ----------------------------------------------------------------------
          when RCV_ACK_PH2=>
            sig_SCK_D<='1';
            state<=I2C_DELAY;
            state_after_delay<=RCV_ACK_PH2_CHECK;

          ----------------------------------------------------------------------
          when RCV_ACK_PH2_CHECK=>
            sig_nack<=sig_SDA_R;
            state<=I2C_DELAY;
            state_after_delay<=RCV_ACK_PH3;

          ----------------------------------------------------------------------
          when RCV_ACK_PH3=>
            sig_SCK_D<='0';
            state<=I2C_DELAY;
            state_after_delay<=DONE;
            
          ----------------------------------------------------------------------
          when SND_ACK_PH1=>
            sig_SDA_D<=stop;
            state<=I2C_DELAY;
            state_after_delay<=SND_ACK_PH2;

          ----------------------------------------------------------------------
          when SND_ACK_PH2=>
            sig_SCK_D<='1';
            state<=I2C_DELAY;
            state_after_delay<=SND_ACK_PH2_A;

          ----------------------------------------------------------------------
          when SND_ACK_PH2_A=>
            state<=I2C_DELAY;
            state_after_delay<=SND_ACK_PH3;

          ----------------------------------------------------------------------
          when SND_ACK_PH3=>
            sig_SCK_D<='0';
            state<=I2C_DELAY;
            state_after_delay<=DONE;
          
          ----------------------------------------------------------------------
          when DONE=>
            if stop='1' then
              state<=I2C_DELAY;
              state_after_delay<=STOP_PH1;
            else 
              state<=INITIATE;
            end if;
          
          ----------------------------------------------------------------------
          -- Waits CLOCKS_PER_TRANSITION to complete and then sets state
          -- to what it should be for state after delay
          ----------------------------------------------------------------------
          when I2C_DELAY=>
            if clk_counter=CLOCKS_PER_TRANSITION then
              clk_counter:=1;
              state<=state_after_delay;
            else
              clk_counter:=clk_counter+1;
            end if;
        end case;
      end if;
    end process;
  end block;
  
  
end rtl;
