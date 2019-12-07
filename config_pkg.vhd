library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package config_pkg is
    type T_INST is (
                   -- R Type
                   i_ADD, i_AND, i_SUB, i_OR, i_SLL, i_SRL, i_SLT, 
                   -- I Type
                   i_ADDI, i_ANDI, i_ORI, i_BEQ, i_BNE, 
                   i_LB, i_LH, i_LW, i_LD,
                   i_SB, i_SH, i_SW, i_SD,
                   -- J Type
                   i_J,   
                   i_NULL
                   );
    type T_DATA_LEN is (d_BYTE, d_HALF_WORD, d_WORD, d_DOUBLE_WORD);
    type T_HAZARD is (h_DATA, h_CONTROL, h_NO);
    type data_array is array (integer range<>) of std_logic_vector(63 downto 0);
    type addr_array is array (integer range<>) of std_logic_vector(4 downto 0);
end package;