----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity OneWireTemperatureSensor_MAX31820 is
  generic
  (
    CLKS_PER_MICROSECOND:natural:=48
  );
  port
  (
    clk:in std_logic;
    init:in std_logic; -- One shot to initialize device
    start:in std_logic; -- One shot to start a conversion
    done:out std_logic; -- One shot when conversion completed or device is initialized
    EightDotFour:out std_logic_vector(11 downto 0);
    
    -- To FPGA IO
    one_wire:inout std_logic
  );
end;

----------------------------------------------------------------------------------
architecture rtl of OneWireTemperatureSensor_MAX31820 is
  signal sig_done:std_logic:='1';
  signal sig_EightDotFour:std_logic_vector(11 downto 0):=(others=>'0');
  signal sig_init_done:std_logic:='1';  
begin
  done<=sig_done;
  EightDotFour<=sig_EightDotFour;

  --------------------------------------------------------------------------------
  onew:block
    constant CMDConvertT:std_logic_vector(15 downto 0):=x"0044";
    constant CmdReadScratchPad:std_logic_vector(15 downto 0):=x"00BE";
    
    signal sig_write_instruction_fifo:std_logic:='0';
    signal sig_instruction:std_logic_vector(15 downto 0);
    signal sig_read_data_fifo:std_logic:='0';
    signal sig_data_out:std_logic_vector(15 downto 0);
    signal sig_start_one_wire_transaction:std_logic:='0';
    signal sig_one_wire_transaction_completed:std_logic;
    
    alias read_write is sig_instruction(8);
    alias bus_reset is sig_instruction(9);
    alias match_rom is sig_instruction(10);
    alias resume_rom is sig_instruction(11);
    alias skip_rom is sig_instruction(12);
    alias read_device_id is sig_instruction(13);
    alias set_device_id is sig_instruction(14);
    
    
    type statemachine is (WAIT_FOR_START,
                          WRITE_TO_INSTRUCTION_FIFO,
                          READ_FROM_DATA_FIFO,
                          READ_FROM_DATA_FIFO_DELAY1,
                          READ_FROM_DATA_FIFO_DELAY2,
                          TRANSACTION_READ_DEVICE_ID,
                          TRANSACTION_START_A_TEMPERATURE_READING,
                          TRANSACTION_WAIT_FOR_TEMPERATURE_READING,
                          TRANSACTION_GET_TEMPERATURE_READING,
                          WAIT_FOR_TRANSACTION_TO_COMPLETE_PH1,
                          WAIT_FOR_TRANSACTION_TO_COMPLETE
                          );
                          
    signal state:statemachine:=WAIT_FOR_START;
    signal state_after_write_to_instruction_fifo:statemachine:=WAIT_FOR_START;
    signal state_after_read_from_data_fifo:statemachine:=WAIT_FOR_START;
    signal state_after_wait_for_transaction_to_complete:statemachine:=WAIT_FOR_START;
  begin
    process(clk)
      variable write_count_to_instruction_fifo:natural range 0 to 15:=0;
      variable read_count_from_data_fifo:natural range 0 to 15:=0;
    begin
      if rising_edge(clk) then
        sig_done<='0';
        sig_write_instruction_fifo<='0';
        sig_read_data_fifo<='0';
        sig_start_one_wire_transaction<='0';
      
        case state is
          --------------------------------------------------------------------------------
          when WAIT_FOR_START=>
            sig_done<='1';
            if start='1' then
              sig_done<='0';
              state<=TRANSACTION_START_A_TEMPERATURE_READING;
            end if;
            if init='1' then
              sig_done<='0';
              state<=TRANSACTION_READ_DEVICE_ID;
            end if;
            
          --------------------------------------------------------------------------------
          when WRITE_TO_INSTRUCTION_FIFO=>
            write_count_to_instruction_fifo:=write_count_to_instruction_fifo+1;
            sig_write_instruction_fifo<='1';
            state<=state_after_write_to_instruction_fifo;
          
          --------------------------------------------------------------------------------
          when READ_FROM_DATA_FIFO=>
            sig_read_data_fifo<='1';
            read_count_from_data_fifo:=read_count_from_data_fifo+1;
            state<=READ_FROM_DATA_FIFO_DELAY1;
            
          --------------------------------------------------------------------------------
          when READ_FROM_DATA_FIFO_DELAY1=>
            state<=READ_FROM_DATA_FIFO_DELAY2;

          --------------------------------------------------------------------------------
          when READ_FROM_DATA_FIFO_DELAY2=>
            state<=state_after_read_from_data_fifo;  
          
          --------------------------------------------------------------------------------
          when TRANSACTION_READ_DEVICE_ID=>
            sig_instruction<=x"0000";
            if write_count_to_instruction_fifo=0 then
              bus_reset<='1';
              state_after_write_to_instruction_fifo<=TRANSACTION_READ_DEVICE_ID;
              state<=WRITE_TO_INSTRUCTION_FIFO;
            elsif write_count_to_instruction_fifo=1 then
              read_device_id<='1';
              state_after_write_to_instruction_fifo<=TRANSACTION_READ_DEVICE_ID;
              state<=WRITE_TO_INSTRUCTION_FIFO;
            else
              if read_count_from_data_fifo=0 then 
                state_after_wait_for_transaction_to_complete<=TRANSACTION_READ_DEVICE_ID;
                state<=WAIT_FOR_TRANSACTION_TO_COMPLETE_PH1;
                read_count_from_data_fifo:=1;
                sig_start_one_wire_transaction<='1';
              elsif read_count_from_data_fifo=9 then
                write_count_to_instruction_fifo:=0;
                read_count_from_data_fifo:=0;
                state<=WAIT_FOR_START;  
              else
                state_after_read_from_data_fifo<=TRANSACTION_READ_DEVICE_ID;
                state<=READ_FROM_DATA_FIFO;
              end if;
            end if;
            
          
          --------------------------------------------------------------------------------
          when TRANSACTION_START_A_TEMPERATURE_READING=>
            sig_instruction<=x"0000";
            if write_count_to_instruction_fifo=0 then
              bus_reset<='1';
              state_after_write_to_instruction_fifo<=TRANSACTION_START_A_TEMPERATURE_READING;
              state<=WRITE_TO_INSTRUCTION_FIFO;
            elsif write_count_to_instruction_fifo=1 then
              match_rom<='1';
              state_after_write_to_instruction_fifo<=TRANSACTION_START_A_TEMPERATURE_READING;
              state<=WRITE_TO_INSTRUCTION_FIFO;
            elsif write_count_to_instruction_fifo=2 then
              sig_instruction<=CMDConvertT;
              state_after_write_to_instruction_fifo<=TRANSACTION_START_A_TEMPERATURE_READING;
              state<=WRITE_TO_INSTRUCTION_FIFO;  
            else
              sig_start_one_wire_transaction<='1';
              state_after_wait_for_transaction_to_complete<=TRANSACTION_WAIT_FOR_TEMPERATURE_READING;
              state<=WAIT_FOR_TRANSACTION_TO_COMPLETE_PH1;
              write_count_to_instruction_fifo:=0;              
            end if;
          
          --------------------------------------------------------------------------------
          when TRANSACTION_WAIT_FOR_TEMPERATURE_READING=>
            sig_instruction<=x"0000";
            if write_count_to_instruction_fifo=0 then
              read_write<='1'; 
              state_after_write_to_instruction_fifo<=TRANSACTION_WAIT_FOR_TEMPERATURE_READING;
              state<=WRITE_TO_INSTRUCTION_FIFO; 
            else
              if read_count_from_data_fifo=0 then
                read_count_from_data_fifo:=1;
                sig_start_one_wire_transaction<='1';
                state_after_wait_for_transaction_to_complete<=TRANSACTION_WAIT_FOR_TEMPERATURE_READING;
                state<=WAIT_FOR_TRANSACTION_TO_COMPLETE_PH1;
              elsif read_count_from_data_fifo=1 then
                state_after_read_from_data_fifo<=TRANSACTION_WAIT_FOR_TEMPERATURE_READING;
                state<=READ_FROM_DATA_FIFO;
              else
                write_count_to_instruction_fifo:=0;
                read_count_from_data_fifo:=0;
                if sig_data_out(7 downto 0)=x"FF" then
                  state<=TRANSACTION_GET_TEMPERATURE_READING;  
                else
                  state<=TRANSACTION_WAIT_FOR_TEMPERATURE_READING;
                end if;
              end if;
            end if;
          
          --------------------------------------------------------------------------------
          when TRANSACTION_GET_TEMPERATURE_READING=>
            sig_instruction<=x"0000";
            if write_count_to_instruction_fifo=0 then
              bus_reset<='1';
              state_after_write_to_instruction_fifo<=TRANSACTION_GET_TEMPERATURE_READING;
              state<=WRITE_TO_INSTRUCTION_FIFO;
            elsif write_count_to_instruction_fifo=1 then
              match_rom<='1';
              state<=WRITE_TO_INSTRUCTION_FIFO;
            elsif write_count_to_instruction_fifo=2 then
              sig_instruction<=CmdReadScratchPad;
              state<=WRITE_TO_INSTRUCTION_FIFO;
            elsif write_count_to_instruction_fifo=3 then
              read_write<='1';
              state<=WRITE_TO_INSTRUCTION_FIFO;
            elsif write_count_to_instruction_fifo=4 then
              read_write<='1';
              state<=WRITE_TO_INSTRUCTION_FIFO;
            else
              if read_count_from_data_fifo=0 then
                state_after_wait_for_transaction_to_complete<=TRANSACTION_GET_TEMPERATURE_READING;
                state<=WAIT_FOR_TRANSACTION_TO_COMPLETE_PH1;
                read_count_from_data_fifo:=1;
                sig_start_one_wire_transaction<='1';
              elsif read_count_from_data_fifo=1 then 
                state_after_read_from_data_fifo<=TRANSACTION_GET_TEMPERATURE_READING;
                state<=READ_FROM_DATA_FIFO; 
              elsif read_count_from_data_fifo=2 then
                sig_EightDotFour(7 downto 0)<=sig_data_out(7 downto 0);
                state<=READ_FROM_DATA_FIFO;  
              else
                sig_EightDotFour(11 downto 8)<=sig_data_out(3 downto 0);
                write_count_to_instruction_fifo:=0;
                read_count_from_data_fifo:=0;
                state<=WAIT_FOR_START;                  
              end if;
            end if;
          
            
          
          --------------------------------------------------------------------------------
          when WAIT_FOR_TRANSACTION_TO_COMPLETE_PH1=> 
            state<=WAIT_FOR_TRANSACTION_TO_COMPLETE;         
          
          --------------------------------------------------------------------------------
          when WAIT_FOR_TRANSACTION_TO_COMPLETE=>
            if sig_one_wire_transaction_completed='1' then
              state<=state_after_wait_for_transaction_to_complete;
            end if;
        end case;
      end if;
    end process;
  
  
  
  
    onewd:entity work.OneWireMaster generic map(CLKS_PER_MICROSECOND=>CLKS_PER_MICROSECOND)
      port map( clk=>clk,
                write_instruction_fifo=>sig_write_instruction_fifo,
                instruction=>sig_instruction,
                read_data_fifo=>sig_read_data_fifo,
                data_out=>sig_data_out,
                read_data_fifo_empty=>open,
                device_present=>open,
                start_transaction=>sig_start_one_wire_transaction,
                transaction_completed=>sig_one_wire_transaction_completed,
                one_wire=>one_wire
              );
  end block;

end;

-- EOF ---------------------------------------------------------------------------




