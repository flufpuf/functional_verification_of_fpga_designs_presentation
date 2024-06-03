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

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.vc_context;

entity tb_axi_stream is
  generic (
    runner_cfg : string;
    output_path : string;
    tb_path : string;
    master_stall_prob : integer range 0 to 100;
    slave_stall_prob : integer range 0 to 100
  );
end entity;

architecture sim of tb_axi_stream is

  constant clk_period : time := 10 ns;

  signal clock : std_logic := '0';
  signal reset : std_logic := '0';

  signal m_axis_tdata : std_logic_vector(7 downto 0);
  signal m_axis_tvalid : std_logic;
  signal m_axis_tready : std_logic;

  constant axis_master_handle : axi_stream_master_t := new_axi_stream_master(
    data_length => m_axis_tdata'length,
    stall_config => new_stall_config(
      stall_probability => (real(master_stall_prob) / 100.0),
      min_stall_cycles => 1,
      max_stall_cycles => 10),
    protocol_checker => new_axi_stream_protocol_checker(
      data_length => m_axis_tdata'length));

  signal s_axis_tdata : std_logic_vector(7 downto 0);
  signal s_axis_tvalid : std_logic;
  signal s_axis_tready : std_logic;

  constant axis_slave_handle : axi_stream_slave_t := new_axi_stream_slave(
    data_length => s_axis_tdata'length,
    stall_config => new_stall_config(
      stall_probability => (real(slave_stall_prob) / 100.0),
      min_stall_cycles => 1,
      max_stall_cycles => 10),
    protocol_checker => new_axi_stream_protocol_checker(
      data_length => s_axis_tdata'length));

  constant debug_logger : logger_t := get_logger("tb_axi_stream:debug_logger");
  constant debug_log_handler : log_handler_t := new_log_handler(output_path & "debug.log", csv, false);

begin

  clk_gen : process
  begin
    wait for clk_period;
    clock <= not clock;
  end process;

  axis_master : entity vunit_lib.axi_stream_master
  generic map (
    master => axis_master_handle
  )
  port map (
    aclk => clock,
    areset_n => (not reset),
    tvalid => m_axis_tvalid,
    tready => m_axis_tready,
    tdata => m_axis_tdata
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

  axis_slave : entity vunit_lib.axi_stream_slave
  generic map (
    slave => axis_slave_handle
  )
  port map (
    aclk => clock,
    areset_n => (not reset),
    tvalid => s_axis_tvalid,
    tready => s_axis_tready,
    tdata => s_axis_tdata
  );

  main : process
    variable tdata : std_logic_vector(m_axis_tdata'range);
    type t_tdata_array is array (natural range <>) of std_logic_vector(m_axis_tdata'range);
    type t_tdata_array_ptr is access t_tdata_array;
    variable tdata_testset : t_tdata_array_ptr;
    variable num_bursts : natural;
    variable burst_length : natural;
  begin
    test_runner_setup(runner, runner_cfg);
    show(display_handler, debug);
    -- hide(display_handler, info);

    set_log_handlers(debug_logger, (display_handler, debug_log_handler));
    show(debug_log_handler, debug);

    while test_suite loop

      if run("single-burst") then

        info("Start single-burst test");

        for beat_idx in 0 to 99 loop
          tdata := std_logic_vector(to_unsigned(beat_idx, tdata'length));

          -- debug("Send 0x" & to_hstring(tdata) & " to DUT");
          debug(debug_logger, "Send 0x" & to_hstring(tdata) & " to DUT");

          -- Non-blocking push
          push_axi_stream(net, axis_master_handle, tdata);
          -- Non-blocking check
          check_axi_stream(net, axis_slave_handle, tdata, blocking => false);
        end loop;
      
      elsif run("multi-burst") then

        info("Start multi-burst test");

        num_bursts := 10;
        info("Send " & to_string(num_bursts) & " bursts to DUT.");

        for burst_idx in 0 to num_bursts-1 loop
          burst_length := 100;
          info("Send burst " & to_string(burst_idx) & " with " & to_string(burst_length) & " beats.");

          for beat_idx in 0 to burst_length-1 loop
            tdata := std_logic_vector(to_unsigned(beat_idx * burst_idx, tdata'length));

            -- Non-blocking push
            push_axi_stream(net, axis_master_handle, tdata);
            -- Non-blocking check
            check_axi_stream(net, axis_slave_handle, tdata, blocking => false);
          end loop;

          wait_until_idle(net, as_sync(axis_master_handle));
          wait_until_idle(net, as_sync(axis_slave_handle));
          wait for clk_period * 100;
        end loop;

      elsif run("corner-case") then

        tdata_testset := new t_tdata_array'(
          x"00",
          x"01",
          x"02",
          x"FD",
          x"FE",
          x"FF"
        );

        for beat_idx in tdata_testset'range loop
          tdata := tdata_testset(beat_idx);

          -- Non-blocking push
          push_axi_stream(net, axis_master_handle, tdata);
          -- Non-blocking check
          check_axi_stream(net, axis_slave_handle, tdata, blocking => false);
        end loop;

      elsif run("test_fail") then
        check(false, "Report an error");

      end if;
    end loop;

    wait_until_idle(net, as_sync(axis_master_handle));
    wait_until_idle(net, as_sync(axis_slave_handle));

    wait for clk_period * 10;

    test_runner_cleanup(runner);
  end process;

  test_runner_watchdog(runner, 10 ms);
end architecture;