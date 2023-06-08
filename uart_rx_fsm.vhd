-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
      CLK : in std_logic;
      RST : in std_logic;
      DATA_IN : in std_logic;
      CLK_CNT : in std_logic_vector(4 downto 0);
      BIT_CNT : in std_logic_vector(3 downto 0);
      
      READ : out std_logic;
      VALID : out std_logic;
      CLK_EN : out std_logic
    );
end entity;



architecture behavioral of UART_RX_FSM is
   type state_fsm is (S0, S1, S2, S3, S4);
   signal current_st : state_fsm;
   signal next_st : state_fsm;
begin
   check_state : process (CLK, RST)
   begin
      if RST = '1' then
         current_st <= S0;
      elsif rising_edge(CLK) then
         current_st <= next_st;
      end if;
   end process check_state;
   
    signal_out : process (current_st)
    begin
    case current_st is
       when S0 =>
          READ <= '0';
          VALID <= '0';
          CLK_EN <= '0';
       when S1 =>
          READ <= '0';
          VALID <= '0';
          CLK_EN <= '1';
       when S2 =>
          READ <= '1';
          VALID <= '0';
          CLK_EN <= '1';
       when S3 =>
          READ <= '1';
          VALID <= '1';
          CLK_EN <= '1';
       when S4 =>
          READ <= '0';
          VALID <= '1';
          CLK_EN <= '1';
       when others =>
          READ <= '1';
          VALID <= '0';
          CLK_EN <= '0';
       end case;
    end process signal_out;

    det_state : process (current_st, DATA_IN, CLK_CNT, BIT_CNT)
    begin
    case current_st is
       when S0 =>
          if DATA_IN = '0' then
             next_st <= S1;
          end if;
       when S1 =>
          if CLK_CNT = x"15" then
             next_st <= S2;
          end if;
       when S2 =>
          if BIT_CNT = x"8" then
             next_st <= S3;
          end if;
       when S3 =>
          if CLK_CNT = x"10" then
             next_st <= S4;
          end if;
       when S4 =>
          if CLK_CNT = x"0" then
             next_st <= S0;
          end if;
       when others =>
             next_st <= S0;
       end case;
    end process det_state;
      
end architecture;
