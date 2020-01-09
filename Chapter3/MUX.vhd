----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/12/2019 05:55:49 PM
-- Design Name: 
-- Module Name: MUX - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MUX is
  port
  (
    s:in std_logic_vector(3 downto 0);
    b:in std_logic_vector(1 downto 0);
    output:out std_logic
  );
end MUX;

architecture rtl of MUX is
  signal sig_c1:std_logic;
  signal sig_c2:std_logic;
begin
  -- instantiate the D1 OR gate
  output<=sig_c1 or sig_c2;
  
  -- instantiate both C1 and C2 OR gates
  c:block
    signal sig_b1:std_logic;
    signal sig_b2:std_logic;
    signal sig_b3:std_logic;
    signal sig_b4:std_logic;
  begin
    sig_c1<=sig_b1 or sig_b2;
    sig_c2<=sig_b3 or sig_b4;
  
    -- instantiate all 4 'B' gates
    bb:block
      signal sig_a1:std_logic;
      signal sig_a2:std_logic;
      signal sig_a3:std_logic;
      signal sig_a4:std_logic;
    begin
      b1:entity work.AND2 port map(i1=>s(3),i2=>sig_a1,o1=>sig_b1);
      b2:entity work.AND2 port map(i1=>s(2),i2=>sig_a2,o1=>sig_b2);
      b3:entity work.AND2 port map(i1=>s(1),i2=>sig_a3,o1=>sig_b3);
      b4:entity work.AND2 port map(i1=>s(0),i2=>sig_a4,o1=>sig_b4);
      
      -- instantiate all 4 'A' gates
      a:block
        signal sig_nb:std_logic_vector(1 downto 0);
      begin
        sig_nb<=not b;
        a1:entity work.AND2 port map(i1=>b(1),i2=>b(0),o1=>sig_a1);
        a2:entity work.AND2 port map(i1=>b(1),i2=>sig_nb(0),o1=>sig_a2);
        a3:entity work.AND2 port map(i1=>sig_nb(1),i2=>b(0),o1=>sig_a3);
        a4:entity work.AND2 port map(i1=>sig_nb(1),i2=>sig_nb(0),o1=>sig_a4);
      end block;
    end block;
  end block;
end rtl;
