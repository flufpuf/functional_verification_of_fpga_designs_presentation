from vunit import VUnit
from pathlib import Path


def write_toml(vu, filename):
  libs = vu.get_libraries()

  lines = ["[libraries]", ""]

  for lib in libs:
    lines.append(f"{lib.name}.files = [")
    file_set = lib.get_source_files()
    
    for file in file_set:
      path = Path(file._source_file.original_name)
      lines.append(f"  '{path.resolve()}',")
      
    lines.extend(["]", ""])
    
  lines = [ln + "\n" for ln in lines]
  
  with open(filename, 'w') as f_toml:
    f_toml.writelines(lines)

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()

# Optionally add VUnit's builtin HDL utilities for checking, logging, communication...
# See http://vunit.github.io/hdl_libraries.html.
vu.add_vhdl_builtins()
vu.add_verification_components()
vu.enable_location_preprocessing()
# or
# vu.add_verilog_builtins()

# Create library 'lib'
lib = vu.add_library("lib")

# Add all files ending in .vhd in current working directory to library
lib.add_source_files("../hdl/*.vhd")
lib.add_source_files("./tb_axi_stream.vhd")

# write_toml(vu, "../../vhdl_ls.toml")

tb = lib.test_bench("tb_axi_stream")

for test in tb.get_tests():
  test.add_config(
    name="low-stall",
    generics={
      "master_stall_prob": 20,
      "slave_stall_prob": 20
    })
  
  test.add_config(
    name="high-stall",
    generics={
      "master_stall_prob": 80,
      "slave_stall_prob": 80
    })
  
  test.add_config(
    name="no-stall",
    generics={
      "master_stall_prob": 0,
      "slave_stall_prob": 0
    })
  
  test.add_config(
    name="high-backpressure",
    generics={
      "master_stall_prob": 0,
      "slave_stall_prob": 80
    })


# Run vunit function
vu.main()