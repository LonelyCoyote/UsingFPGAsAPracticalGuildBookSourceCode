----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_OneWireMaster is end;

architecture sim of tb_OneWireMaster is
  signal clk:std_logic;
  signal write_instruction_fifo:std_logic;
  signal instruction:std_logic_vector(15 downto 0);
  signal read_data_fifo:std_logic;
  signal data_out:std_logic_vector(15 downto 0);
  signal read_data_fifo_empty:std_logic;
  signal device_present:std_logic;
  signal start_transaction:std_logic;
  signal transaction_completed:std_logic;
  signal one_wire:std_logic:='Z';
  
  alias read_write is instruction(8);
  alias bus_reset is instruction(9);
  alias match_rom is instruction(10);
  alias resume_rom is instruction(11);
  alias skip_rom is instruction(12);
  alias read_device_id is instruction(13);
  alias set_device_id is instruction(14);

begin
  clk_gen:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  stim:process
  begin
    -- initialize inputs
    write_instruction_fifo<='0';
    instruction<=(others=>'0'); 
    read_data_fifo<='0';
    start_transaction<='0';
    
    wait for 50 us;
    
--    -- Test reset device
--    bus_reset<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='0';
--    bus_reset<='0';
    
--    -- followed by a read device ID
--    read_device_id<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='0';
--    read_device_id<='0';
    
--    wait until rising_edge(clk);
--    start_transaction<='1';
--    wait until rising_edge(clk);
--    start_transaction<='0';
--    wait until transaction_completed='1';
    
--    -- Lets set the device id
--    -- push 0x0123456789ABCDEF into fifo
--    set_device_id<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='0';
    
--    instruction<=x"0001"; -- byte 1
--    wait until rising_edge(clk);
--    write_instruction_fifo<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='0';
    
--    instruction<=x"0023"; -- byte 2
--    wait until rising_edge(clk);
--    write_instruction_fifo<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='0';
    
--    instruction<=x"0045"; -- byte 3
--    wait until rising_edge(clk);
--    write_instruction_fifo<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='0';
    
--    instruction<=x"0067"; -- byte 4
--    wait until rising_edge(clk);
--    write_instruction_fifo<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='0';
    
--    instruction<=x"0089"; -- byte 5
--    wait until rising_edge(clk);
--    write_instruction_fifo<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='0';
    
--    instruction<=x"00AB"; -- byte 6
--    wait until rising_edge(clk);
--    write_instruction_fifo<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='0';
    
--    instruction<=x"00CD"; -- byte 7
--    wait until rising_edge(clk);
--    write_instruction_fifo<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='0';

--    instruction<=x"00EF"; -- byte 8
--    wait until rising_edge(clk);
--    write_instruction_fifo<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='0';
    
--    -- execute the transaction
--    wait until rising_edge(clk);
--    start_transaction<='1';
--    wait until rising_edge(clk);
--    start_transaction<='0';
--    wait until transaction_completed='1';
    
--    -- test rom match
--    instruction<=(others=>'0');
--    match_rom<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='1';
--    wait until rising_edge(clk);
--    write_instruction_fifo<='0';
    
--    wait until rising_edge(clk);
--    start_transaction<='1';
--    wait until rising_edge(clk);
--    start_transaction<='0';
--    wait until transaction_completed='1';
    
    wait for 500 us;
    
    -- test the problem child
    instruction<=(others=>'0');
    bus_reset<='1';
    wait until rising_edge(clk);
    write_instruction_fifo<='1';
    wait until rising_edge(clk);
    write_instruction_fifo<='0';

    bus_reset<='0';
    match_rom<='1';
    wait until rising_edge(clk);
    write_instruction_fifo<='1';
    wait until rising_edge(clk);
    write_instruction_fifo<='0';
    match_rom<='0';
    
    instruction<=x"000F";  -- write scratch pad
    wait until rising_edge(clk);
    write_instruction_fifo<='1';
    wait until rising_edge(clk);
    write_instruction_fifo<='0';
    
    instruction<=x"00C0";   -- TA1
    wait until rising_edge(clk);
    write_instruction_fifo<='1';
    wait until rising_edge(clk);
    write_instruction_fifo<='0';
    
    instruction<=x"0001";   -- TA2
    wait until rising_edge(clk);
    write_instruction_fifo<='1';
    wait until rising_edge(clk);
    write_instruction_fifo<='0';
    
    instruction<=x"0055"; -- data
    wait until rising_edge(clk);
    write_instruction_fifo<='1';
    wait until rising_edge(clk);
    write_instruction_fifo<='0';
    
    -- perform the transaction
    wait until rising_edge(clk);
    start_transaction<='1';
    wait until rising_edge(clk);
    start_transaction<='0';
    wait until transaction_completed='1';
    
    
    
    
    
    
  
    wait;
  end process;





  uut:entity work.OneWireMaster generic map(CLKS_PER_MICROSECOND=>100)
    port map(clk=>clk,
             write_instruction_fifo=>write_instruction_fifo,
             instruction=>instruction,
             read_data_fifo=>read_data_fifo,
             data_out=>data_out,
             read_data_fifo_empty=>read_data_fifo_empty,
             device_present=>device_present,
             start_transaction=>start_transaction,
             transaction_completed=>transaction_completed,
             one_wire=>one_wire);

end sim;
