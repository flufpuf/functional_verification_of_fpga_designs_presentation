library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;
  
library OSVVM;
context OSVVM.OsvvmContext;
use osvvm.ScoreboardPkg_slv.all;

library osvvm_AXI4;
context osvvm_AXI4.AxiStreamContext;

entity test_ctrl is
port (
    -- Global Signal Interface
    reset_n : in std_logic ;

    -- Transaction Interfaces
    m_axis_rec : inout StreamRecType ;
    s_axis_rec : inout StreamRecType 

  );

  constant tdata_width : integer := m_axis_rec.DataToModel'length ; 
end entity test_ctrl ;
