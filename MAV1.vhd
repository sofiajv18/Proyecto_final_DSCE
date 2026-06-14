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
        N : integer := 16--4096  -- número de muestras
    );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (11 downto 0);
           mav_out : out STD_LOGIC_VECTOR (11 downto 0);
           mav_ready : out STD_LOGIC;
           data_ready : in std_logic);
end MAV1;

architecture Behavioral of MAV1 is

    -- Memoria que almacena las últimas N muestras
    type sample_array is array (0 to N - 1) of unsigned(11 downto 0);
    signal samples : sample_array :=(others => (others => '0'));
    -- Acumulador de la suma de las muestras
    signal acc : unsigned(23 downto 0) :=(others => '0');
    -- Posicion de escritura dentro de la memoria circular
    signal write_index :integer range 0 to N - 1 := 0;
    signal sample_count :integer range 0 to N := 0; --Numero de muestras recibidas durante el llenado inicial
    signal mav_reg : unsigned(11 downto 0) :=(others => '0');

    -- Pulso que indica que el resultado es valido
    signal ready_s : std_logic := '0';
begin
    process(clk)
        variable new_sum : unsigned(23 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '0' then
                samples      <= (others => (others => '0'));
                acc          <= (others => '0');
                write_index  <= 0;
                sample_count <= 0;
                mav_reg      <= (others => '0');
                ready_s      <= '0';
            else
                ready_s <= '0';

                if data_ready = '1' then ---- Solo procesa una nueva muestra valida
                    -- Llenado inicial de la ventana
                    if sample_count < N then
                        -- Suma la nueva muestra
                        new_sum := acc + resize(unsigned(data_in),acc'length);
                        acc <= new_sum;
                        -- Guarda la nueva muestra en la memoria
                        samples(write_index) <= unsigned(data_in);
                        
                        -- Incrementa el indice circular
                        if write_index = N - 1 then
                            write_index <= 0;
                        else
                            write_index <= write_index + 1;
                        end if;
                        
                        -- Cuando llegan las primeras N muestras calcula la primera media
                        if sample_count = N - 1 then
                            sample_count <= N;
                            mav_reg <= resize(new_sum / N,mav_reg'length);
                            ready_s <= '1';
                        else
                            sample_count <= sample_count + 1;
                        end if;
                    -- Ventana completa: media movil
                    else
                        -- Resta la muestra más antigua y suma la muestra nueva
                        new_sum := acc - resize(samples(write_index),acc'length)+ resize(unsigned(data_in),acc'length);
                        acc <= new_sum;
                        -- Sustituye la muestra más antigua
                        samples(write_index) <=unsigned(data_in);
                        -- Calcula la nueva media movil
                        mav_reg <= resize(new_sum / N,mav_reg'length);
                        ready_s <= '1';
                        
                        if write_index = N - 1 then
                            write_index <= 0;
                        else
                            write_index <= write_index + 1;
                        end if;
                        
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    mav_out   <= std_logic_vector(mav_reg);
    mav_ready <= ready_s;
    
end Behavioral;