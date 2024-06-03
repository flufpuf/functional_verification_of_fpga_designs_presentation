library ieee;
context ieee.ieee_std_context;
use ieee.math_real.all;

entity axi_stream_dut is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    s_axis_tdata : in std_logic_vector(7 downto 0);
    s_axis_tvalid : in std_logic;
    s_axis_tready : out std_logic;

    m_axis_tdata : out std_logic_vector(7 downto 0);
    m_axis_tvalid : out std_logic;
    m_axis_tready : in std_logic        
  );
end entity;

architecture rtl of axi_stream_dut is

begin

  m_axis_tdata <= s_axis_tdata;
  m_axis_tvalid <= s_axis_tvalid;
  s_axis_tready <= m_axis_tready;

end architecture;