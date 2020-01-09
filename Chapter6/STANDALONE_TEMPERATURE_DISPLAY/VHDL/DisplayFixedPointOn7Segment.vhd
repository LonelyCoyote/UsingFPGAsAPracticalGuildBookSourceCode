----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
entity DisplayFixedPointOn7Segment is
  generic
  (
    CLKS_BETWEEN_DIGIT_UPDATES:natural:=12000
  );
  port
  (
    clk:in std_logic;
    EigthDotFour:in std_logic_vector(11 downto 0);
    
    -- To FPGA IO Ring
    A: out std_logic;
    B: out std_logic;
    C: out std_logic;
    D: out std_logic;
    E: out std_logic;
    F: out std_logic;
    G: out std_logic;
    DP: out std_logic;
    
    Digit1: out std_logic;
    Digit2: out std_logic;
    Digit3: out std_logic;
    Digit4: out std_logic
  );
end;

----------------------------------------------------------------------------------
architecture rtl of DisplayFixedPointOn7Segment is
  signal sig_digit1:std_logic_vector(6 downto 0);
  signal sig_digit2:std_logic_vector(6 downto 0);
  signal sig_digit3:std_logic_vector(6 downto 0);
  signal sig_digit4:std_logic_vector(6 downto 0);
begin

  ----------------------------------------------------------------------------------
  display_driver:block
    type stateMachine is (STATE_DIGIT1,STATE_DIGIT2,STATE_DIGIT3,STATE_DIGIT4);
    signal state:stateMachine:=STATE_DIGIT1;

    signal sig_current_digit:std_logic_vector(6 downto 0):=(others=>'0');
    signal sig_activateDigit1:std_logic:='0';
    signal sig_activateDigit2:std_logic:='0';
    signal sig_activateDigit3:std_logic:='0';
    signal sig_activateDigit4:std_logic:='0';
    signal sig_activateDecimalPoint:std_logic:='0';

  begin
    dd:process(clk)
      variable clk_counter:natural range 1 to CLKS_BETWEEN_DIGIT_UPDATES:=1;
    begin
      if rising_edge(clk) then
        sig_current_digit<=(others=>'0');
        sig_activateDigit1<='0';
        sig_activateDigit2<='0';
        sig_activateDigit3<='0';
        sig_activateDigit4<='0';
        sig_activateDecimalPoint<='0';
        case state is
          ----------------------------------------------------------------------------------
          when STATE_DIGIT1 =>
            sig_current_digit<=sig_digit1;
            sig_activateDigit1<='1';
            if clk_counter=CLKS_BETWEEN_DIGIT_UPDATES then
              clk_counter:=1;
              state<=STATE_DIGIT2;
            else
              clk_counter:=clk_counter+1;
            end if;  
            
          ----------------------------------------------------------------------------------
          when STATE_DIGIT2 =>
            sig_current_digit<=sig_digit2;
            sig_activateDigit2<='1';
            sig_activateDecimalPoint<='1';
            if clk_counter=CLKS_BETWEEN_DIGIT_UPDATES then
              clk_counter:=1;
              state<=STATE_DIGIT3;
            else
              clk_counter:=clk_counter+1;
            end if;  
            
          ----------------------------------------------------------------------------------
          when STATE_DIGIT3 =>
            sig_current_digit<=sig_digit3;
            sig_activateDigit3<='1';
            if clk_counter=CLKS_BETWEEN_DIGIT_UPDATES then
              clk_counter:=1;
              state<=STATE_DIGIT4;
            else
              clk_counter:=clk_counter+1;
            end if;
              
          ----------------------------------------------------------------------------------
          when STATE_DIGIT4 =>
            sig_current_digit<=sig_digit4;
            sig_activateDigit4<='1';
            if clk_counter=CLKS_BETWEEN_DIGIT_UPDATES then
              clk_counter:=1;
              state<=STATE_DIGIT1;
            else
              clk_counter:=clk_counter+1;
            end if; 
             
        end case;
      end if;
    end process;

    Digit1<='Z' when sig_activateDigit1='0' else '1';
    Digit2<='Z' when sig_activateDigit2='0' else '1';
    Digit3<='Z' when sig_activateDigit3='0' else '1';
    Digit4<='Z' when sig_activateDigit4='0' else '1';
    A<='Z' when sig_current_digit(6)='0' else '0';
    B<='Z' when sig_current_digit(5)='0' else '0';
    C<='Z' when sig_current_digit(4)='0' else '0';
    D<='Z' when sig_current_digit(3)='0' else '0';
    E<='Z' when sig_current_digit(2)='0' else '0';
    F<='Z' when sig_current_digit(1)='0' else '0';
    G<='Z' when sig_current_digit(0)='0' else '0';
    DP<='Z' when sig_activateDecimalPoint='0' else '0';
  end block;



  ----------------------------------------------------------------------------------
  primary_converter:block
    signal sig_tens:std_logic_vector(3 downto 0);
    signal sig_ones:std_logic_vector(3 downto 0);
    signal sig_frac_tenths:std_logic_vector(3 downto 0);
    signal sig_frac_hundreths:std_logic_vector(3 downto 0);
    signal sig_7segment:std_logic_vector(6 downto 0);
  begin
    bcd2:entity work.BinaryToBCD2 port map(binary_in=>EigthDotFour(11 downto 4),
      tens=>sig_tens,ones=>sig_ones);
    fract:entity work.Fract4ToBCD port map(fract4=>EigthDotFour(3 downto 0),tenths=>
      sig_frac_tenths,hundreths=>sig_frac_hundreths);
    bcd27seg1:entity work.BCDTo7Segment port map(bcd=>sig_tens,sevenSegment=>sig_digit1);
    bcd27seg2:entity work.BCDTo7Segment port map(bcd=>sig_ones,sevenSegment=>sig_digit2);
    bcd27seg3:entity work.BCDTo7Segment port map(bcd=>sig_frac_tenths,sevenSegment=>sig_digit3);
    bcd27seg4:entity work.BCDTo7Segment port map(bcd=>sig_frac_hundreths,sevenSegment=>sig_digit4);
  end block;

end rtl;

-- EOF ---------------------------------------------------------------------------

