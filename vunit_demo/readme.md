# VUnit Demo

Instructions below are for Linux and GHDL.

Guides:

* [Install GHDL](https://ghdl.github.io/ghdl/getting.html)
* [Install VUnit](https://vunit.github.io/installing.html)
* [Switch Simulator in VUnit](https://vunit.github.io/cli.html#simulator-selection)
* [GTKWave](https://gtkwave.sourceforge.net/)

## Run this demo

```
cd vunit_demo/sim
```

List all tests:

```
python run.py --list
```

Run all tests:

```
python run.py
```

Run selected test with GUI (GTKWave):

```
python run.py lib.tb_axi_stream.high-stall.single-burst -g
```