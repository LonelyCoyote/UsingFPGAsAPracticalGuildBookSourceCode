----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
entity Decoder is
  port
  (
    clk:in std_logic;
    counter:out std_logic_vector(15 downto 0);  -- Interpreted as signed integer
    clear_counter:in std_logic;
    A:in std_logic;
    B:in std_logic
  );
end;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
architecture rtl of Decoder is
  signal sig_counter:std_logic_vector(15 downto 0):=(others=>'0');
  signal sig_syncA:std_logic;
  signal sig_syncB:std_logic;
  signal sig_pA:std_logic:='0';
  signal sig_pB:std_logic:='0';
begin
  counter<=sig_counter;
  process(clk)
    variable move:std_logic:='0';
    variable negative:std_logic:='0';
    variable stabilize_count:natural range 1 to 10:=1;
  begin
    if rising_edge(clk) then
      sig_pA<=sig_syncA;
      sig_pB<=sig_syncB;
      move:='0';
      negative:='0';
      
      -- if A stays the same and B changes
      if sig_pA=sig_syncA and sig_pB/=sig_syncB then
        move:='1';
        -- A is stable low B going high is negative
        if sig_pA='0' then
          if sig_syncB='1' then
            negative:='1';
          end if;  
        -- A is stable high B going low is negative
        else
          if sig_syncB='0' then
            negative:='1';
          end if;
        end if;
      end if;
      
      -- if B stays the same and A Changes
      if sig_pB=sig_syncB and sig_pA/=sig_syncA then
        move:='1';
        -- B is stable low A going low is negative
        if sig_pB='0' then
          if sig_syncA='0' then
            negative:='1';
          end if;
        else
        -- B is stable high A going high is negative
          if sig_syncA='1' then
            negative:='1';
            end if;
        end if;
      end if;
      
      if clear_counter='1' then
        sig_counter<=(others=>'0');
        stabilize_count:=1;
      end if;
      
      if stabilize_count=10 then
        if move='1' then
          if negative='1' then
            sig_counter<=std_logic_vector(unsigned(sig_counter)-1);
          else
            sig_counter<=std_logic_vector(unsigned(sig_counter)+1);
          end if;
        end if;
      else
        stabilize_count:=stabilize_count+1;
      end if;
      
    end if;
  end process;
  
  async:entity work.ThreeStageClkSync port map(clk=>clk,asyncsig=>A,syncsig=>sig_syncA);  
  bsync:entity work.ThreeStageClkSync port map(clk=>clk,asyncsig=>B,syncsig=>sig_syncB);  
end;

-- EOF ---------------------------------------------------------------------------

