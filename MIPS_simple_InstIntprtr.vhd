library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_pkg.all;

entity MIPS_simple_InstIntprtr is
    Port ( IF_inst : in STD_LOGIC_VECTOR(31 downto 0);
           ID_inst_descript_temp : out T_INST);
end MIPS_simple_InstIntprtr;

architecture Behavioral of MIPS_simple_InstIntprtr is

begin
    process(IF_inst)
    begin
        ID_inst_descript_temp <= i_NULL;                 
        case IF_inst(31 downto 26) is
        when "000000" =>
            case IF_inst(5 downto 0) is
                when "100000" =>
                    ID_inst_descript_temp <= i_ADD;
                when "100010" =>
                    ID_inst_descript_temp <= i_SUB;
                when "100100" =>
                    ID_inst_descript_temp <= i_AND;
                when "100101" =>
                    ID_inst_descript_temp <= i_OR;  
                when "101010" =>
                    ID_inst_descript_temp <= i_SLT;
                when "000001" =>
                    ID_inst_descript_temp <= i_SLL;
                when "000010" =>
                    ID_inst_descript_temp <= i_SRL;  
                when others => null;
            end case; 
            
        when "001000" => 
            ID_inst_descript_temp <= i_ADDI;
        when "001100" =>
            ID_inst_descript_temp <= i_ANDI;
        when "001101" =>
            ID_inst_descript_temp <= i_ORI;
        when "100000" =>
            ID_inst_descript_temp <= i_LB;
        when "100001" =>
            ID_inst_descript_temp <= i_LH;
        when "100010" =>
            ID_inst_descript_temp <= i_LW;
        when "100011" =>
            ID_inst_descript_temp <= i_LD;
    
        when "101000" =>
            ID_inst_descript_temp <= i_SB;
        when "101001" =>
            ID_inst_descript_temp <= i_SH;
        when "101010" =>
            ID_inst_descript_temp <= i_SW;
        when "101011" =>
            ID_inst_descript_temp <= i_SD;    
            
        when "000100" =>
            ID_inst_descript_temp <= i_BEQ;
        when "000101" =>
            ID_inst_descript_temp <= i_BNE;
        when "000010" =>
            ID_inst_descript_temp <= i_J;
        when others => null;
        end case;
    end process;

end Behavioral;
