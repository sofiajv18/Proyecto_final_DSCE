----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.10.2025 12:59:44
-- Design Name: 
-- Module Name: ram - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram is
    Port ( clk : in STD_LOGIC;
           wr_en : in STD_LOGIC;  --escritura
           addr_wr : in STD_LOGIC_VECTOR (13 downto 0); -- direccion escritura
           data_in : in STD_LOGIC_VECTOR (11 downto 0); --dato a guardar
           addr_rd : in STD_LOGIC_VECTOR (13 downto 0); -- direccion de lectura
           data_out : out STD_LOGIC_VECTOR (11 downto 0)); -- dato leido
end ram;

architecture Behavioral of ram is

    constant ADDR_WIDTH : integer := 14; -- Para 16384 direcciones (2^14)
    constant DATA_WIDTH : integer := 12; -- Para datos de 12 bits
    subtype ram_word_t is std_logic_vector(DATA_WIDTH-1 downto 0); -- Un dato de 12 bits
    type ram_array_t is array (0 to (2**ADDR_WIDTH)-1) of ram_word_t; -- El array de memoria

    signal memory_core : ram_array_t:= (others => (others => '0')); -- RAM real
    signal read_reg : ram_word_t := (others => '0');
begin
RAM_Access_Proc : process (clk)
    begin
        if rising_edge(clk) then
            -- Escritura: Solo ocurre si wr_en = '1'
            if wr_en = '1' then
                memory_core(to_integer(unsigned(addr_wr))) <= data_in;
            end if;
            -- Lectura: Ocurre siempre en cada ciclo de reloj
            -- La salida data_out mostrará el contenido de la dirección addr_rd
            read_reg <= memory_core(to_integer(unsigned(addr_rd)));
        end if;
    end process RAM_Access_Proc;
    data_out <= read_reg;
end Behavioral;