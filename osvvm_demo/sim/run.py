from vunit import VUnit
from pathlib import Path

def write_toml(vu, filename):
  libs = vu.get_libraries()

  lines = ["[libraries]", ""]

  for lib in libs:
    lines.append(f"{lib.name}.files = [")
    file_set = lib.get_source_files()
    
    for file in file_set:
      path = Path(file.name)
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

osvvm_common = vu.add_library("osvvm_common")

osvvm_path = Path("../OsvvmLibraries/Common/src/")
for file in osvvm_path.glob("*.vhd"):
  if file.stem.endswith("_c") or file.stem.endswith("_Aldec") or file.stem.endswith("_xilinx"):
    continue
  
  osvvm_common.add_source_file(file)

osvvm = vu.add_library("osvvm")

osvvm_path = Path("../OsvvmLibraries/osvvm/")
for file in osvvm_path.glob("*.vhd"):
  if file.stem.endswith("_c") or file.stem.endswith("_Aldec") or file.stem.endswith("_xilinx"):
    continue
  
  osvvm.add_source_file(file)

osvvm_axi4 = vu.add_library("osvvm_axi4")

osvvm_path = Path("../OsvvmLibraries/AXI4/common/src/")
for file in osvvm_path.glob("*.vhd"):
  if file.stem.endswith("_c") or file.stem.endswith("_Aldec") or file.stem.endswith("_xilinx"):
    continue
  
  osvvm_axi4.add_source_file(file)

osvvm_path = Path("../OsvvmLibraries/AXI4/AxiStream/src/")
for file in osvvm_path.glob("*.vhd"):
  if file.stem.endswith("_c") or file.stem.endswith("_Aldec") or file.stem.endswith("_xilinx"):
    continue
  
  osvvm_axi4.add_source_file(file)

vu.add_verification_components()

# Create library 'lib'
lib = vu.add_library("lib")

# Add all files ending in .vhd in current working directory to library
lib.add_source_files("../hdl/*.vhd")
lib.add_source_files("./*.vhd")

write_toml(vu, "../../vhdl_ls.toml")

# Run vunit function
vu.main()