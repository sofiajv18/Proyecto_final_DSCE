----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.10.2025 12:08:39
-- Design Name: 
-- Module Name: clock_divider - Behavioral
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

entity clock_divider is
    Generic (
        DIV_VALUE : integer := 25 -- quedaría 1Mhz por asegurar que funcione DAC
    );
    Port (
        clk50  : in  std_logic;     -- reloj principal
        rst_in  : in  std_logic;     
        clkDiv : out std_logic      -- Reloj de salida dividada
    );
end clock_divider;

architecture Behavioral of clock_divider is
    -- Usamos DIV_VALUE para definir el rango del contador
    signal prescaler_cnt  : integer range 0 to DIV_VALUE - 1 := 0;
    signal clk_out_signal : std_logic := '0';


begin

Prescaler_Proc : process (clk50, rst_in)
    begin
        if rst_in = '0' then -- reset activo bajo
            prescaler_cnt <= 0;
            clk_out_signal <= '0';
        elsif rising_edge(clk50) then
            if prescaler_cnt = DIV_VALUE - 1 then -- 24 (cuenta 25 ciclos)
                prescaler_cnt <= 0;
                clk_out_signal <= not clk_out_signal; --cambia el reloj de 0 a 1 y de 1 a 0
            else
                prescaler_cnt <= prescaler_cnt + 1;
            end if;
        end if;
    end process Prescaler_Proc;

    -- señal interna al puerto de salida
    clkDiv <= clk_out_signal;


end Behavioral;
