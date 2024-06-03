-- Topics covered:
-- - Verification components
-- - stalling
-- - Protocol checkers
-- - TB Timeout
-- - Test cases
-- - Test case configurations
-- - basic logging
-- - enable_location_preprocessing
-- - basic checking
-- - log handler (write log to file)
--
-- Possible addons:
-- - Randomization
-- - (Random salt)
-- - (Coverage)

library ieee;
context ieee.ieee_std_context;
use ieee.math_real.all;

library osvvm;
context osvvm.osvvmContext;

library osvvm_axi4;
context osvvm_axi4.axistreamcontext;

entity tb_axi_stream is
end entity;

architecture test_harness of tb_axi_stream is

  constant clk_period : time := 10 ns;

  signal clock : std_logic := '0';
  signal reset : std_logic := '0';

  constant tdata_width : natural := 8;
  constant tdata_width_bytes : natural := tdata_width / 8;
  constant tid_max_width : natural := 4;
  constant tdest_max_width : natural := 4;
  constant tuser_max_width : natural := 4;

  signal m_axis_tdata, s_axis_tdata : std_logic_vector(tdata_width-1 downto 0);
  signal m_axis_tvalid, s_axis_tvalid : std_logic;
  signal m_axis_tready, s_axis_tready : std_logic;
  signal m_axis_tid, s_axis_tid : std_logic_vector(tid_max_width-1 downto 0) := (others => '0');
  signal m_axis_tdest, s_axis_tdest : std_logic_vector(tdest_max_width-1 downto 0) := (others => '0');
  signal m_axis_tuser, s_axis_tuser : std_logic_vector(tuser_max_width-1 downto 0) := (others => '0');
  signal m_axis_tstrb, s_axis_tstrb : std_logic_vector(tdata_width_bytes-1 downto 0) := (others => '1');
  signal m_axis_tkeep, s_axis_tkeep : std_logic_vector(tdata_width_bytes-1 downto 0) := (others => '1');
  signal m_axis_tlast, s_axis_tlast : std_logic := '0';

  constant AXI_PARAM_WIDTH : integer := TID_MAX_WIDTH + TDEST_MAX_WIDTH + TUSER_MAX_WIDTH + 1 ;

  signal m_axis_rec, s_axis_rec : StreamRecType(
    DataToModel   (tdata_width-1 downto 0),
    DataFromModel (tdata_width-1 downto 0),
    ParamToModel  (axi_param_width-1 downto 0),
    ParamFromModel(axi_param_width-1 downto 0));

  component test_ctrl is
  port (
    reset_n : in std_logic;
    m_axis_rec : inout StreamRecType;
    s_axis_rec : inout StreamRecType);
  end component;

begin

  clk_gen : process
  begin
    wait for clk_period;
    clock <= not clock;
  end process;

  inst_test_ctrl : test_ctrl
  port map (
    reset_n => (not reset),
    m_axis_rec => m_axis_rec,
    s_axis_rec => s_axis_rec);

  axis_master : entity osvvm_axi4.AxiStreamTransmitter
  generic map (
    MODEL_ID_NAME => "AXI Stream Master",
    tperiod_Clk   => clk_period
  )
  port map (
    -- Globals
    Clk       => clock,
    nReset    => (not reset),
    -- AXI Transmitter Functional Interface
    TValid    => m_axis_tvalid,
    TReady    => m_axis_tready,
    TData     => m_axis_tdata,
    TID       => m_axis_tid,
    TDest     => m_axis_tdest,
    TUser     => m_axis_tuser,
    TStrb     => m_axis_tstrb,
    TKeep     => m_axis_tkeep,
    TLast     => m_axis_tlast,
    -- Testbench Transaction Interface
    TransRec  => m_axis_rec
  );

  dut : entity work.axi_stream_dut
  port map (
    clk => clock,
    reset => reset,
    
    s_axis_tdata => m_axis_tdata,
    s_axis_tvalid => m_axis_tvalid,
    s_axis_tready => m_axis_tready,

    m_axis_tdata => s_axis_tdata,
    m_axis_tvalid => s_axis_tvalid,
    m_axis_tready => s_axis_tready
  );

  axis_slave : entity osvvm_axi4.AxiStreamReceiver
  generic map (
    MODEL_ID_NAME  => "axi stream slave",
    tperiod_Clk    => clk_period)
  port map (
    -- Globals
    Clk       => clock,
    nReset    => (not reset),
    -- AXI Receiver Functional Interface
    TValid    => s_axis_tvalid,
    TReady    => s_axis_tready,
    TID       => s_axis_tid,
    TDest     => s_axis_tdest,
    TUser     => s_axis_tuser,
    TData     => s_axis_tdata,
    TStrb     => s_axis_tstrb,
    TKeep     => s_axis_tkeep,
    TLast     => s_axis_tlast,
    -- Testbench Transaction Interface
    TransRec  => s_axis_rec);
end architecture;