-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    
    signal clk_cnt_l : std_logic_vector(4 downto 0) := "00000";
    signal bit_cnt_l : std_logic_vector(3 downto 0) := "0000";

    signal dout_l : std_logic_vector(7 downto 0) := "00000000";
    
    signal read_l : std_logic := '0';
    signal valid_l : std_logic := '0';
    signal clk_en_l : std_logic := '0';
    
begin
    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        data_in => DIN,

        clk_cnt => clk_cnt_l,
        bit_cnt => bit_cnt_l,
        
        clk_en => clk_en_l,
        valid => valid_l,
        read => read_l

    );


    main_loop : process (CLK, RST)
    begin
        if rising_edge(clk) then
            if valid_l = '0' then
                DOUT <= "00000000";
                DOUT_VLD <= '0';
            end if;
            if clk_en_l = '1' then
                if read_l = '0' and valid_l = '0' and clk_cnt_l = x"15" then
                    clk_cnt_l <= "00000";
                elsif read_l = '1' and valid_l = '0' and clk_cnt_l = x"0f" then
                    clk_cnt_l <= "00000";
                elsif read_l = '1' and valid_l = '1' and clk_cnt_l = x"10" then
                    clk_cnt_l <= "00000";
                    bit_cnt_l <= "0000";
                else
                    clk_cnt_l <= clk_cnt_l + 1;
                end if;
                    
            elsif clk_en_l = '0' then 
                clk_cnt_l <= "00000";
            else
                clk_cnt_l <= "00000";
            end if;
            if read_l = '1' and clk_cnt_l = "00000" then
                if DIN = '1' then
                case bit_cnt_l is
                    when "0000" =>
                        dout_l <= dout_l + "00000001";
                    when "0001" =>
                        dout_l <= dout_l + "00000010";
                    when "0010" =>
                        dout_l <= dout_l + "00000100";
                    when "0011" =>
                        dout_l <= dout_l + "00001000";
                    when "0100" =>
                        dout_l <= dout_l + "00010000";
                    when "0101" =>
                        dout_l <= dout_l + "00100000";
                    when "0110" =>
                        dout_l <= dout_l + "01000000";
                    when "0111" =>
                        dout_l <= dout_l + "10000000";
                    when others =>
                        null;
                end case;
            end if;
            bit_cnt_l <= bit_cnt_l + 1;
        end if;
        if clk_en_l = '1' and valid_l = '1' and read_l = '0' then
            DOUT_VLD <= '1';
        end if;
        DOUT <= dout_l;
        if clk_en_l = '0' and valid_l = '0' and read_l = '0' then
            dout_l <= "00000000";
        end if;
    end if;
            
    end process main_loop;

end architecture;
