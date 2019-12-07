library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_pkg.all;

entity decoder_ver2 is
    generic (reg_num : integer);
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        en : in std_logic;
        inst : in std_logic_vector(31 downto 0);
        next_pc : in std_logic_vector(31 downto 0);
        next_pc_out : out std_logic_vector(31 downto 0);
        inst_descript : in T_INST;
        A_data : out std_logic_vector(63 downto 0);
        B_data : out std_logic_vector(63 downto 0);
        A_addr : out std_logic_vector(4 downto 0);
        B_addr : out std_logic_vector(4 downto 0);
        immed : out std_logic_vector(31 downto 0);
        dest_addr : out std_logic_vector(4 downto 0);
        write_back_data : in std_logic_vector(63 downto 0);
        write_back_addr : in std_logic_vector(4 downto 0)
        --DF_addr_in : in addr_array(0 to reg_num-1);
        --DF_data_in : in data_array(0 to reg_num-1)
    );
        
end decoder_ver2;

architecture BHV of decoder_ver2 is
    
    signal src1_addr : std_logic_vector(4 downto 0);
    signal src1_data : std_logic_vector(63 downto 0);
    signal src2_addr : std_logic_vector(4 downto 0);
    signal src2_data : std_logic_vector(63 downto 0);
    signal immed_temp : std_logic_vector(31 downto 0);
    signal shamt : std_logic_vector(4 downto 0);
    signal offset : std_logic_vector(25 downto 0);

begin
    shamt <= inst(10 downto 6);
    offset <= inst(25 downto 0);
    src1_addr <= inst(25 downto 21);
    src2_addr <= inst(20 downto 16);
    
    process(clk, rst_n)
    begin
        if (rst_n = '0') then
            A_addr <= (others => '0');
            B_addr <= (others => '0');
        elsif (rising_edge(clk)) then
            A_addr <= inst(25 downto 21);
            B_addr <= inst(20 downto 16);
        end if;
    end process;
    
    immed_temp <= std_logic_vector(resize(signed(inst(15 downto 0)), 32));
    
    U_REG_FILE : entity work.reg_file
        port map (
            clk => clk,
            rst_n => rst_n,
            en => en,
            wr_addr => write_back_addr,
            wr_data => write_back_data,
            rd_addr_A => src1_addr,
            rd_data_A => src1_data,
            rd_addr_B => src2_addr,
            rd_data_B => src2_data
            );
    
    process(inst_descript,src1_data,src2_data,next_pc,immed_temp,shamt,inst)--,DF_addr_in,DF_data_in)

    begin    
        dest_addr <= (others => '0');
        A_data <= (others => '0');
        B_data <= (others => '0');
        next_pc_out <= std_logic_vector(resize(unsigned(next_pc),32));
        immed <= (others => '0');
        
        case inst_descript is    
            -- (I-type)
            when i_ADDI|i_ANDI|i_ORI|i_LB|i_LH|i_LW|i_LD|i_SB|i_SH|i_SW|i_SD =>
                dest_addr <= inst(20 downto 16);
                A_data <= src1_data;
                --for i in 0 to reg_num-1 loop
                    --if (src1_addr = DF_addr_in(i)) then
                        --A_data <= DF_data_in(i);
                    --end if;
                --end loop;
                immed <= immed_temp;
            
            when i_BNE|i_BEQ =>
                A_data <= src1_data;
                B_data <= src2_data;
                --for i in 0 to reg_num-1 loop
                    --if (src1_addr = DF_addr_in(i)) then
                        --A_data <= DF_data_in(i);
                    --end if;
                    --if (src2_addr = DF_addr_in(i)) then
                       -- B_data <= DF_data_in(i);
                    --end if;
                --end loop;
                immed <= immed_temp;
          
            -- (R-type)
            when i_ADD|i_SUB|i_AND|i_OR|i_SLT =>
                dest_addr <= inst(15 downto 11);
                A_data <= src1_data;
                B_data <= src2_data;
                --for i in 0 to reg_num-1 loop
                    --if (src1_addr = DF_addr_in(i)) then
                        --A_data <= DF_data_in(i);
                    --end if;
                    --if (src2_addr = DF_addr_in(i)) then
                        --B_data <= DF_data_in(i);
                    --end if;
                --end loop;
                
            when i_SLL|i_SRL =>
                dest_addr <= inst(15 downto 11);
                A_data <= src2_data;
                --for i in 0 to reg_num-1 loop
                    --if (src2_addr = DF_addr_in(i)) then
                        --A_data <= DF_data_in(i);  
                    --end if;
                --end loop;
                B_data <= std_logic_vector(resize(unsigned(shamt),64));
                
            -- (J-type)
            when i_J =>
                dest_addr <= (others => '0');
                A_data <= std_logic_vector(resize(unsigned(inst(25 downto 0)),64));
                next_pc_out <= std_logic_vector(resize(unsigned(next_pc),32));
                
            when others => null;
        end case;
    end process;
end BHV;