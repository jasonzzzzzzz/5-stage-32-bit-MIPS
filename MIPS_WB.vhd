library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_pkg.all;

entity MIPS_WB is
    Port (
        --WB_en : in std_logic;
        WB_inst_descript : in T_INST;
        ALU_out : in std_logic_vector(63 downto 0);
        MEM_out : in std_logic_vector(63 downto 0);
        WB_data : out std_logic_vector(63 downto 0)
       
    );
end MIPS_WB;

architecture Behavioral of MIPS_WB is
    signal WB_control : std_logic;
begin
    process(WB_inst_descript)
    begin
        case WB_inst_descript is
            when i_ADD|i_ADDI|i_SUB|i_AND|i_ANDI|i_OR|i_ORI|i_SLL|i_SRL =>
                WB_control <= '0';

            -- bypassing logic
            -- when i_BEQ|i_EQ =>
            -- WB_data <= MEM_out;  
            
            when others =>
                WB_control <= '1';

        end case;
    end process;
    
    process(WB_control, ALU_out, MEM_out)
    begin
        --if (WB_en = '1') then
            if (WB_control = '0') then
                WB_data <= ALU_out;
            else
                WB_data <= MEM_out;
            end if;        
        --end if;
    end process;
    --write_back_addr_out <= write_back_addr_in;
end Behavioral;
