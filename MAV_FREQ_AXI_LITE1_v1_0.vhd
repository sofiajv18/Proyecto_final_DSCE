library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MAV_FREQ_AXI_LITE1_v1_0 is
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
        data_in : in std_logic_vector(11 downto 0);
        data_ready : in std_logic;
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
end MAV_FREQ_AXI_LITE1_v1_0;

architecture arch_imp of MAV_FREQ_AXI_LITE1_v1_0 is

    signal mav_out_s  : std_logic_vector(11 downto 0);
    signal freq_out_s : std_logic_vector(31 downto 0);
    signal mav_ready_s  : std_logic;
    signal freq_ready_s : std_logic;
    
    signal data_ready_reg   : std_logic := '0';
    signal data_ready_pulse : std_logic := '0';
	-- component declaration
	component MAV_FREQ_AXI_LITE1_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		
		mav_in  : in std_logic_vector(11 downto 0);
        freq_in : in std_logic_vector(31 downto 0);
        mav_ready  : in std_logic;
        freq_ready : in std_logic;
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
	end component MAV_FREQ_AXI_LITE1_v1_0_S00_AXI;

    component MAV_FREQ_TOP is
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               data_in : in STD_LOGIC_VECTOR (11 downto 0);
               mav_out : out STD_LOGIC_VECTOR (11 downto 0);
               freq_out : out STD_LOGIC_VECTOR (31 downto 0);
               mav_ready : out STD_LOGIC;
               freq_ready : out STD_LOGIC;
               data_ready : in STD_LOGIC);
    end component;
begin

-- Instantiation of Axi Bus Interface S00_AXI
MAV_FREQ_AXI_LITE1_v1_0_S00_AXI_inst : MAV_FREQ_AXI_LITE1_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	
	    mav_in  => mav_out_s,
        freq_in => freq_out_s,
        mav_ready  => mav_ready_s,   
        freq_ready => freq_ready_s,
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
	
	DUT: MAV_FREQ_TOP
        port map (
            clk      => s00_axi_aclk,
            rst      => s00_axi_aresetn,
            data_in  => data_in,
            mav_out  => mav_out_s,
            freq_out => freq_out_s,
            mav_ready  => mav_ready_s,
            freq_ready => freq_ready_s,
            data_ready => data_ready_pulse
        );

	-- Add user logic here
    process(s00_axi_aclk)
    begin
        if rising_edge(s00_axi_aclk) then
            data_ready_pulse <= data_ready and not data_ready_reg;
            data_ready_reg <= data_ready;
        end if;
    end process;
	-- User logic ends

end arch_imp;
