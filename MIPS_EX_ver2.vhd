library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_pkg.ALL;

entity MIPS_EX_ver2 is
    generic (reg_num : integer);
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        EX_en : in std_logic;
        op0 : in std_logic_vector(63 downto 0);
        op1 : in std_logic_vector(63 downto 0);
        immed : in std_logic_vector(31 downto 0);
        NPC : in std_logic_vector(31 downto 0);
        ALU_ctrl : in T_INST;
        branch_taken : out std_logic;
        ALU_out : out std_logic_vector(63 downto 0);
        write_back_addr_in : in std_logic_vector(4 downto 0);
        write_back_addr_out : out std_logic_vector(4 downto 0);
        MEM_save_data_out : out std_logic_vector(63 downto 0);
        A_addr : in std_logic_vector(4 downto 0);
        B_addr : in std_logic_vector(4 downto 0)
        --DF_addr_out : out addr_array(0 to reg_num-1);
        --DF_data_out : out data_array(0 to reg_num-1)   
    );
end MIPS_EX_ver2;

architecture Behavioral of MIPS_EX_ver2 is
    signal branch_temp : std_logic;
    signal ALU_out_temp : std_logic_vector(63 downto 0);
    signal DF_addr_out : addr_array(0 to reg_num-1);
    signal DF_data_out : data_array(0 to reg_num-1);
    signal ALU_in1 : std_logic_vector(63 downto 0);
    signal ALU_in2 : std_logic_vector(63 downto 0);
begin
    U_DATA_FORWARDING : entity work.MIPS_Data_Forward
        generic map (reg_num => reg_num)
        port map (
            clk => clk,
            rst_n => rst_n,
            addr_in => write_back_addr_in,
            data_in => ALU_out_temp,
            addr_out => DF_addr_out,
            data_out => DF_data_out
        );
    U_ALU : entity work.ALU
        port map (
            op0 => ALU_in1,
            op1 => ALU_in2,
            immed => immed,
            NPC => NPC,
            ctrl_signal => ALU_ctrl,
            result => ALU_out_temp,
            zero_branch => branch_temp
        );
        
    -- Data forwarding
    process(ALU_ctrl,A_addr, B_addr, DF_addr_out, DF_data_out)
    begin
        ALU_in1 <= op0;
        ALU_in2 <= op1;
        
        case ALU_ctrl is
            when i_J => null;
            when others =>
                
                for i in 0 to reg_num-1 loop
                    if (A_addr = DF_addr_out(i)) then
                        ALU_in1 <= DF_data_out(i);
                    end if;
                    if (B_addr = DF_addr_out(i)) then
                        ALU_in2 <= DF_data_out(i); 
                    end if;
                end loop;
        end case;
    end process;
    
    -- Stage Registers
    process(clk, rst_n)
    begin
        if (rst_n = '0') then
            ALU_out <= (others => '0');
            branch_taken <= '0';
            write_back_addr_out <= (others => '0');
            MEM_save_data_out <= (others => '0');
        elsif (rising_edge(clk)) then
            if (EX_en = '1') then
                ALU_out <= ALU_out_temp;
                branch_taken <= branch_temp;
                write_back_addr_out <= write_back_addr_in;
                MEM_save_data_out <= op1;
            end if;
        end if;
    end process;
end Behavioral;
