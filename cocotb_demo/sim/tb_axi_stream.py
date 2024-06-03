import cocotb
from cocotb.triggers import FallingEdge, Timer
from cocotb.clock import Clock
from cocotb.regression import TestFactory
import itertools
import numpy as np

from cocotbext.axi import (AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamMonitor)

clk_period = 1

def stall_generator(p):
  while True:
    yield np.random.binomial(1, p)

async def setup_testbench(dut, source_stall_prob=0.2, sink_stall_prob=0.2):
  axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.reset)
  axis_source.set_pause_generator(stall_generator(source_stall_prob))
  
  axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.reset)
  axis_sink.set_pause_generator(stall_generator(sink_stall_prob))

  cocotb.start_soon(Clock(dut.clk, clk_period, units="ns").start())
  dut.reset.value = 0
  
  return axis_source, axis_sink

async def single_burst(dut, source_stall_prob, sink_stall_prob):

  axis_source, axis_sink = await setup_testbench(dut, source_stall_prob, sink_stall_prob)
  
  await Timer(5, units="ns")
  
  for beat_idx in range(100):
    await axis_source.send(bytes([beat_idx]))
    
  for beat_idx in range(100):
    rxframe = await axis_sink.recv()
    assert int.from_bytes(rxframe.tdata) == beat_idx, f"Error at beat index {beat_idx}"
    
  await axis_source.wait()

  await Timer(clk_period * 5, units="ns")
  
tf = TestFactory(test_function=single_burst)
tf.add_option(('source_stall_prob', 'sink_stall_prob'), [(0.2, 0.2), (0.8, 0.8), (0.0, 0.0), (0.0, 0.8)])
tf.generate_tests()
  
async def multi_burst(dut, source_stall_prob, sink_stall_prob):
  axis_source, axis_sink = await setup_testbench(dut, source_stall_prob, sink_stall_prob)
  
  await Timer(5, units="ns")
  
  for burst_idx in range(10):
    for beat_idx in range(100):
      await axis_source.send(bytes([beat_idx]))
      
    for beat_idx in range(100):
      rxframe = await axis_sink.recv()
      assert int.from_bytes(rxframe.tdata) == beat_idx, f"Error at beat index {beat_idx}"
      
    await axis_source.wait()

    await Timer(clk_period * 100, units="ns")
    
tf = TestFactory(test_function=multi_burst)
tf.add_option(('source_stall_prob', 'sink_stall_prob'), [(0.2, 0.2), (0.8, 0.8), (0.0, 0.0), (0.0, 0.8)])
tf.generate_tests()
    
async def corner_case(dut, source_stall_prob, sink_stall_prob):
  axis_source, axis_sink = await setup_testbench(dut, source_stall_prob, sink_stall_prob)
  
  await Timer(5, units="ns")
  
  tdata_testset = [0x00, 0x01, 0x02, 0xFD, 0xFE, 0xFF]
  
  for tdata in tdata_testset:
    await axis_source.send(bytes([tdata]))
    
  for beat_idx, tdata in enumerate(tdata_testset):
    rxframe = await axis_sink.recv()
    assert int.from_bytes(rxframe.tdata) == tdata, f"Error at beat index {beat_idx}"
    
  await axis_source.wait()

  await Timer(clk_period * 5, units="ns")
  
tf = TestFactory(test_function=corner_case)
tf.add_option(('source_stall_prob', 'sink_stall_prob'), [(0.2, 0.2), (0.8, 0.8), (0.0, 0.0), (0.0, 0.8)])
tf.generate_tests()