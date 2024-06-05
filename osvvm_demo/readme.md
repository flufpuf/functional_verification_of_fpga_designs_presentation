# OSVVM Demo

Instructions below are for Linux and GHDL.

Instructions for Windows and other simulators can be found OSSVM's ["Script User Guide"](https://github.com/OSVVM/Documentation/blob/main/Script_user_guide.pdf)


More Guides:

* [Install GHDL](https://ghdl.github.io/ghdl/getting.html)
* [GTKWave](https://gtkwave.sourceforge.net/)

## Setup

```
cd osvvm_demo/
git clone https://github.com/OSVVM/OsvvmLibraries.git
cd OsvvmLibraries
git checkout 2024.05a
git submodule update --init --recursive
cd ..
```

## Run this demo

```
mkdir build
cd build
rlwrap tclsh
source ../OsvvmLibraries/Scripts/StartUp.tcl
build ../OsvvmLibraries
build ../sim/run_all_tests.pro
```

Wave for gtkwave is written to reports/DefaultLib/tb_axi_stream_*.ghw

## Open wave with gtkwave

```
cd osvvm_demo/build
gtkwave reports/DefaultLib/tb_axi_stream_multi_burst.ghw
```

## Clean

```
cd osvvm_demo
rm -rf build
rm -rf OsvvmLibraries
```