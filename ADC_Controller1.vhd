----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.04.2026 20:53:26
-- Design Name: 
-- Module Name: ADC_Controller1 - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ADC_Controller1 is
    Port ( clk50 : in STD_LOGIC;
           nRST : in STD_LOGIC;
           START : in STD_LOGIC;
           DIN : in STD_LOGIC;
           nCS : out STD_LOGIC;
           DONE : out STD_LOGIC;
           DATA_IN : out STD_LOGIC_VECTOR (11 downto 0);
           CLK_OUT : out STD_LOGIC);
end ADC_Controller1;

architecture Behavioral of ADC_Controller1 is

    -- reloj dividido
    signal clkDiv : std_logic;

    -- señales internas
    signal enShift  : std_logic;
    signal bit_cnt  : std_logic_vector(4 downto 0);

    signal done_internal : std_logic;
    
    component clock_divider is
        Generic (
            DIV_VALUE : integer := 10
        );
        Port (
            clk50  : in  std_logic;
            rst_in : in  std_logic;
            clkDiv : out std_logic
        );
    end component;

    component fsm_adc is
        Port (
            clkDiv   : in  STD_LOGIC;
            nRST     : in  STD_LOGIC;
            START    : in  STD_LOGIC;
            bit_cnt  : in  STD_LOGIC_VECTOR (4 downto 0);
            DONE     : out STD_LOGIC;
            enShift  : out STD_LOGIC;
            nCS      : out STD_LOGIC
        );
    end component;

    component shift_register_adc is
        Port (
            clkDiv   : in  STD_LOGIC;
            nRST     : in  STD_LOGIC;
            DIN     : in  STD_LOGIC;
            enShift  : in  STD_LOGIC;
            DONE : in STD_LOGIC;
            DATA_IN : out STD_LOGIC_VECTOR(11 downto 0);
            bit_cnt  : out STD_LOGIC_VECTOR(4 downto 0)
        );
    end component;

begin
    
    U1_CLK : clock_divider
        generic map (DIV_VALUE => 10)
        port map (
            clk50  => clk50,
            rst_in => nRST,
            clkDiv => clkDiv
        );

    U2_FSM : fsm_adc
        port map (
            clkDiv   => clkDiv,
            nRST     => nRST,
            START    => START, --'1'
            bit_cnt  => bit_cnt,
            DONE     => done_internal,
            enShift  => enShift,
            nCS      => nCS
        );

    U3_SHIFT : shift_register_adc
        port map (
            clkDiv   => clkDiv,
            nRST     => nRST,
            DIN     => DIN,
            enShift  => enShift,
            DONE     => done_internal,
            DATA_IN => DATA_IN,
            bit_cnt  => bit_cnt
        );

    --nCS <= '0';
    DONE    <= done_internal;
    CLK_OUT <= clkDiv;

end Behavioral;
