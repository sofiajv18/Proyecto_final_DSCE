----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.10.2025 12:36:35
-- Design Name: 
-- Module Name: fsm - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm is
    Port ( START       : in  STD_LOGIC; -- INICIO
           nRST        : in  STD_LOGIC; -- RESET
           clkDiv      : in  STD_LOGIC; -- RELOJ DAC 1MHZ
           SiftCounter : in  STD_LOGIC_VECTOR (3 downto 0); -- BITS enviados 0-15
           DATA_READY : in STD_LOGIC;   -- cuando RAM ya tiene datos
           --salidas
           DONE        : out STD_LOGIC; -- TERMINAR
           LoadData    : out STD_LOGIC; -- cargar datos en shift register
           enSift      : out STD_LOGIC; -- habilita desplazaiento
           nSYNC       : out STD_LOGIC); -- activa el DAC
end fsm;

architecture Behavioral of fsm is
    type state_type is (IDLE, WaitLoad, LOAD, WaitLoad2, SiftOUT, SyncData);
    signal current_state, next_state : state_type := IDLE;
    
begin

-- Proceso secuencial
State_Update_Proc : process (clkDiv, nRST)
begin
    if nRST = '0' then     -- reset activo BAJO, en un reset vuelve a IDLE
        current_state <= IDLE;
    elsif rising_edge(clkDiv) then
        current_state <= next_state; -- en cada ciclo cambia de estado
    end if;
end process;

-- Proceso combinacional
Next_State_Logic_Proc : process (current_state, START, SiftCounter, DATA_READY)
begin
    next_state <= current_state;
    LoadData   <= '0';
    enSift     <= '0';
    DONE       <= '0';
    nSYNC      <= '1';

    case current_state is
        -- IDLE: esperando START. No cargar datos aun
        when IDLE =>
            DONE <= '0';
            if START = '1' then
                next_state <= WaitLoad;
            end if;
        -- WaitLoad: 1 ciclo de espera para que RAM estabilice
        
        when WaitLoad =>
            if DATA_READY = '1' then
                next_state <= LOAD;
            end if;
        when LOAD =>
            LoadData <= '1';
            next_state <= WaitLoad2;
        when WaitLoad2 =>
            LoadData <= '0';
            next_state <= SiftOUT;
        -- SiftOUT: cargar datos y desplazar 16 ciclos
        when SiftOUT =>
            enSift   <= '1'; --desplazar
            nSYNC    <= '0'; --DAC ACTIVO
            
            -- 16 bits
            if SiftCounter = "1111" then --cuando llega a 15 envia 16 bits
                next_state <= SyncData;
            end if;
        -- SyncData: fin de transmisión
        when SyncData =>
            DONE <= '1'; --FIN
            nSYNC <= '1'; --desactiva DAC
            next_state <= IDLE;
       

    end case;
end process;

end Behavioral;
