-- uart.vhd: UART controller - receiving part
-- Author(s): JAROSLAV STREIT xstrei06
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-------------------------------------------------
entity UART_RX is
port(	
   CLK		: 	in std_logic;
	RST		: 	in std_logic;
	DIN		: 	in std_logic;
	DOUT		: 	out std_logic_vector(7 downto 0);
	DOUT_VLD	: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
signal clk_cnt		: std_logic_vector(3 downto 0):= "0000";
signal clk_cnt2 	: std_logic_vector(3 downto 0):= "0000";
signal bit_cnt 	: std_logic_vector(3 downto 0):= "0000";
signal cnt_en		: std_logic;
signal cnt_en2		: std_logic;
signal writing		: std_logic := '0';
begin

	FSM: entity work.UART_FSM(behavioral)
		port map (
			CLK			=> CLK,
			RST			=> RST,
			DIN			=> DIN,
			CLK_CNT		=> clk_cnt,
			CLK_CNT2		=> clk_cnt2,
			BIT_CNT		=> bit_cnt,
			D_VLD			=> DOUT_VLD,
			CNT_EN		=> cnt_en,
			CNT_EN2		=> cnt_en2
		);		
		
		count: process(CLK, RST,cnt_en)
		begin
			if rising_edge(CLK) then
				if cnt_en = '1' then
					clk_cnt <= clk_cnt + "1";
				else
					clk_cnt <= "0000";
				end if;
			end if;
		end process;
		
		count2: process(CLK, cnt_en2, clk_cnt)
		begin
			if rising_edge(CLK) then
				if cnt_en2 = '1' then
					if clk_cnt = "1000" then
						clk_cnt2 <= "0000";
					elsif clk_cnt2 = "1111" then
						clk_cnt2 <= "0000";
					else
						clk_cnt2 <= clk_cnt2 + '1';
					end if;
				else
					clk_cnt2 <= "0000";
				end if;
			end if;
		end process;
		
		bit_count: process(CLK,cnt_en2, clk_cnt2)
			begin
				if rising_edge(CLK) then
					if cnt_en2 = '1' then
						if clk_cnt2 = "1111" then
							bit_cnt <= bit_cnt + '1';
						end if;
						if bit_cnt = "1001" then
							bit_cnt <= "0000";
						end if;
					end if;
				end if;
			end process;
			
		wrt: process(CLK,clk_cnt2)
			begin
				if rising_edge(CLK) then
					if clk_cnt2 = "1111" then
						writing <= '1';
					else
						writing <= '0';
					end if;
				end if;
			end process;
			
		reg: process(CLK,RST,cnt_en2, writing)
		begin
			if rising_edge(CLK) then
				if RST = '1' then
					DOUT <= "00000000";
				end if;
				if cnt_en2 = '1' then
					if writing = '1' then
						case bit_cnt is
							when "0001" => DOUT(0) <= DIN;
							when "0010" => DOUT(1) <= DIN;
							when "0011" => DOUT(2) <= DIN;
							when "0100" => DOUT(3) <= DIN;
							when "0101" => DOUT(4) <= DIN;
							when "0110" => DOUT(5) <= DIN;
							when "0111" => DOUT(6) <= DIN;
							when "1000" => DOUT(7) <= DIN;
							when others => null;
						end case;
					end if;
				end if;
			end if;
		end process;
	
end behavioral;
