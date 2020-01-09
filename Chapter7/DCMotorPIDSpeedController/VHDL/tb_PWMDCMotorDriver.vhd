----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_PWMDCMotorDriver is end;

----------------------------------------------------------------------------------
architecture sim of tb_PWMDCMotorDriver is
  signal clk:std_logic;
  signal val:std_logic_vector(15 downto 0):=(others=>'0');
  signal ld:std_logic:='0';
  signal pwm1:std_logic;
  signal pwm2:std_logic;
begin
  uut:entity work.PWMDCMotorDriver generic map(PERIOD_IN_CLK_CYCLES=>x"0008")
    port map(clk=>clk,val=>val,ld=>ld,pwm1=>pwm1,pwm2=>pwm2);

  clk_gen:process
  begin
    clk<='0';
    wait for 5 ns;
    clk<='1';
    wait for 5 ns;
  end process;
  
  stim:process
  begin
    wait for 100 ns;
    
    -- load zero no move
    wait until rising_edge(clk);
    ld<='1';
    wait until rising_edge(clk);
    ld<='0';

    wait for 1 us;
    
    val<=x"0001";
    wait until rising_edge(clk);
    ld<='1';
    wait until rising_edge(clk);
    ld<='0';

    wait for 1 us;
    
    val<=x"FFFF";
    wait until rising_edge(clk);
    ld<='1';
    wait until rising_edge(clk);
    ld<='0';

    wait for 1 us;

    val<=x"FFFC";
    wait until rising_edge(clk);
    ld<='1';
    wait until rising_edge(clk);
    ld<='0';

    wait for 1 us;

    val<=x"0004";
    wait until rising_edge(clk);
    ld<='1';
    wait until rising_edge(clk);
    ld<='0';
  
    wait;
  end process;


end;
