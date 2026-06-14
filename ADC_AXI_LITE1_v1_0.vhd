library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADC_AXI_LITE1_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
        DIN     : in std_logic;   -- dato serie del ADC
        nCS     : out std_logic;
        CLK_OUT : out std_logic;
        data_adc_out : out std_logic_vector(11 downto 0);
        data_ready_out : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end ADC_AXI_LITE1_v1_0;

architecture arch_imp of ADC_AXI_LITE1_v1_0 is

    signal data_in_s : std_logic_vector(11 downto 0);
    signal start_s   : std_logic;
    signal done_s       : std_logic;
    
    type start_state_type is (GENERATE_START, WAIT_DONE_HIGH, WAIT_DONE_LOW);

    signal start_state : start_state_type := GENERATE_START;
    
    constant START_PULSE_CYCLES : integer := 100;
    
    signal start_counter :
        integer range 0 to START_PULSE_CYCLES - 1 := 0;
    
    signal done_meta : std_logic := '0';
    signal done_sync : std_logic := '0';

	-- component declaration
	component ADC_AXI_LITE1_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		
		data_adc : in std_logic_vector(11 downto 0);
        done_adc : in std_logic;
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component ADC_AXI_LITE1_v1_0_S00_AXI;
    
    component ADC_Controller1 is
        Port (
            clk50     : in  STD_LOGIC;
            nRST      : in  STD_LOGIC;
            START     : in  STD_LOGIC;
            DIN      : in  STD_LOGIC;
            nCS       : out STD_LOGIC;
            DONE      : out STD_LOGIC;
            DATA_IN  : out STD_LOGIC_VECTOR(11 downto 0);
            CLK_OUT   : out STD_LOGIC
        );
    end component;
begin

-- Instantiation of Axi Bus Interface S00_AXI
ADC_AXI_LITE1_v1_0_S00_AXI_inst : ADC_AXI_LITE1_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	
        data_adc => data_in_s,
        done_adc => done_s,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

     ADC_inst : ADC_Controller1
        port map (
            clk50    => s00_axi_aclk ,
            nRST     => s00_axi_aresetn,
            START    => start_s,
            DIN     => DIN,
            nCS      => nCS,
            DONE     => done_s,
            DATA_IN => data_in_s,
            CLK_OUT  => CLK_OUT
        );
	-- Add user logic here
	--start_s <= s00_axi_aresetn;--'1'
	
--	process(s00_axi_aclk)
--    variable cnt : integer := 0;
--    begin
--        if rising_edge(s00_axi_aclk) then
--            if s00_axi_aresetn = '0' then
--                start_s <= '0';
--                cnt := 0;
--            else
--                if cnt = 10 then
--                    start_s <= '1';
--                elsif cnt = 11 then
--                    start_s <= '0';
--                end if;
                
--                -- reinicio limpio
--            if cnt = 1000 then
--                cnt := 0;
--            else
--                cnt := cnt + 1;
--            end if;
--        end if;
--        end if;
--    end process;
--    start_s <= '1';

    process(s00_axi_aclk)
    begin
        if rising_edge(s00_axi_aclk) then
            if s00_axi_aresetn = '0' then
                start_s       <= '0';
                start_counter <= 0;
                start_state   <= GENERATE_START;
    
                done_meta <= '0';
                done_sync <= '0';
            else
                -- Sincronizacion de DONE con el reloj AXI    
                done_meta <= done_s;
                done_sync <= done_meta;
                -- Generacion continua de conversiones
                case start_state is
                    -- Genera un START suficientemente ancho
                    when GENERATE_START =>
                        start_s <= '1';
                        if start_counter = START_PULSE_CYCLES - 1 then
                            start_s       <= '0';
                            start_counter <= 0;
                            start_state   <= WAIT_DONE_HIGH;
                        else
                            start_counter <= start_counter + 1;
                        end if;
                    -- Espera a que la conversion termine
                    when WAIT_DONE_HIGH =>
                        start_s <= '0';
                        if done_sync = '1' then
                            start_state <= WAIT_DONE_LOW;
                        end if;
                    -- Espera a que DONE vuelva a cero
                    when WAIT_DONE_LOW =>
                        start_s <= '0';
                        if done_sync = '0' then
                            start_state <= GENERATE_START;
                        end if;
                end case;
            end if;
        end if;
    end process;
--    start_s <= not done_s;
    data_adc_out <= data_in_s;
    data_ready_out <= done_s;
	-- User logic ends

end arch_imp;
