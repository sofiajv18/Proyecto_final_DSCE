----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.04.2026 02:43:46
-- Design Name: 
-- Module Name: MAV_FREQ_TOP - Behavioral
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

entity MAV_FREQ_TOP is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (11 downto 0);
           mav_out : out STD_LOGIC_VECTOR (11 downto 0);
           freq_out : out STD_LOGIC_VECTOR (31 downto 0);
           data_ready : in STD_LOGIC;
           mav_ready : out STD_LOGIC;
           freq_ready : out STD_LOGIC);
end MAV_FREQ_TOP;

architecture Behavioral of MAV_FREQ_TOP is
    signal mav_signal  : std_logic_vector(11 downto 0);
    signal freq_signal : std_logic_vector(31 downto 0);
    signal mav_ready_s  : std_logic;
    signal freq_ready_s : std_logic;
    
    signal ready_meta   : std_logic := '0';
    signal ready_sync   : std_logic := '0';
    signal ready_prev   : std_logic := '0';
    
    signal sample_pulse : std_logic := '0';
    
    component MAV1 is
        Generic (
            N : integer := 16--4096-- -- número de muestras
        );
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               data_in : in STD_LOGIC_VECTOR (11 downto 0);
               mav_out : out STD_LOGIC_VECTOR (11 downto 0);
               mav_ready : out STD_LOGIC;
               data_ready : in std_logic);
    end component;
    
    component FREQ1 is
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               data_in : in STD_LOGIC_VECTOR (11 downto 0);
               freq_out : out STD_LOGIC_VECTOR (31 downto 0);
               freq_ready : out STD_LOGIC;
               data_ready : in std_logic);
    end component;
begin
    MAV_inst : MAV1
        generic map (
            N => 16--4096--16
        )
        port map (
            clk     => clk,
            rst     => rst,
            data_in => data_in,
            mav_out => mav_signal,
            mav_ready => mav_ready_s,
            data_ready => sample_pulse
        );

    FREQ_inst : FREQ1
        port map (
            clk      => clk,
            rst      => rst,
            data_in  => data_in,
            freq_out => freq_signal,
            freq_ready => freq_ready_s,
            data_ready => sample_pulse
        );
    
    process(clk)
    begin
        if rising_edge(clk) then
    
            if rst = '0' then
    
                ready_meta <= '0';
                ready_sync <= '0';
                ready_prev <= '0';
    
            else
    
                ready_meta <= data_ready;
                ready_sync <= ready_meta;
                ready_prev <= ready_sync;
    
            end if;
    
        end if;
    end process;
    
    sample_pulse <= ready_sync and not ready_prev;
    
    mav_out  <= mav_signal;
    freq_out <= freq_signal;
    mav_ready  <= mav_ready_s;
    freq_ready <= freq_ready_s;

end Behavioral;