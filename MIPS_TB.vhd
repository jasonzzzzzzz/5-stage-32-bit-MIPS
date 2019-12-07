library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_pkg.all;

entity MIPS_TB is
end MIPS_TB;

architecture TB of MIPS_TB is
    constant reg_num : integer := 3;
    signal clk : std_logic := '1';
    signal rst_n : std_logic;
    signal ctrl_Imem_wr_en : std_logic;
    signal ctrl_PC_en : std_logic;
    signal Imem_wr_addr : std_logic_vector(31 downto 0);
    signal Imem_wr_data : std_logic_vector(31 downto 0);
    signal ctrl_decoder_en : std_logic;
    signal ctrl_EX_en : std_logic;
    signal ctrl_MEM_wr_en : std_logic;
    signal ctrl_MEM_rd_en : std_logic;
    signal ctrl_WB_control : std_logic;
    signal ctrl_reg_wr_en : std_logic;
    
    signal go : std_logic;
    signal done : std_logic;
begin
    U_DUT : entity work.MIPS_new
        generic map(reg_num => reg_num)
        port map(
            clk => clk,
            rst_n => rst_n,
            go => go,
            done => done,
            ctrl_Imem_wr_en => ctrl_Imem_wr_en,
            Imem_wr_addr => Imem_wr_addr,
            Imem_wr_data => Imem_wr_data
        );
        
    clk <= not clk after 10 ns;
    
    process
    begin
        rst_n <= '0';
        ctrl_Imem_wr_en <= '1';
        go <= '0';
        Imem_wr_addr <= std_logic_vector(to_unsigned(4,32));
        Imem_wr_data <= X"20030008"; --addi $3, $0, 8
        wait for 20 ns;
        Imem_wr_addr <= std_logic_vector(to_unsigned(8,32));
        Imem_wr_data <= X"20040001"; --addi $4, $0, 1
        wait for 20 ns;
        Imem_wr_addr <= std_logic_vector(to_unsigned(12,32));
        Imem_wr_data <= X"2005ffff"; --addi $5, $0, -1
        wait for 20 ns;
        Imem_wr_addr <= std_logic_vector(to_unsigned(16,32));
        Imem_wr_data <= X"10600004"; --BEQ $3 $0 4
        wait for 20 ns;
        Imem_wr_addr <= std_logic_vector(to_unsigned(20,32));
        Imem_wr_data <= X"00852020"; --add $4, $4, $5
        wait for 20 ns;
        Imem_wr_addr <= std_logic_vector(to_unsigned(24,32));
        Imem_wr_data <= X"00852822"; --sub $5, $4, $5
        wait for 20 ns;
        Imem_wr_addr <= std_logic_vector(to_unsigned(28,32));
        Imem_wr_data <= X"2063ffff"; --addi $3, $3, -1
        wait for 20 ns;
        Imem_wr_addr <= std_logic_vector(to_unsigned(32,32));
        Imem_wr_data <= X"08000004"; --J loop
        wait for 20 ns;
        Imem_wr_addr <= std_logic_vector(to_unsigned(36,32));
        Imem_wr_data <= X"a00400ff"; --sb $4, 255($0)


        wait for 100 ns;
        ctrl_Imem_wr_en <= '0';
        rst_n <= '1';
        
        wait for 20 ns;
        go <= '1';

        
        wait;
    end process;
        
end TB;
