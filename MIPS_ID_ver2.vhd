library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_pkg.all;

entity MIPS_ID_ver2 is
    generic (reg_num : integer);
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        reg_file_en : in std_logic;
        decoder_en : in std_logic;
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
        write_back_addr : in std_logic_vector(4 downto 0);
        DF_addr_in : in addr_array(0 to reg_num-1);
        DF_data_in : in data_array(0 to reg_num-1)
    );
end MIPS_ID_ver2;

architecture STR of MIPS_ID_ver2 is
    
    signal A_data_reg : std_logic_vector(63 downto 0);
    signal B_data_reg : std_logic_vector(63 downto 0);
    signal dest_addr_reg : std_logic_vector(4 downto 0);
    signal next_pc_out_temp : std_logic_vector(31 downto 0);
    signal immed_temp : std_logic_vector(31 downto 0);
    --signal inst_descript_temp : T_INST;
    
begin
    U_DECODER : entity work.decoder_ver2
        generic map (reg_num => reg_num)
        port map (
            clk => clk,
            rst_n => rst_n,
            en => reg_file_en,
            inst => inst,
            next_pc => next_pc,
            next_pc_out => next_pc_out_temp,
            inst_descript => inst_descript,
            A_data => A_data_reg,
            B_data => B_data_reg,
            A_addr => A_addr,
            B_addr => B_addr,
            immed => immed_temp,
            dest_addr => dest_addr_reg,
            write_back_data => write_back_data,
            write_back_addr => write_back_addr
            --DF_addr_in => DF_addr_in,
            --DF_data_in => DF_data_in
            );

    process(clk,rst_n)
    begin
        if (rst_n = '0') then
            A_data <= (others=>'0');
            B_data <= (others=>'0');
            immed <= (others=>'0');
            dest_addr <= (others=>'0');
            next_pc_out <= (others=>'0');
               
        elsif (rising_edge(clk)) then
            if (decoder_en = '1') then
                A_data <= A_data_reg;
                B_data <= B_data_reg;
                immed <= immed_temp;
                dest_addr <= dest_addr_reg;
                next_pc_out <= next_pc_out_temp;
               
            end if;
        end if;
    end process;
    
end STR;