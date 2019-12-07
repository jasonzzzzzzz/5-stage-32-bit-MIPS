library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS_IF is
    Port (
        clk : in STD_LOGIC; 
        rst_n : in STD_LOGIC;
        sel : in std_logic;
        w_en : in std_logic;
        addr_wr : in STD_LOGIC_VECTOR (31 downto 0);
        wdata : in STD_LOGIC_VECTOR (31 downto 0);
        PC_en : in std_logic;
        NPC_output : out STD_LOGIC_VECTOR (31 downto 0);
        IR_output : out STD_LOGIC_VECTOR (31 downto 0);
        ALU_out :in STD_LOGIC_VECTOR (63 downto 0);
        inst_for_ctrl : out std_logic_vector(31 downto 0);
        next_inst_for_ctrl : out std_logic_vector(31 downto 0)
      );
end MIPS_IF;

architecture STR of MIPS_IF is
    signal addr_rd1 : STD_LOGIC_VECTOR (31 downto 0);
    signal rdata1 : STD_LOGIC_VECTOR (31 downto 0);
    signal addr_rd2 : STD_LOGIC_VECTOR (31 downto 0);
    signal rdata2 : STD_LOGIC_VECTOR (31 downto 0);
    signal NPC_output_temp : STD_LOGIC_VECTOR (31 downto 0);
    signal IR_output_temp : std_logic_vector(31 downto 0);
begin

    U_PC_block : entity work.PC_block
        port map(
            clk => clk,
            rst_n => rst_n,
            sel => sel,
            ALU_out => ALU_out,
            PC_en => PC_en,
            PC_output => addr_rd1,
            NPC_output => NPC_output_temp,
            IR_output_temp => IR_output_temp,
            IR_output => IR_output,
            IR_input => rdata1
        );
    NPC_output <= NPC_output_temp;
    
    U_memory : entity work.I_memory 
        port map(
            clk => clk,
            addr_wr =>addr_wr,
            w_en => w_en,
            --r_en => PC_en,
            r_en => '1',
            wdata => wdata,
            rdata1 => rdata1,
            rdata2 => rdata2,
            addr_rd1 => addr_rd1,
            addr_rd2 => addr_rd2
        );
    addr_rd2 <= std_logic_vector(unsigned(addr_rd1) + 4);
    inst_for_ctrl <= IR_output_temp; 
    next_inst_for_ctrl <= rdata2;
end STR;
