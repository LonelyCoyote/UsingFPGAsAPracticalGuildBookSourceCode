----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity OneWireMaster is
  generic
  (
    CLKS_PER_MICROSECOND:natural:=48
  );
  port
  (
    clk:in std_logic;
    write_instruction_fifo:in std_logic;  -- one shot to write an instruction to the FIFO
    instruction:in std_logic_vector(15 downto 0);  -- data to write to the FIFO
    
    read_data_fifo:in std_logic; -- one shot to read data from the returning fifo
    data_out:out std_logic_vector(15 downto 0); -- the data coming back from the device FIFO
    read_data_fifo_empty:out std_logic;
    
    device_present:out std_logic; -- when a reset is done, this should be high
    
    start_transaction:in std_logic; -- one shot to start a transaction
    transaction_completed:out std_logic; -- the transaction has completed
    
    one_wire:inout std_logic
  );

end OneWireMaster;

architecture rtl of OneWireMaster is
  COMPONENT FIFO16BIT
    PORT (
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC
    );
  END COMPONENT;
  signal sig_device_present:std_logic:='0';
  signal sig_transaction_completed:std_logic:='1';
begin
  transaction_completed<=sig_transaction_completed;

  imp:block
    type statemachine is (
                          WAIT_FOR_START,
                          GET_NEXT_COMMAND_PH1,
                          GET_NEXT_COMMAND_PH2,
                          GET_NEXT_COMMAND_PH3,
                          EXECUTE_RESET_PH1,
                          EXECUTE_RESET_PH2,
                          EXECUTE_RESET_PH3,
                          ROM_READ_PH1,
                          ROM_READ_PH2,
                          ROM_READ_PH3,
                          ROM_READ_PH4,
                          ROM_READ_PH5,
                          ROM_READ_PH6,
                          ROM_MATCH_PH1,
                          ROM_MATCH_PH2,
                          ROM_MATCH_PH3,
                          ROM_MATCH_PH4,
                          ROM_MATCH_PH5,
                          ROM_MATCH_PH6,
                          SEND_BYTE_PH1,
                          SEND_BYTE_PH2,
                          SEND_BYTE_PH3,
                          RCV_BYTE_PH1,
                          RCV_BYTE_PH2,
                          RCV_BYTE_PH3,
                          SET_DEVICE_ID_PH1,
                          SET_DEVICE_ID_PH2,
                          SET_DEVICE_ID_PH3
                          );
    
    constant ROM_READ:std_logic_vector(7 downto 0):=x"33";
    constant ROM_MATCH:std_logic_vector(7 downto 0):=x"55";
    constant ROM_RESUME:std_logic_vector(7 downto 0):=x"A5";
    constant ROM_SKIP:std_logic_vector(7 downto 0):=x"CC";
    
    signal state:statemachine:=WAIT_FOR_START;

    -- Fifo in control signals and aliases
    signal fifo_in_rd_en:std_logic:='0';
    signal fifo_in_data_out:std_logic_vector(15 downto 0);
    alias read_write is fifo_in_data_out(8);
    alias bus_reset is fifo_in_data_out(9);
    alias match_rom is fifo_in_data_out(10);
    alias resume_rom is fifo_in_data_out(11);
    alias skip_rom is fifo_in_data_out(12);
    alias read_device_id is fifo_in_data_out(13);
    alias set_device_id is fifo_in_data_out(14);
    signal fifo_in_empty:std_logic;

    -- fifo out control    
    signal fifo_out_data_in:std_logic_vector(15 downto 0);
    signal fifo_out_wr_en:std_logic;
    
    type device_id_type is array (0 to 7) of std_logic_vector(7 downto 0);
    signal sig_device_id:device_id_type:=(others=>(others=>'0'));
    
    -- one wire reset control
    signal one_wire_reset:std_logic:='0';
    signal one_wire_reset_done:std_logic;
    
    -- byte sending control
    signal byte_to_send:std_logic_vector(7 downto 0):=(others=>'0');
    signal send_byte_start:std_logic:='0';
    signal send_byte_done:std_logic;
    
    -- byte receiving control
    signal byte_read:std_logic_vector(7 downto 0):=(others=>'0');
    signal read_byte_start:std_logic:='0';
    signal read_byte_done:std_logic;

  begin
    -- Main control process
    process(clk)
      variable byte_counter:natural range 0 to 255:=0;
      variable delay_counter:natural range 1 to 15:=1;
    begin
      if rising_edge(clk) then
        fifo_in_rd_en<='0';
        sig_transaction_completed<='0';
        one_wire_reset<='0';
        send_byte_start<='0';
        read_byte_start<='0';
        fifo_out_wr_en<='0';
      
        case state is
          --------------------------------------------------------------------------------
          when WAIT_FOR_START=>
            sig_transaction_completed<='1';
            if start_transaction='1' then
              sig_transaction_completed<='0';
              state<=GET_NEXT_COMMAND_PH1;
            end if;
          --------------------------------------------------------------------------------
          when GET_NEXT_COMMAND_PH1=>
            if delay_counter=5 then
              delay_counter:=1;
              if fifo_in_empty='1' then
                state<=WAIT_FOR_START;
              else
                fifo_in_rd_en<='1';
                state<=GET_NEXT_COMMAND_PH2;
              end if;
            else
              delay_counter:=delay_counter+1;
            end if;
            
          --------------------------------------------------------------------------------
          when GET_NEXT_COMMAND_PH2=>
            state<=GET_NEXT_COMMAND_PH3;
            
          --------------------------------------------------------------------------------
          when GET_NEXT_COMMAND_PH3=>
            if bus_reset='1' then
              state<=EXECUTE_RESET_PH1; 
            elsif read_device_id='1' then
              byte_to_send<=ROM_READ;
              state<=ROM_READ_PH1;
            elsif match_rom='1' then
              byte_to_send<=ROM_MATCH;
              state<=ROM_MATCH_PH1;
            elsif resume_rom='1' then
              byte_to_send<=ROM_RESUME;
              state<=SEND_BYTE_PH1;
            elsif skip_rom='1' then
              byte_to_send<=ROM_SKIP; 
              state<=SEND_BYTE_PH1; 
            elsif set_device_id='1' then 
              state<=SET_DEVICE_ID_PH1;
            elsif read_write='1' then
              state<=RCV_BYTE_PH1;
            else
              byte_to_send<=fifo_in_data_out(7 downto 0);
              state<=SEND_BYTE_PH1;
            end if;
            
          --------------------------------------------------------------------------------
          when EXECUTE_RESET_PH1=>
            one_wire_reset<='1';
            state<=EXECUTE_RESET_PH2;  
          
          --------------------------------------------------------------------------------
          when EXECUTE_RESET_PH2=>
            state<=EXECUTE_RESET_PH3;
            
          --------------------------------------------------------------------------------
          when EXECUTE_RESET_PH3=>
            if one_wire_reset_done='1' then
              state<=GET_NEXT_COMMAND_PH1;
            end if;
            
          --------------------------------------------------------------------------------
          when ROM_READ_PH1=>
            send_byte_start<='1';
            state<=ROM_READ_PH2;   
          
          --------------------------------------------------------------------------------
          when ROM_READ_PH2=>
            state<=ROM_READ_PH3;
          
          --------------------------------------------------------------------------------
          when ROM_READ_PH3=>
            if send_byte_done='1' then
              state<=ROM_READ_PH4;
            end if;
          
          --------------------------------------------------------------------------------
          when ROM_READ_PH4=>
            read_byte_start<='1';
            state<=ROM_READ_PH5;
          
          --------------------------------------------------------------------------------
          when ROM_READ_PH5=>
            state<=ROM_READ_PH6;
          
          --------------------------------------------------------------------------------
          when ROM_READ_PH6=>
            if read_byte_done='1' then
              sig_device_id(byte_counter)<=byte_read;
              fifo_out_data_in(7 downto 0)<=byte_read;
              fifo_out_wr_en<='1';
              
              if byte_counter=7 then
                byte_counter:=0;
                state<=GET_NEXT_COMMAND_PH1;
              else
                byte_counter:=byte_counter+1;
                state<=ROM_READ_PH4;
              end if;  
            end if;
            
          --------------------------------------------------------------------------------
          when ROM_MATCH_PH1=>
            send_byte_start<='1';
            state<=ROM_MATCH_PH2;
            
          --------------------------------------------------------------------------------
          when ROM_MATCH_PH2=>
            state<=ROM_MATCH_PH3;
            
          --------------------------------------------------------------------------------
          when ROM_MATCH_PH3=>
            if send_byte_done='1' then
              state<=ROM_MATCH_PH4;
            end if;
          
          --------------------------------------------------------------------------------
          when ROM_MATCH_PH4=>
            byte_to_send<=sig_device_id(byte_counter);
            send_byte_start<='1';
            state<=ROM_MATCH_PH5;
            
          --------------------------------------------------------------------------------
          when ROM_MATCH_PH5=>
            state<=ROM_MATCH_PH6;
          
          --------------------------------------------------------------------------------
          when ROM_MATCH_PH6=>
            if send_byte_done='1' then
              if byte_counter=7 then
                byte_counter:=0;
                state<=GET_NEXT_COMMAND_PH1;
              else
                byte_counter:=byte_counter+1;
                state<=ROM_MATCH_PH4;
              end if;
            end if;
            
          --------------------------------------------------------------------------------
          when SEND_BYTE_PH1=>
            send_byte_start<='1';
            state<=SEND_BYTE_PH2;
            
          --------------------------------------------------------------------------------
          when SEND_BYTE_PH2=>
            state<=SEND_BYTE_PH3;
            
          --------------------------------------------------------------------------------
          when SEND_BYTE_PH3=>
            if send_byte_done='1' then
              state<=GET_NEXT_COMMAND_PH1;
            end if;
          
          --------------------------------------------------------------------------------
          when RCV_BYTE_PH1=>
            read_byte_start<='1';
            state<=RCV_BYTE_PH2;
          
          --------------------------------------------------------------------------------
          when RCV_BYTE_PH2=>
            state<=RCV_BYTE_PH3;
          
          --------------------------------------------------------------------------------
          when RCV_BYTE_PH3=>
            if read_byte_done='1' then
              fifo_out_data_in(7 downto 0)<=byte_read;
              fifo_out_wr_en<='1';
              state<=GET_NEXT_COMMAND_PH1;
            end if;
          
          --------------------------------------------------------------------------------
          when SET_DEVICE_ID_PH1=>
            fifo_in_rd_en<='1';
            state<=SET_DEVICE_ID_PH2;
          
          --------------------------------------------------------------------------------
          when SET_DEVICE_ID_PH2=>
            state<=SET_DEVICE_ID_PH3;
          
          --------------------------------------------------------------------------------
          when SET_DEVICE_ID_PH3=>
            sig_device_id(byte_counter)<=fifo_in_data_out(7 downto 0);
            if byte_counter=7 then
              byte_counter:=0;
              state<=GET_NEXT_COMMAND_PH1;
            else
              byte_counter:=byte_counter+1;
              state<=SET_DEVICE_ID_PH1;
            end if;
            
          
      end case;
    end if;
    end process;

    -- incomming data that creates a one wire transaction
    -- FORMAT: bits 7 downto 0 is data (if all other upper bits zero)
    -- bit 8 set high for a read low for a write, if write the 8 bits are used
    -- bit 9 set high for a bus reset
    -- bit 10 set high to use match rom
    -- bit 11 set high to use resume rom
    -- bit 12 set high to use skip rom
    -- bit 13 set high to read the device ID (only works with one device on bus)
    fifo_in:FIFO16BIT
      PORT MAP (
        wr_clk => clk,
        rd_clk => clk,
        din => instruction,
        wr_en => write_instruction_fifo,
        rd_en => fifo_in_rd_en,
        dout => fifo_in_data_out,
        full => open,
        empty => fifo_in_empty
      );

    -- data from the slave device coming back
    -- FORMAT bits 7 downto 0 is data
    -- bits 15 downto 0 not used
    fifo_out:FIFO16BIT
      PORT MAP (
        wr_clk => clk,
        rd_clk => clk,
        din => fifo_out_data_in,
        wr_en => fifo_out_wr_en,
        rd_en => read_data_fifo,
        dout => data_out,
        full => open,
        empty => read_data_fifo_empty
      );
      
  rst:entity work.OneWireReset generic map(CLKS_PER_MICROSECOND=>CLKS_PER_MICROSECOND)
  port map(clk=>clk,reset=>one_wire_reset,done=>one_wire_reset_done,devices_present=>device_present,one_wire=>one_wire);
   
  bsend:entity work.OneWireSendByte generic map(CLKS_PER_MICROSECOND=>CLKS_PER_MICROSECOND)
    port map(clk=>clk,byte=>byte_to_send,start=>send_byte_start,done=>send_byte_done,one_wire=>one_wire);
    
  brcv:entity work.OneWireRcvByte generic map(CLKS_PER_MICROSECOND=>CLKS_PER_MICROSECOND)
    port map(clk=>clk,byte=>byte_read,start=>read_byte_start,done=>read_byte_done,one_wire=>one_wire);
    
   
      
  end block;
end rtl;
