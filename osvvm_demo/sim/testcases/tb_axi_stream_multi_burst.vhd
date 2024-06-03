architecture multi_burst of test_ctrl is
  signal test_done : integer_barrier := 1;

  shared variable prng : RandomPType;
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
    SetTestName("multi_burst") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns; wait for 0 ns;
    TranscriptOpen ;
    SetTranscriptMirror(TRUE);
    prng.initSeed(42);

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
    variable tdata : std_logic_vector(tdata_width-1 downto 0);
  begin
    WaitForClock(m_axis_rec, 2);
    SetBurstMode(m_axis_rec, STREAM_BURST_WORD_MODE);
    SetUseRandomDelays(m_axis_rec);

    if reset_n /= '1' then wait until reset_n = '1'; end if;

    for burst_idx in 0 to 9 loop
      for beat_idx in 0 to 99 loop
        tdata := std_logic_vector(to_unsigned(burst_idx * beat_idx, tdata_width));
        send(m_axis_rec, tdata);
      end loop;

      waitForClock(m_axis_rec, 100);
    end loop;

    WaitForClock(m_axis_rec, 10);
    WaitForBarrier(test_done);
    wait ;
  end process tx_proc;

  rx_proc : process
    variable tdata : std_logic_vector(tdata_width-1 downto 0);
  begin
    waitForClock(s_axis_rec, 2);
    SetBurstMode(s_axis_rec, STREAM_BURST_WORD_MODE);
    SetUseRandomDelays(s_axis_rec);

    if reset_n /= '1' then wait until reset_n = '1'; end if;

    for burst_idx in 0 to 9 loop
      for beat_idx in 0 to 99 loop
        tdata := std_logic_vector(to_unsigned(burst_idx * beat_idx, tdata_width));
        check(s_axis_rec, tdata);
      end loop;
    end loop;

    WaitForClock(s_axis_rec, 10);
    WaitForBarrier(test_done);
  end process rx_proc;
end multi_burst ;
  
Configuration tb_axi_stream_multi_burst of tb_axi_stream is
  for test_harness
    for inst_test_ctrl : test_ctrl
      use entity work.test_ctrl(multi_burst);
    end for;
  end for;
end tb_axi_stream_multi_burst;