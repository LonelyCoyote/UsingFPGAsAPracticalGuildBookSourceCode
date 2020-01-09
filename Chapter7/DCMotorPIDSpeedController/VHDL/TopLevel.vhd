------------------------------------------------------------------------------------------------------------------------
-- TopLevel.vhd
--
-- Use this as a template for creating any Opal Kelly Project that uses the XEM7001
--
------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned.all;
use work.FRONTPANEL.all;

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
entity TopLevel is
	port (
		-- Opal Kelly Interface Signals (leave these as is)
		hi_in     : in    STD_LOGIC_VECTOR(7 downto 0);
		hi_out    : out   STD_LOGIC_VECTOR(1 downto 0);
		hi_inout  : inout STD_LOGIC_VECTOR(15 downto 0);
		hi_aa     : inout STD_LOGIC;
		hi_muxsel : out   STD_LOGIC;
		
		-- Application specific signals (change these to what you need per your xdc file)
		led       : out   STD_LOGIC_VECTOR(7 downto 0);
		button    : in    STD_LOGIC_VECTOR(3 downto 0);
		
		-- motor bidirectinal driver
		pwm1:     out std_logic;
		pwm2:     out std_logic;
		A:        in std_logic;
		B:        in std_logic
	);
end;

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
architecture rtl of TopLevel is
  -- 48Mhz system clock is used by OK's interface
  signal clk:std_logic;
  
  -- USB 2.0 endpoints are 16 bits wide
  subtype endPoint is std_logic_vector(15 downto 0);
  
  -- Wire in endpoints (max 32)
	signal wireIn00 : endPoint;
	signal wireIn01 : endPoint;
	signal wireIn02 : endPoint;
	
	-- Wire out endpoints (max 32)
	signal wireOut00 : endPoint;
	signal wireOut01 : endPoint;
	
	-- Trigger in endpoints (max 32)
  signal triggerIn00:endPoint;

	-- Trigger out endpoints (max 32)
  signal triggerOut00:endPoint;

	-- Pipe in endpoints (max 32)
  signal pipeIn00:endPoint;
  signal pipeIn00write:std_logic;

	-- Pipe out endpoints (max 32)
  signal pipeOut00:endPoint;
  signal pipeOut00read:std_logic;
begin

------------------------------------------------------------------------------------------------------------------------
-- Instantiate the okHost and connect endpoints
-- This will need modified to connect your design to OK's interface
------------------------------------------------------------------------------------------------------------------------
okHostInterface:block
	signal ti_clk   : STD_LOGIC;
	signal ok1      : STD_LOGIC_VECTOR(30 downto 0);
	signal ok2      : STD_LOGIC_VECTOR(16 downto 0);
	subtype epAddress is std_logic_vector(7 downto 0);

  -- These signals get wire-ored together to form the ok2 bus
  subtype ok2OredBus is std_logic_vector(16 downto 0);  -- subtype reminds us to wire or this type to ok2 bus
  signal ok2Ch01  : ok2OredBus;
  signal ok2Ch02  : ok2OredBus;
  signal ok2Ch03  : ok2OredBus;
  signal ok2Ch04  : ok2OredBus;
  signal ok2Ch05  : ok2OredBus;
begin
  -- if you add or remove endpoints that use ok2 bus, be sure to add/remove them from this 'or' logic
  ok2 <=ok2Ch01 or 
        ok2Ch02 or 
        ok2Ch03 or
        ok2Ch04 or
        ok2Ch05;

  hi_muxsel <= '0';
  clk<=ti_clk;
  
  okHI : okHost port map(hi_in=>hi_in,hi_out=>hi_out,hi_inout=>hi_inout,hi_aa=>hi_aa,ti_clk=>ti_clk,ok1=>ok1,ok2=>ok2);

  ----------------------------------------------------------------------------------------------------------------------
  -- Incoming endpoints block
  ----------------------------------------------------------------------------------------------------------------------
  incommingEndPoints:block
  begin
    --------------------------------------------------------------------------------------------------------------------
    wire:block
      constant BASE_ADDRESS:epAddress:=x"00";
    begin
      ep00 : okWireIn port map (ok1=>ok1, ep_addr=>BASE_ADDRESS+x"00", ep_dataout=>wireIn00);
      ep01 : okWireIn port map (ok1=>ok1, ep_addr=>BASE_ADDRESS+x"01", ep_dataout=>wireIn01);
      ep02 : okWireIn port map (ok1=>ok1, ep_addr=>BASE_ADDRESS+x"02", ep_dataout=>wireIn02);
    end block;

    --------------------------------------------------------------------------------------------------------------------
    trigger:block
      -- Note: trigger in's may use any clock you provide and will syncronize the one shot trigger to it
      constant BASE_ADDRESS:epAddress:=x"40";
    begin
      ep00 : okTriggerIn port map (ok1=>ok1, ep_addr=>BASE_ADDRESS+x"00", ep_clk=>clk, ep_trigger=>triggerIn00);
    end block;
    
    --------------------------------------------------------------------------------------------------------------------
    pipe:block
      constant BASE_ADDRESS:epAddress:=x"80";
    begin
      ep00 : okPipeIn port map(ok1=>ok1,ok2=>ok2Ch03,ep_addr=>BASE_ADDRESS+x"00",ep_dataout=>pipeIn00,ep_write=>pipeIn00write);
    end block;
  end block;
  
  ----------------------------------------------------------------------------------------------------------------------
  -- Outgoing endpoints block
  ----------------------------------------------------------------------------------------------------------------------
  outgoingEndPoints:block
  begin
    
    --------------------------------------------------------------------------------------------------------------------
    wire:block
      constant BASE_ADDRESS:epAddress:=x"20";
    begin
      ep00 : okWireOut port map (ok1=>ok1, ok2=>ok2Ch01, ep_addr=>BASE_ADDRESS+x"00", ep_datain=>wireOut00);
      ep01 : okWireOut port map (ok1=>ok1, ok2=>ok2Ch02, ep_addr=>BASE_ADDRESS+x"01", ep_datain=>wireOut01);
    end block;
    
    --------------------------------------------------------------------------------------------------------------------
    trigger:block
      -- Note: trigger out's may use any clock you provide and will syncronize the one shot trigger to it
      constant BASE_ADDRESS:epAddress:=x"60";
    begin
      ep00: okTriggerOut port map(ok1=>ok1,ok2=>ok2Ch04,ep_addr=>BASE_ADDRESS+x"00",ep_clk=>clk,ep_trigger=>triggerOut00);
    end block;
    
    --------------------------------------------------------------------------------------------------------------------
    pipe:block
      constant BASE_ADDRESS:epAddress:=x"A0";
    begin
      ep00: okPipeOut port map(ok1=>ok1,ok2=>ok2Ch05,ep_addr=>BASE_ADDRESS+x"00",ep_datain=>pipeOut00,ep_read=>pipeOut00read);
    end block;
  end block;
  
end block;

------------------------------------------------------------------------------------------------------------------------
-- Application specific stuff here
------------------------------------------------------------------------------------------------------------------------
application:block
begin
  -- TEMPLATE DEMO ONLY, CHANGE CODE BELOW THIS LINE FOR THE SPECIFIC APPLICATION
  led<=not wireOut00(7 downto 0);
  
  mtrdrvr:entity work.PWMDCMotorDriver generic map(PERIOD_IN_CLK_CYCLES=>x"4000")
    port map(clk=>clk,val=>wireIn00,ld=>triggerIn00(0),pwm1=>pwm1,pwm2=>pwm2);
    
  speedMonitor:entity work.DecoderSpeedMonitor
    generic map(GATE_TIME_IN_CLK_CYCLES=>4800000)
    port map(clk=>clk,current_speed=>wireOut00,A=>A,B=>B);
  
end block;

end;



