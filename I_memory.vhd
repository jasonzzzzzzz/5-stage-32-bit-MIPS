library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I_memory is
    Port ( 
        clk : in STD_LOGIC;
        addr_wr : in STD_LOGIC_VECTOR (31 downto 0);
        addr_rd1 : in STD_LOGIC_VECTOR (31 downto 0);
        addr_rd2 : in STD_LOGIC_VECTOR (31 downto 0);
        w_en : in std_logic;
        r_en : in std_logic;
        wdata: in STD_LOGIC_VECTOR (31 downto 0);
        rdata1 : out STD_LOGIC_VECTOR (31 downto 0);
        rdata2 : out STD_LOGIC_VECTOR (31 downto 0)
    );
end I_memory;

architecture Behavioral of I_memory is

   type memory_type is array (natural range <>) of std_logic_vector(7 downto 0);
   signal memory : memory_type(0 to 255) := (others => (others => '0'));
 
begin

    process(clk)
    begin
        if clk'event and clk = '1' then
            if w_en = '1' then
                memory(to_integer(unsigned(addr_wr))) <= wdata(31 downto 24);
                memory(to_integer(unsigned(addr_wr)+1)) <= wdata(23 downto 16);
                memory(to_integer(unsigned(addr_wr)+2)) <= wdata(15 downto 8);
                memory(to_integer(unsigned(addr_wr)+3)) <= wdata(7 downto 0);
            end if;
        end if;
    end process;
    
    process(r_en,addr_rd1,addr_rd2,memory)
    begin
        if (r_en = '1') then
            rdata1 <= memory(to_integer(unsigned(addr_rd1))) & memory(to_integer(unsigned(addr_rd1)+1)) & 
                 memory(to_integer(unsigned(addr_rd1)+2)) & memory(to_integer(unsigned(addr_rd1)+3));
                 
            rdata2 <= memory(to_integer(unsigned(addr_rd2))) & memory(to_integer(unsigned(addr_rd2)+1)) & 
                 memory(to_integer(unsigned(addr_rd2)+2)) & memory(to_integer(unsigned(addr_rd2)+3));
        else
            rdata1 <= (others => '0');
            rdata2 <= (others => '0');
        end if;
    end process;
end Behavioral;
