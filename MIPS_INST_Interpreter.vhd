library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_pkg.all;

entity MIPS_INST_interpreter is
    Port (
        clk : in std_logic;
        rst_n : in std_logic;
        IF_inst : in std_logic_vector(31 downto 0);
        ID_en : in std_logic;
        ID_inst_descript : out T_INST;    
        EX_en : in std_logic;
        EX_inst_descript : out T_INST;    
        MEM_inst_descript : out T_INST;    
        WB_inst_descript : out T_INST       
    );
end MIPS_INST_interpreter;

architecture BHV of MIPS_INST_interpreter is
    signal ID_inst_descript_temp : T_INST;
    signal EX_inst_descript_temp : T_INST;
    signal MEM_inst_descript_temp : T_INST;
    signal WB_inst_descript_temp : T_INST;
    
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
        ----- when i_SH i_SW i_SD
        when "000100" =>
            ID_inst_descript_temp <= i_BEQ;
        when "000101" =>
            ID_inst_descript_temp <= i_BNE;
        when "000010" =>
            ID_inst_descript_temp <= i_J;
        when others => null;
        end case;
    end process;
    
    process(clk, rst_n)
    begin
        if (rst_n = '0') then
            EX_inst_descript_temp <= i_NULL;
            MEM_inst_descript_temp <= i_NULL;
            WB_inst_descript_temp <= i_NULL;     
        elsif (rising_edge(clk)) then
            if (ID_en = '1') then
                EX_inst_descript_temp <= ID_inst_descript_temp;
            end if;
            if (EX_en = '1') then
                MEM_inst_descript_temp <= EX_inst_descript_temp;
            end if;
            WB_inst_descript_temp <= MEM_inst_descript_temp;
        end if;
    end process;
    
    ID_inst_descript <= ID_inst_descript_temp;
    EX_inst_descript <= EX_inst_descript_temp;
    MEM_inst_descript <= MEM_inst_descript_temp;
    WB_inst_descript <= WB_inst_descript_temp;
    
end BHV;   