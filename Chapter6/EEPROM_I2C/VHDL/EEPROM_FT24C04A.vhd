----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity EEPROM_FT24C04A is
  generic
  (
    I2C_CLOCKS_PER_TRANSITION:natural:=120
  );
  port
  (
    clk:in std_logic;
    address:in std_logic_vector(8 downto 0);
    data_in:in std_logic_vector(7 downto 0);
    data_out:out std_logic_vector(7 downto 0);
    read_write:in std_logic;  -- read='1' write='0'
    nack:out std_logic; -- high indicates EEPROM is not acking
    start:in std_logic; -- initiate a transfer
    done:out std_logic; -- high when transfer done
    A0:in std_logic;
    A1:in std_logic;
    
    -- to IO Pins of FPGA routed to EEPROM
    SCK:inout std_logic;
    SDA:inout std_logic
  );
end;

----------------------------------------------------------------------------------
architecture rtl of EEPROM_FT24C04A is
  signal sig_data_out:std_logic_vector(7 downto 0):=(others=>'0');
  signal sig_done:std_logic:='1';
  signal sig_nack:std_logic:='0';
begin
  done<=sig_done;
  data_out<=sig_data_out;
  nack<=sig_nack;
  
  --------------------------------------------------------------------------------
  imp:block
    type statemachine is (WAIT_FOR_START,
                          SEND_DEVICE_ADDRESS,
                          SEND_ADDRESS,
                          SEND_BYTE,
                          RCV_BYTE,
                          RCV_BYTE_PH2,
                          WAIT_FOR_DONE,
                          WAIT_FOR_DONE_PH2);
    signal state:statemachine:=WAIT_FOR_START;
    signal next_state_after_wait:statemachine:=WAIT_FOR_START;
    signal sig_send_device_address_count:natural range 0 to 1:=0;
    constant upper_address:std_logic_vector(3 downto 0):=b"1010";

    -- Signals to I2C interface
    signal sig_i2c_load:std_logic:='0';
    signal sig_i2c_done:std_logic;
    signal sig_i2c_start:std_logic:='0';
    signal sig_i2c_stop:std_logic:='0';
    signal sig_i2c_data_in:std_logic_vector(7 downto 0):=(others=>'0');
    signal sig_i2c_data_out:std_logic_vector(7 downto 0):=(others=>'0');
    signal sig_i2c_nack:std_logic;
  begin
    main:process(clk)
    begin
      if rising_edge(clk) then
        sig_done<='0';
        sig_i2c_load<='0';
        
          case state is
            ----------------------------------------------------------------------
            when WAIT_FOR_START=>
              sig_done<='1';
              sig_send_device_address_count<=0;
              if start='1' then
                sig_done<='0';
                state<=SEND_DEVICE_ADDRESS;
              end if;

            ----------------------------------------------------------------------
            when SEND_DEVICE_ADDRESS=>
              sig_i2c_data_in(7 downto 4)<=upper_address;
              sig_i2c_data_in(3 downto 0)<=(3=>A1, 2=>A0, 1=>address(8), 0=>'0');
              sig_i2c_start<='1';
              sig_i2c_stop<='0';
              sig_i2c_load<='1';
              state<=WAIT_FOR_DONE;
              if sig_send_device_address_count=0 then
                sig_send_device_address_count<=1;
                next_state_after_wait<=SEND_ADDRESS;
              else
                sig_i2c_data_in(0)<='1';
                next_state_after_wait<=RCV_BYTE;
              end if;

            ----------------------------------------------------------------------
            when SEND_ADDRESS=>
              sig_nack<=sig_i2c_nack;
              sig_i2c_data_in<=address(7 downto 0);
              sig_i2c_start<='0';
              sig_i2c_stop<='0';
              sig_i2c_load<='1';
              
              state<=WAIT_FOR_DONE;
              if read_write='1' then
                sig_send_device_address_count<=1;
                next_state_after_wait<=SEND_DEVICE_ADDRESS;
            else
                next_state_after_wait<=SEND_BYTE;
              end if;

            ----------------------------------------------------------------------
            when SEND_BYTE=>
              sig_i2c_data_in<=data_in;
              sig_i2c_start<='0';
              sig_i2c_stop<='1';
              sig_i2c_load<='1';
              state<=WAIT_FOR_DONE;
              next_state_after_wait<=WAIT_FOR_START;

            ----------------------------------------------------------------------
            when RCV_BYTE=>
              sig_i2c_start<='0';
              sig_i2c_stop<='1';
              sig_i2c_load<='1';
              state<=WAIT_FOR_DONE;
              next_state_after_wait<=RCV_BYTE_PH2;
            
            ----------------------------------------------------------------------
            when RCV_BYTE_PH2=>
              sig_data_out<=sig_i2c_data_out;
              state<=WAIT_FOR_DONE;
              next_state_after_wait<=WAIT_FOR_START;
              
            ----------------------------------------------------------------------
            -- Due to pipelining we need an extra clock cycle prior to checking
            when WAIT_FOR_DONE=>
              state<=WAIT_FOR_DONE_PH2;
              
            ----------------------------------------------------------------------
            when WAIT_FOR_DONE_PH2=>
              if sig_i2c_done='1' then
                state<=next_state_after_wait;
              end if;
  
          end case;
        end if;
    end process;
    
  ------------------------------------------------------------------------------
  -- Instantiate I2C interface
  ------------------------------------------------------------------------------
  i2c1:entity work.I2C_Master generic map(CLOCKS_PER_TRANSITION=>I2C_CLOCKS_PER_TRANSITION)
    port map
    (
      clk=>clk,
      load=>sig_i2c_load,
      done=>sig_i2c_done,
      reset=>'0',
      start=>sig_i2c_start,
      stop=>sig_i2c_stop,
      s_data_in=>sig_i2c_data_in,
      s_data_out=>sig_i2c_data_out,
      nack=>sig_i2c_nack,
      SCK=>SCK,
      SDA=>SDA
    );
  end block;
end;












