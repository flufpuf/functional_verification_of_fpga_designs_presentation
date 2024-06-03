architecture single_burst of test_ctrl is
  signal test_done : integer_barrier := 1 ;

  function init_testset return slv_vector is
    variable ret : slv_vector(0 to 99)(tdata_width-1 downto 0);
  begin
    for idx in ret'range loop
      ret(idx) := std_logic_vector(to_unsigned(idx, tdata_width));
    end loop;

    return ret;
  end function;

  constant testset : slv_vector := init_testset;

begin

  watchdog : process
  begin
    wait for 1 ms;
    log("Watchdog timeout");
    std.env.stop;
  end process;

  ctrl_proc : process
  begin
    -- Initialization of test
    SetTestName("single_burst") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns; wait for 0 ns;
    TranscriptOpen ;
    SetTranscriptMirror(TRUE);

    -- Wait for Design Reset
    if reset_n /= '1' then wait until reset_n = '1'; end if;
    ClearAlerts;

    WaitForBarrier(test_done);
    
    TranscriptClose;
    EndOfTestReports; 
    std.env.stop;
    wait;
  end process ctrl_proc;
  
  tx_proc : process
  begin
    WaitForClock(m_axis_rec, 2);
    SetBurstMode(m_axis_rec, STREAM_BURST_WORD_MODE);
    SetUseRandomDelays(m_axis_rec);

    if reset_n /= '1' then wait until reset_n = '1'; end if;

    sendBurstVector(m_axis_rec, testset);

    WaitForClock(m_axis_rec, 10);
    WaitForBarrier(test_done);
    wait ;
  end process tx_proc;

  rx_proc : process
  begin
    waitForClock(s_axis_rec, 2);
    SetBurstMode(s_axis_rec, STREAM_BURST_WORD_MODE);
    SetUseRandomDelays(s_axis_rec);

    if reset_n /= '1' then wait until reset_n = '1'; end if;

    for beat_idx in testset'range loop
      check(s_axis_rec, testset(beat_idx));
    end loop;

    WaitForClock(s_axis_rec, 10);
    WaitForBarrier(test_done);
  end process rx_proc;
end single_burst ;
  
Configuration tb_axi_stream_single_burst of tb_axi_stream is
  for test_harness
    for inst_test_ctrl : test_ctrl
      use entity work.test_ctrl(single_burst);
    end for;
  end for;
end tb_axi_stream_single_burst;