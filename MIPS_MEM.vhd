library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_pkg.all;

entity MIPS_MEM is
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        MEM_inst_descript : T_INST;
        
        MEM_wr_addr : in std_logic_vector(31 downto 0);
        MEM_wr_data : in std_logic_vector(63 downto 0);
        
        MEM_rd_addr : in std_logic_vector(31 downto 0);
        ALU_in : in std_logic_vector(63 downto 0);
        ALU_out : out std_logic_vector(63 downto 0);
        reg_file_wr_en_out : out std_logic;
        MEM_out : out std_logic_vector(63 downto 0);
        write_back_addr_in : in std_logic_vector(4 downto 0);
        write_back_addr_out : out std_logic_vector(4 downto 0)   
        );
end MIPS_MEM;

architecture BHV of MIPS_MEM is
    signal MEM_en : std_logic;
    signal MEM_data_length : T_DATA_LEN;
    signal MEM_wr_en : std_logic;
    signal MEM_rd_en : std_logic;
    signal MEM_rd_data : std_logic_vector(63 downto 0);
   -- signal MEM_wr_addr : std_logic_vector(31 downto 0);
   -- signal MEM_rd_addr : std_logic_vector(31 downto 0);
    signal reg_file_en_temp : std_logic;
    
begin

    process(MEM_inst_descript)
    begin
        MEM_wr_en <= '0';
        MEM_rd_en <= '0';
        MEM_en <= '1';
        reg_file_en_temp <= '0';
        case MEM_inst_descript is
            when i_SB =>
                MEM_data_length <= d_BYTE;
                MEM_wr_en <= '1';
            when i_SH =>
                MEM_data_length <= d_HALF_WORD;
                MEM_wr_en <= '1';
            when i_SW =>
                MEM_data_length <= d_WORD;
                MEM_wr_en <= '1';
            when i_SD =>
                MEM_data_length <= d_DOUBLE_WORD;
                MEM_wr_en <= '1';
            when i_LB =>
                MEM_data_length <= d_BYTE;
                MEM_rd_en <= '1';
            when i_LH =>
                MEM_data_length <= d_HALF_WORD;
                MEM_rd_en <= '1';
            when i_LW =>
                MEM_data_length <= d_WORD;
                MEM_rd_en <= '1';
            when i_LD =>
                MEM_data_length <= d_DOUBLE_WORD;
                MEM_rd_en <= '1';
                
            -- bypassing logic
            -- when i_ADD|i_ADDI|i_SUB|i_AND|i_ANDI|i_OR|i_ORI|i_SLL|i_SRL =>
            -- WB_data <= ALU_out;  

            when others => 
                MEM_en <= '0';
                reg_file_en_temp <= '1';
            
        end case;
    end process;
    
    U_D_MEM : entity work.D_memory 
        port map (
            clk => clk,
            data_length => MEM_data_length,
            addr_wr => MEM_wr_addr,
            addr_rd => MEM_rd_addr,
            w_en => MEM_wr_en,
            r_en => MEM_rd_en,
            wdata => MEM_wr_data,
            rdata => MEM_rd_data
        );

    process(clk, rst_n)
    begin
        if (rst_n = '0') then
            MEM_out <= (others => '0');
            write_back_addr_out <= (others => '0');
            reg_file_wr_en_out <= '0';
            ALU_out <= (others => '0');
        elsif (rising_edge(clk)) then
           
            if (MEM_en = '1') then
                MEM_out <= MEM_rd_data;
            else
                ALU_out <= ALU_in;
                write_back_addr_out <= write_back_addr_in;
                reg_file_wr_en_out <= reg_file_en_temp;
            end if;
        end if;
    end process;
end BHV; 