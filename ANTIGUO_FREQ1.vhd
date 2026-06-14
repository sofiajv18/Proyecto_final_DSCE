----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.04.2026 02:40:22
-- Design Name: 
-- Module Name: FREQ1 - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FREQ1 is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (11 downto 0);
           freq_out : out STD_LOGIC_VECTOR (31 downto 0);
           freq_ready : out STD_LOGIC;
           data_ready : in std_logic);
end FREQ1;

architecture Behavioral of FREQ1 is

    constant CLK_FREQ : integer := 200000000; -- 200 MHz reloj principal

    signal counter       : integer := 0;
    signal period_count  : integer := 1;
    signal prev_data     : unsigned(11 downto 0) := (others => '0');
    signal freq_reg      : unsigned(31 downto 0) := (others => '0');
    signal ready_s       : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                counter <= 0;
                period_count <= 1;
                freq_reg <= (others => '0');
                ready_s <= '0';
            else
                ready_s <= '0';  

                if data_ready = '1' then
                    counter <= counter + 1;
                    --freq_reg <= to_unsigned(counter, 32); -- salida visible
    
--                    -- Detectar reinicio de rampa (cuando baja)
--                    if unsigned(data_in) < prev_data then
                    if (unsigned(prev_data) > 150) and (unsigned(data_in) < 80) then
                        period_count <= counter;
                        counter <= 1;
    
                        -- f=clk/N
                        if period_count /= 0 then
                            freq_reg <= to_unsigned(CLK_FREQ / period_count, 32);
                            ready_s <= '1'; --dato valido
                        end if;
                    end if;
    
                    prev_data <= unsigned(data_in);
                end if;
            end if;
            end if;
    end process;

    freq_out <= std_logic_vector(freq_reg);
    freq_ready <= ready_s;
        

end Behavioral;
