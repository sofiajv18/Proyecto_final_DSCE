----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.04.2026 20:41:58
-- Design Name: 
-- Module Name: shift_register_adc - Behavioral
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

entity shift_register_adc is
    Port ( clkDiv : in STD_LOGIC;
           nRST : in STD_LOGIC;
           DIN : in STD_LOGIC;--dato serie del adc
           enShift : in STD_LOGIC; -- HABIlita lectura
           DONE : in STD_LOGIC;
           DATA_IN : out STD_LOGIC_VECTOR (11 downto 0);
           bit_cnt : out STD_LOGIC_VECTOR (4 downto 0));
end shift_register_adc;

architecture Behavioral of shift_register_adc is

    signal shift_reg : std_logic_vector(11 downto 0) := (others => '0');
    signal counter   : unsigned(4 downto 0) := (others => '0');
    
begin
    process(clkDiv, nRST)
    begin
        if nRST = '0' then
            shift_reg <= (others => '0');
            counter   <= (others => '0');

        elsif rising_edge(clkDiv) then

            if enShift = '1' then
--                -- desplaza e introduce nuevo bit
--                shift_reg <= shift_reg(10 downto 0) & DOUT;

--                -- incrementa contador
--                if counter < 12 then
--                    counter <= counter + 1;
--                end if;
--            else
--                -- si no estamos leyendo, reinicia contador
--                counter <= (others => '0');
--                shift_reg <= (others => '0');

                if counter < 16 then   -- evita el último shift extra
                    if counter >= 4 then
                        shift_reg <= shift_reg(10 downto 0) & DIN;
                    end if;
            
                    counter <= counter + 1;
                end if;
--            else
--                counter <= (others => '0');
--            end if;
              elsif DONE = '1' then
                counter <= (others => '0');
              end if;

        end if;
    end process;

    DATA_IN <= shift_reg;
    bit_cnt  <= std_logic_vector(counter);

end Behavioral;
