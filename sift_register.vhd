----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.10.2025 12:26:49
-- Design Name: 
-- Module Name: sift_register - Behavioral
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

entity sift_register is
    Port ( clkDiv : in STD_LOGIC; --1MHz
           nRST : in STD_LOGIC; --activo bajo
           DATA1 : in STD_LOGIC_VECTOR (11 downto 0); --12bits
           LoadData : in STD_LOGIC;--cargar dato
           enSift : in STD_LOGIC; --empezar a enviar bits
           D1 : out STD_LOGIC;-- salida al DAC
           SiftCounter : out STD_LOGIC_VECTOR (3 downto 0));--contador de bits enviados
end sift_register;

architecture Behavioral of sift_register is

  -- Señales internas:
  signal shift_reg   : std_logic_vector(15 downto 0) := (others => '0');
  signal counter_reg : unsigned(3 downto 0) := (others => '0');-- contador de 0-15

begin

  Shift_Proc : process (clkDiv, nRST)
  begin
    if nRST = '0' then -- Reset activo bajo
      shift_reg   <= (others => '0');
      counter_reg <= (others => '0');
      --D1 <= '0';

    elsif rising_edge(clkDiv) then

      if LoadData = '1' then
        -- Cargar trama completa de 16 bits del Pmod DA1:
        shift_reg <= "0000" & DATA1;   -- bits 15 downto 12 = 0000, resto datos
        counter_reg <= (others => '0'); -- Reinicia el contador a 0

      elsif enSift = '1' then --empieza transmision
        --D1 <= shift_reg(15); --añadido antes
        -- Desplaza el registro 1 bit a la izquierda
        shift_reg <= shift_reg(14 downto 0) & '0'; -- *quita el primer bit
        -- Incrementa el contador
        counter_reg <= counter_reg + 1;
      end if;
    end if;
  end process Shift_Proc;

  D1 <= shift_reg(15); --salida sacar el MSB

  SiftCounter <= std_logic_vector(counter_reg);

end Behavioral;
