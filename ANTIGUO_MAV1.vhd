----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.04.2026 02:37:14
-- Design Name: 
-- Module Name: MAV1 - Behavioral
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

entity MAV1 is

    Generic (
        N : integer := 4096  -- número de muestras
    );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (11 downto 0);
           mav_out : out STD_LOGIC_VECTOR (11 downto 0);
           mav_ready : out STD_LOGIC;
           data_ready : in std_logic);
end MAV1;

architecture Behavioral of MAV1 is

    signal acc      : unsigned(23 downto 0) := (others => '0'); -- acumulador
    signal count    : integer range 0 to N := 0;
    signal mav_reg  : unsigned(11 downto 0) := (others => '0');
    signal ready_s  : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                acc     <= (others => '0');
                count   <= 0;
                mav_reg <= (others => '0');
                ready_s <= '0';
            else
                ready_s <= '0';  --resetear cada ciclo

                if data_ready = '1' then
                    acc <= acc + unsigned(data_in);
--                    count <= count + 1;

                    if count = N-1 then
                        -- división por N (4096 = 2^12 shift)
                        mav_reg <= acc(23 downto 12);
                       
                        acc <= (others => '0');
                        count <= 0;
                        ready_s <= '1'; --dato valido
                        else
                            count <= count + 1;
                    end if;
                end if;
        end if;
        end if;
    end process;

    mav_out <= std_logic_vector(mav_reg);
    mav_ready <= ready_s;

end Behavioral;
