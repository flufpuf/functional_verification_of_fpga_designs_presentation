# Cocotb Demo

Instructions below are for Linux and GHDL.

Guides:

* [Install GHDL](https://ghdl.github.io/ghdl/getting.html)
* [Install Cocotb](https://docs.cocotb.org/en/stable/install.html#installation)
* [Cocotb Quickstart Guide (also switching simulators)](https://docs.cocotb.org/en/stable/quickstart.html)
* [GTKWave](https://gtkwave.sourceforge.net/)

## Run this demo

```
cd cocotb_demo/sim
```

Run all tests:

```
make
```

Run single test:

```
make TESTCASE=single_burst_001
```

Open wave in GTKWave:

```
gtkwave tb_axi_stream.vcd
```