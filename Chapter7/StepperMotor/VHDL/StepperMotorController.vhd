----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


----------------------------------------------------------------------------------
entity StepperMotorController is
  generic
  (
    CLKS_PER_MICROSECOND:natural range 1 to 400:=48
  );
  port
  (
    clk:in std_logic;
    dir:in std_logic;
    pulses_to_move:in std_logic_vector(15 downto 0);  -- number of pulses to move, ignored if continous='1'
    microseconds_between_pulses_lo_word:in std_logic_vector(15 downto 0);
    microseconds_between_pulses_hi_word:in std_logic_vector(3 downto 0);
    enabled:in std_logic; -- asyncronous, you can enable or disable the motor drive at any time
    continuous:in std_logic; -- angle to move ignored in continous
    start:in std_logic; -- command to start the moving
    done: out std_logic;  -- only valid if continous is false
    
    ph1:out std_logic;
    ph2:out std_logic;
    ph3:out std_logic;
    ph4:out std_logic
  );
end;

----------------------------------------------------------------------------------
architecture rtl of StepperMotorController is
  type statemachine is (WAIT_FOR_START,SEND_PULSE,DELAY);
  signal state:statemachine:=WAIT_FOR_START;
  signal sig_done:std_logic:='1';
  signal clock_counter:natural:=1;
  signal pulse_count:natural:=1;
  signal sig_step:std_logic:='0';
begin
  done<=sig_done;
  process(clk)
    variable clks_per_pulse:std_logic_vector(39 downto 0):=(others=>'0');
  begin
    if rising_edge(clk) then
      sig_done<='0';
      sig_step<='0';
      case state is
        -------------------------------------------------------------------------
        when WAIT_FOR_START=>
          sig_done<='1';
          if start='1' then
            clks_per_pulse:=(others=>'0');
            clks_per_pulse(15 downto 0):=microseconds_between_pulses_lo_word;
            clks_per_pulse(19 downto 16):=microseconds_between_pulses_hi_word;
            clks_per_pulse:=std_logic_vector(unsigned(clks_per_pulse(19 downto 0))*CLKS_PER_MICROSECOND);
            sig_done<='0';
            clock_counter<=1;
            pulse_count<=1;
            state<=SEND_PULSE;
          end if;
        
        -------------------------------------------------------------------------
        when SEND_PULSE=>
          sig_step<='1';
          state<=DELAY;
        
        -------------------------------------------------------------------------
        when DELAY=>
          if clock_counter=unsigned(clks_per_pulse) then
            clock_counter<=1;
            if continuous='0' then
              if pulse_count=unsigned(pulses_to_move) then
                state<=WAIT_FOR_START;
              else
                state<=SEND_PULSE;
                pulse_count<=pulse_count+1;
              end if;
            else
              pulse_count<=to_integer(unsigned(pulses_to_move));
              state<=SEND_PULSE;
            end if;
          else
            clock_counter<=clock_counter+1;
          end if;
      end case;
    end if;
  end process;
  
  drvr:entity work.StepperMotorDriver port map(clk=>clk,step=>sig_step,dir=>dir,
    enabled=>enabled,ph1=>ph1,ph2=>ph2,ph3=>ph3,ph4=>ph4);
  
end;

-- EOF ---------------------------------------------------------------------------
