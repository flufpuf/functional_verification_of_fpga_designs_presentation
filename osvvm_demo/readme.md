# OSVVM Demo

## Setup

cd osvvm_demo/
git clone https://github.com/OSVVM/OsvvmLibraries.git
cd OsvvmLibraries
git submodule update --init --recursive
cd ..

## Run this demo

mkdir build
cd build
rlwrap tclsh
source ../OsvvmLibraries/Scripts/StartUp.tcl
build ../OsvvmLibraries
build ../sim/run_all_tests.pro

Wave for gtkwave is in reports/DefaultLib/tb_axi_stream_*.ghw

## Open wave with gtkwave

cd osvvm_demo/build
gtkwave reports/DefaultLib/tb_axi_stream_multi_burst.ghw -a ../sim/wave/tb_axi_stream_gtkw

## Clean

cd osvvm_demo
rm build
rm OsvvmLibraries