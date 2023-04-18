-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): JAROSLAV STREIT xstrei06
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK 		: in std_logic;
   RST 		: in std_logic;
	DIN 		: in std_logic;
	CLK_CNT 	: in std_logic_vector(3 downto 0);
	CLK_CNT2 : in std_logic_vector(3 downto 0);
	BIT_CNT 	: in std_logic_vector(3 downto 0);
	D_VLD 	: out std_logic;
	CNT_EN	: out std_logic;
	CNT_EN2	: out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type STATE_TYPE is (STALL, START_BIT, READ_MID, WAIT_STOP, VALID_END);
signal state : STATE_TYPE := STALL;

begin

	D_VLD <= '1' when state = VALID_END and DIN = '1'
	else '0';
	CNT_EN <= '1' when state = START_BIT
	else '0';
	CNT_EN2 <= '1' when state = READ_MID or state = WAIT_STOP
	else '0';
	
	process (CLK,state,DIN,CLK_CNT,BIT_CNT,CLK_CNT2) begin
		if rising_edge(CLK) then
			if RST = '1' then
				state <= STALL;
			else
				case state is				
				when STALL => if DIN = '0' then
										state <= START_BIT;
									end if;
				when START_BIT => if CLK_CNT = "1000" then
											state <= READ_MID;
										end if;								
				when READ_MID => if BIT_CNT = "1000" then
											state <= WAIT_STOP;
										end if;
				when WAIT_STOP => if BIT_CNT = "1001" then
											state <= VALID_END;
										end if;		
				when VALID_END => if DIN = '1' then
											state <= STALL;
										elsif DIN = '0' then
											state <= START_BIT;
										end if;				
				when others => null;
				end case;
			end if;
		end if;
	end process;
end behavioral;
