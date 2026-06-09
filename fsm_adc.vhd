----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.04.2026 20:25:59
-- Design Name: 
-- Module Name: fsm_adc - Behavioral
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

entity fsm_adc is
    Port ( clkDiv : in STD_LOGIC;
           nRST : in STD_LOGIC;
           START : in STD_LOGIC; --inicia conversion adc
           bit_cnt : in STD_LOGIC_VECTOR (4 downto 0); --
           DONE : out STD_LOGIC; -- indica que ya ha terminado de leer
           enShift : out STD_LOGIC;
           nCS : out STD_LOGIC); -- activacion adc en activo en bajo , 0 
end fsm_adc;

architecture Behavioral of fsm_adc is
    
    type state_type is (HOLD, F_PORCH, SHIFTING, B_PORCH);
    signal state, next_state : state_type;
    
    signal cnt : integer range 0 to 20 := 0; --contador auxiliar
    
    signal start_reg   : std_logic := '0';
    signal start_pulse : std_logic := '0';
    
begin

    -- REGISTRO DE ESTADO
    process(clkDiv, nRST)
    begin
        if nRST = '0' then
            state <= HOLD; -- estado inicial HOLD
            cnt <= 0;
        elsif rising_edge(clkDiv) then
            state <= next_state;
            -- contador para delays
            if state = F_PORCH or state = B_PORCH then -- se cuenta solo en esos estaods
                cnt <= cnt + 1;
            else
                cnt <= 0;
            end if;
        end if;
    end process;

    -- DETECTOR DE FLANCO DE START
    process(clkDiv, nRST)
    begin
        if nRST = '0' then
            start_reg   <= '0';
            start_pulse <= '0';
        elsif rising_edge(clkDiv) then
            if START = '1' and start_reg = '0' then
                start_pulse <= '1';
            else
                start_pulse <= '0';
            end if;
            start_reg <= START;
        end if;
    end process;
    
    -- LÓGICA DE TRANSICIÓN
    process(state, start_pulse, cnt, bit_cnt)
    begin
        next_state <= state; -- no cambias

        case state is
            -- ESPERA
            when HOLD =>
                if start_pulse = '1' then
                    next_state <= F_PORCH;
                end if;

            -- PREPARACIÓN ADC
            when F_PORCH =>
                if cnt >= 3 then
                    next_state <= SHIFTING;-- esperar ciclos antes de leer
                end if;

            -- LECTURA DE BITS
            when SHIFTING =>
                if unsigned(bit_cnt) = 15 then -- cuando lleva 16 bits, cambio a 15
                    next_state <= B_PORCH;
                end if;

            -- FINAL
            when B_PORCH =>
                if cnt >= 3 then
                    next_state <= HOLD;
                end if;

        end case;
    end process;

    -- SALIDAS
    process(state)
    begin
        -- valores por defecto
        DONE    <= '0';
        enShift <= '0'; -- no se desplaza
        nCS     <= '1'; --ADC desactivado

        case state is

            when HOLD =>
                nCS <= '1';

            when F_PORCH =>
                nCS <= '0'; -- activas adc, prepara conversion

            when SHIFTING =>
                nCS <= '0';
                enShift <= '1'; -- lees bits

            when B_PORCH =>
                nCS <= '1'; -- apaga adc
                DONE <= '1';

        end case;
    end process;

end Behavioral;
