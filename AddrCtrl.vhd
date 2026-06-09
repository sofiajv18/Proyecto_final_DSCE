----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.11.2025 15:43:09
-- Design Name: 
-- Module Name: AddrCtrl - Behavioral
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

entity AddrCtrl is
    Port ( clkDiv   : in  STD_LOGIC;
           nRST    : in  STD_LOGIC;
           DONE    : in  STD_LOGIC;
           addr_rd : out STD_LOGIC_VECTOR (13 downto 0); --guardar direcccion actual
           START   : out STD_LOGIC );
end AddrCtrl;

architecture Behavioral of AddrCtrl is
  -- Contador de direcciones de la RAM
  signal addr_counter_reg : unsigned(13 downto 0) := (others => '0');

  -- Señales para detectar flanco de DONE
  signal done_reg   : std_logic := '0'; -- valor anterior
  signal done_pulse : std_logic := '0'; -- pulso de 1 ciclo cuando DONE sube

  -- Señal de START interna
  signal start_reg  : std_logic := '0';
begin

  -- 1. DETECCIÓN DE FLANCO DE DONE
  ------------------------------------------------------------------
  process(clkDiv, nRST)
  begin
    if nRST = '0' then
      done_reg   <= '0';
      done_pulse <= '0';

    elsif rising_edge(clkDiv) then

      -- Detectamos flanco de subida (0 ? 1)
      if (DONE = '1' and done_reg = '0') then
        done_pulse <= '1';
      else
        done_pulse <= '0';
      end if;

      -- Guardamos el valor anterior
      done_reg <= DONE;

    end if;
  end process;

  ------------------------------------------------------------------
  -- 2. CONTADOR DE DIRECCIONES
  ------------------------------------------------------------------
  process(clkDiv, nRST)
  begin
    if nRST = '0' then
      addr_counter_reg <= (others => '0');

    elsif rising_edge(clkDiv) then

      -- Solo incrementa cuando termina una transmisión
      if done_pulse = '1' then
        if addr_counter_reg = 16383 then
          addr_counter_reg <= (others => '0'); -- reinicio
        else
          addr_counter_reg <= addr_counter_reg + 1;
        end if;
      end if;

    end if;
  end process;

  ------------------------------------------------------------------
  -- 3. GENERACIÓN DE START
  ------------------------------------------------------------------
  process(clkDiv, nRST)
  begin
    if nRST = '0' then
      start_reg <= '1'; -- primer arranque tras reset

    elsif rising_edge(clkDiv) then

      if done_pulse = '1' then
        start_reg <= '1'; -- nuevo dato
      else
        start_reg <= '0';
      end if;

    end if;
  end process;

  ------------------------------------------------------------------
  -- SALIDAS
  ------------------------------------------------------------------
  START   <= start_reg;
  addr_rd <= std_logic_vector(addr_counter_reg);

end Behavioral;