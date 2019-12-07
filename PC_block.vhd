library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_block is
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           sel : in STD_LOGIC;
           --PC_input : in STD_LOGIC_VECTOR (31 downto 0);
           PC_en : in std_logic;
           
           IR_input : in STD_LOGIC_VECTOR (31 downto 0);
           
           PC_output : out STD_LOGIC_VECTOR (31 downto 0);
           NPC_output : out STD_LOGIC_VECTOR (31 downto 0);
           IR_output_temp : out STD_LOGIC_VECTOR (31 downto 0);
           IR_output : out STD_LOGIC_VECTOR (31 downto 0);
           ALU_out : in STD_LOGIC_VECTOR (63 downto 0));
end PC_block;

architecture Behavioral of PC_block is

    signal PC_temp : STD_LOGIC_VECTOR (31 downto 0);
    signal NPC_IR_en : std_logic;
    signal NPC_output_temp : std_logic_vector(31 downto 0);
    signal IR_output_reg : std_logic_vector(31 downto 0);
    
begin
    IR_output_temp <= IR_output_reg;
    
    process(ALU_out,PC_temp,sel)
    begin
        if (sel = '0') then
            NPC_output_temp <= STD_LOGIC_VECTOR(unsigned(PC_temp)+4);
        else
            NPC_output_temp <= ALU_out(31 downto 0);
        end if;
    end process;
    
    PC_output <= PC_temp;
    
    process(NPC_IR_en, IR_input, PC_en)
    begin
        if (NPC_IR_en = '1') then
            IR_output_reg <= IR_input;
        else
            IR_output_reg <= (others => '0');
        end if;
    end process;
    
    process(clk, rst_n)
    begin
        if(rst_n = '0') then
            NPC_IR_en <= '0';
            PC_temp <= (others => '0');
            IR_output <= (others => '0');
            NPC_output <= (others => '0');
        elsif(rising_edge(clk))then
            NPC_IR_en <= PC_en;
            IR_output <= IR_output_reg;
            if (PC_en = '1') then
                PC_temp <= NPC_output_temp;
            end if;
            if (NPC_IR_en = '1') then 
                
                NPC_output <= NPC_output_temp;
            end if;
        end if;   
    end process;
end Behavioral;
