----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity DisplayTemperature is
  generic
  (
    CLKS_PER_MICROSECOND:natural:=48
  );
  port
  (
    clk:in std_logic;
    FixedPointTemp:out std_logic_vector(11 downto 0);
    modeCorF: in std_logic; -- High for C low for F
    
    -- To FPGA IO Ring
    signal A:out std_logic;
    signal B:out std_logic;
    signal C:out std_logic;
    signal D:out std_logic;
    signal E:out std_logic;
    signal F:out std_logic;
    signal G:out std_logic;
    signal DP:out std_logic;
    signal Digit1:out std_logic;
    signal Digit2:out std_logic;
    signal Digit3:out std_logic;
    signal Digit4:out std_logic;
    
    signal one_wire:inout std_logic
  );
end DisplayTemperature;

----------------------------------------------------------------------------------
architecture rtl of DisplayTemperature is
  type statemachine is (INIT_PH1,INIT_PH2,INIT_PH3,GET_READING_PH1,GET_READING_PH2,GET_READING_PH3);
  signal state:statemachine:=INIT_PH1;
  signal sig_init:std_logic:='0';
  signal sig_start:std_logic:='0';
  signal sig_done:std_logic;
  signal sig_FixedPointCTemp:std_logic_vector(11 downto 0);
  signal sig_FixedPointFTemp:std_logic_vector(11 downto 0);
  signal sig_FixedPointToDisplay:std_logic_vector(11 downto 0);
begin
  sig_FixedPointToDisplay<=sig_FixedPointCTemp when modeCorF='1' else sig_FixedPointFTemp;
  FixedPointTemp<=sig_FixedPointToDisplay;

  process(clk)
  begin
    if rising_edge(clk) then
      sig_init<='0';
      sig_start<='0';
      case state is
----------------------------------------------------------------------------------
        when INIT_PH1=>
          sig_init<='1';
          state<=INIT_PH2;
----------------------------------------------------------------------------------
        when INIT_PH2=>
          state<=INIT_PH3;
          
----------------------------------------------------------------------------------
        when INIT_PH3=>
          if sig_done='1' then
            state<=GET_READING_PH1;
          end if;
          
----------------------------------------------------------------------------------
        when GET_READING_PH1=>
          sig_start<='1';
          state<=GET_READING_PH2;
          
----------------------------------------------------------------------------------
        when GET_READING_PH2=>
          state<=GET_READING_PH3;
          
----------------------------------------------------------------------------------
        when GET_READING_PH3=>
          if sig_done='1' then
            state<=GET_READING_PH1;
          end if;
      end case;
    end if;
  end process;
  
  TSense:entity work.OneWireTemperatureSensor_MAX31820
    generic map(CLKS_PER_MICROSECOND=>CLKS_PER_MICROSECOND)
    port map(clk=>clk,init=>sig_init,start=>sig_start,done=>sig_done,EightDotFour=>sig_FixedPointCTemp,
      one_wire=>one_wire);
      
  Display:entity work.DisplayFixedPointOn7Segment
    port map(clk=>clk,EigthDotFour=>sig_FixedPointToDisplay,
      A=>A,B=>B,C=>C,D=>D,E=>E,F=>F,G=>G,DP=>DP,
      Digit1=>Digit1,Digit2=>Digit2,Digit3=>Digit3,Digit4=>Digit4);
      
  cToFConv:entity work.CtoF port map(Cin=>sig_FixedPointCTemp,Fout=>sig_FixedPointFTemp);

end rtl;

-- EOF ---------------------------------------------------------------------------














