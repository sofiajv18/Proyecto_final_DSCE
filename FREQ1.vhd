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

    -- Contador de ciclos entre dos reinicios de la rampa
    constant CLK_FREQ_U : unsigned(31 downto 0) := to_unsigned(CLK_FREQ, 32);
    -- Periodo teorico
    -- Para DAC_CLK=25MHz: f_rampa =25MHz/(16×4096)= aprox 381 Hz 
    -- Periodo esperado a 200 MHz:aprox 524288 ciclos

    constant MIN_PERIOD_CYCLES : unsigned(31 downto 0):= to_unsigned(300000, 32);
    constant MAX_PERIOD_CYCLES : unsigned(31 downto 0):= to_unsigned(900000, 32);

    -- Medicion del periodo
    signal counter : unsigned(31 downto 0):=(others => '0');
    signal prev_data : unsigned(11 downto 0):=(others => '0');

    signal first_fall_found : STD_LOGIC := '0';
    -- Salida
    signal freq_reg : unsigned(31 downto 0):=(others => '0');
    signal ready_s : STD_LOGIC := '0';
    -- Divisor secuencial
    signal div_busy : STD_LOGIC := '0';
    signal dividend_reg : unsigned(31 downto 0):=(others => '0');
    signal divisor_reg : unsigned(31 downto 0):=(others => '0');
    signal quotient_reg : unsigned(31 downto 0):=(others => '0');
    signal remainder_reg : unsigned(32 downto 0):=(others => '0');
    signal div_count :integer range 0 to 31 := 0;
    
begin
    process(clk)
        variable current_data :unsigned(11 downto 0);
        variable period_cycles :unsigned(31 downto 0);
        variable remainder_next :unsigned(32 downto 0);
        variable dividend_next :unsigned(31 downto 0);
        variable quotient_next :unsigned(31 downto 0);

    begin
        if rising_edge(clk) then
            if rst = '0' then
                counter          <= (others => '0');
                prev_data        <= (others => '0');
                first_fall_found <= '0';
                freq_reg <= (others => '0');
                ready_s  <= '0';
                div_busy      <= '0';
                dividend_reg  <= (others => '0');
                divisor_reg   <= (others => '0');
                quotient_reg  <= (others => '0');
                remainder_reg <= (others => '0');
                div_count     <= 0;
            else
                -- FREQ_READY solamente dura un ciclo.
                ready_s <= '0';
                -- Contador
                if counter /= x"FFFFFFFF" then --32bits si no llega incrementa
                    counter <= counter + to_unsigned(1, counter'length);
                end if;
                -- Division secuencial:
                -- frecuencia = 200 MHz/periodo
                if div_busy = '1' then
                    -- Desplazar el resto e introducir el siguiente bit del dividendo.
                    remainder_next := remainder_reg(31 downto 0) & dividend_reg(31);
                    dividend_next := dividend_reg(30 downto 0) & '0';
                    quotient_next := quotient_reg(30 downto 0) & '0';

                    if remainder_next >= resize(divisor_reg,remainder_next'length) then
                        remainder_next := remainder_next - resize(divisor_reg,remainder_next'length);

                        quotient_next(0) := '1';
                    end if;

                    remainder_reg <= remainder_next;
                    dividend_reg  <= dividend_next;
                    quotient_reg  <= quotient_next;

                    -- Después de 32 iteraciones,la division ha terminado
                    if div_count = 31 then
                        freq_reg <= quotient_next;
                        ready_s  <= '1';
                        div_busy  <= '0';
                        div_count <= 0;
                    else
                        div_count <= div_count + 1;
                    end if;

                end if;
                -- Procesar una muestra nueva del ADC
                if data_ready = '1' then
                    current_data := unsigned(data_in);
                    -- Detectar reinicio del diente de sierra
                    -- Muestra anterior: zona alta
                    -- Muestra actual: zona baja
                    if (prev_data > to_unsigned(3500, prev_data'length))and(current_data <to_unsigned(500, current_data'length)) then
                        period_cycles := counter + to_unsigned(1, counter'length);
                        -- Primera caida:solamente inicia la medición
                        if first_fall_found = '0' then
                            first_fall_found <= '1';
                            counter          <= (others => '0');
                        -- Periodo valido
                        elsif(period_cycles >= MIN_PERIOD_CYCLES)and(period_cycles <= MAX_PERIOD_CYCLES)then
                            counter <= (others => '0');
                            if div_busy = '0' then
                                dividend_reg <= CLK_FREQ_U;
                                divisor_reg  <= period_cycles;
                                quotient_reg  <= (others => '0');
                                remainder_reg <= (others => '0');
                                div_count <= 0;
                                div_busy  <= '1';
                            end if;
                        -- Periodo demasiado corto, Es una caida falsa
                        -- No se reinicia el contador
                        elsif period_cycles < MIN_PERIOD_CYCLES then
                            null;
                        -- Periodo demasiado largo. Se reinicia para recuperar sincronizaciom
                        else
                            counter <= (others => '0');
                        end if;
                    end if;
                    -- Guardar la muestra para la proxima comparacion
                    prev_data <= current_data;
                end if;
            end if;
        end if;
    end process;

    freq_out   <= STD_LOGIC_VECTOR(freq_reg);
    freq_ready <= ready_s;
        

end Behavioral;