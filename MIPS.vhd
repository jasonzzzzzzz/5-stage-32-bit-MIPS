library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_pkg.all;

entity MIPS is
    generic (reg_num : integer);
    Port ( 
        clk : in std_logic;
        rst_n : in std_logic;
        
        go : in std_logic;
        done : out std_logic;
        
        Imem_wr_addr : in std_logic_vector(31 downto 0);
        Imem_wr_data : in std_logic_vector(31 downto 0);
        
        ctrl_Imem_wr_en : in std_logic
    );
end MIPS;

architecture STR of MIPS is
    signal NPC_output : std_logic_vector(31 downto 0);
    signal IR_output : std_logic_vector(31 downto 0);
    signal ALU_out : std_logic_vector(63 downto 0);
    
    signal inst_descript : T_INST;
    signal ID_inst_descript : T_INST;
    signal EX_inst_descript : T_INST;
    signal MEM_inst_descript : T_INST;
    signal WB_inst_descript : T_INST;
    
    signal ID_reg_file_en : std_logic;
    signal EX_reg_file_en : std_logic;
    signal MEM_reg_file_en : std_logic;
    signal WB_reg_file_en : std_logic;
    
    signal A_data : std_logic_vector(63 downto 0);
    signal B_data : std_logic_vector(63 downto 0);
    signal immed : std_logic_vector(31 downto 0);
    signal dest_addr : std_logic_vector(4 downto 0);
    signal write_back_data : std_logic_vector(63 downto 0);
    signal write_back_addr : std_logic_vector(4 downto 0);
    signal ID_NPC_out : std_logic_vector(31 downto 0);
    
    signal EX_write_back_addr_out : std_logic_vector(4 downto 0);
    signal MEM_write_back_addr_out : std_logic_vector(4 downto 0);
    signal MEM_save_data_out : std_logic_vector(63 downto 0);
    signal branch_taken : std_logic;
    
    signal MEM_ALU_out : std_logic_vector(63 downto 0);
    signal MEM_out : std_logic_vector(63 downto 0);
    
    signal IF_inst : std_logic_vector(31 downto 0);
    signal IF_next_inst : std_logic_vector(31 downto 0);
    --signal ctrl_Imem_wr_en : std_logic;
    signal ctrl_PC_en : std_logic;
    signal ctrl_decoder_en : std_logic;
    signal ctrl_EX_en : std_logic;
    
    signal DF_addr_out : addr_array(0 to reg_num-1);
    signal DF_data_out : data_array(0 to reg_num-1);
    
    signal A_addr : std_logic_vector(4 downto 0);
    signal B_addr : std_logic_vector(4 downto 0);
begin
    U_CTRL : entity work.MIPS_CTRL
        port map(
            clk => clk,
            rst_n => rst_n,
            go => go,
            done => done,
            IF_inst => IF_inst,
            IF_next_inst => IF_next_inst,
            --ctrl_Imem_wr_en => ctrl_Imem_wr_en,
            ctrl_PC_en => ctrl_PC_en,
            ctrl_decoder_en => ctrl_decoder_en,
            ctrl_EX_en => ctrl_EX_en
        );
        
    U_II : entity work.MIPS_INST_interpreter
        port map(
            clk => clk,
            rst_n => rst_n,
            IF_inst => IR_output,
            ID_en => ctrl_decoder_en,
            ID_inst_descript => ID_inst_descript,
            EX_en => ctrl_EX_en,
            EX_inst_descript => EX_inst_descript,
            MEM_inst_descript => MEM_inst_descript,
            WB_inst_descript => WB_inst_descript
        );
        
    U_IF : entity work.MIPS_IF
        port map(
            clk => clk,
            rst_n => rst_n,
            sel => branch_taken,
            w_en => ctrl_Imem_wr_en,
            addr_wr => Imem_wr_addr,
            wdata => Imem_wr_data,
            PC_en => ctrl_PC_en,
            NPC_output => NPC_output,
            IR_output => IR_output,
            ALU_out => ALU_out,
            inst_for_ctrl => IF_inst,
            next_inst_for_ctrl => IF_next_inst
        );
    
    U_ID : entity work.MIPS_ID_ver2
        generic map(reg_num => reg_num)
        port map(
            clk => clk,
            rst_n => rst_n,
            decoder_en => ctrl_decoder_en,
            reg_file_en => MEM_reg_file_en,
            inst => IR_output,
            next_pc => NPC_output,
            next_pc_out => ID_NPC_out,
            inst_descript => ID_inst_descript,
            DF_addr_in => DF_addr_out,
            DF_data_in => DF_data_out,
            A_data => A_data,
            B_data => B_data,
            A_addr => A_addr,
            B_addr => B_addr,
            immed => immed,
            dest_addr => dest_addr,
            write_back_data => write_back_data,
            write_back_addr => MEM_write_back_addr_out
        );
        
    U_EX : entity work.MIPS_EX_ver2
        generic map(reg_num => reg_num)
        port map(
            clk => clk,
            rst_n => rst_n,
            write_back_addr_in => dest_addr,
            write_back_addr_out => EX_write_back_addr_out,
            MEM_save_data_out => MEM_save_data_out,
            EX_en => ctrl_EX_en,
            op0 => A_data,
            op1 => B_data,
            A_addr => A_addr,
            B_addr => B_addr,
            immed => immed,
            NPC => ID_NPC_out,
            ALU_ctrl => EX_inst_descript,
            branch_taken => branch_taken,
            ALU_out => ALU_out
        );
    
    U_MEM : entity work.MIPS_MEM
        port map(
            clk => clk,
            rst_n => rst_n,
            MEM_inst_descript => MEM_inst_descript,
            write_back_addr_in => EX_write_back_addr_out,
            write_back_addr_out => MEM_write_back_addr_out,
            reg_file_wr_en_out => MEM_reg_file_en,
            MEM_wr_addr => ALU_out(31 downto 0),
            MEM_wr_data => MEM_save_data_out,
            MEM_rd_addr => ALU_out(31 downto 0),
            MEM_out => MEM_out,
            ALU_in => ALU_out,
            ALU_out => MEM_ALU_out
        );
    
    U_WB : entity work.MIPS_WB
        port map(
            WB_inst_descript => WB_inst_descript,
            ALU_out => MEM_ALU_out,
            MEM_out => MEM_out,
            WB_data => write_back_data
        );
        

end STR;
