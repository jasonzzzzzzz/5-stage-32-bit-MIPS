library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_pkg.all;

entity D_memory is
    Port ( 
        clk : in STD_LOGIC;
        data_length : in T_DATA_LEN;
        addr_wr : in STD_LOGIC_VECTOR (31 downto 0);
        addr_rd : in STD_LOGIC_VECTOR (31 downto 0);
        r_en : in std_logic;
        w_en : in std_logic;
        wdata: in STD_LOGIC_VECTOR (63 downto 0);
        rdata : out STD_LOGIC_VECTOR (63 downto 0)
    );
end D_memory;

architecture Behavioral of D_memory is

   type memory_type is array (natural range <>) of std_logic_vector(7 downto 0);
   signal memory : memory_type(0 to 255) := (others => (others => '0'));

begin
    
    process(clk)
    begin
        if clk'event and clk = '1' then
            if w_en = '1' then
                case data_length is
                    when d_BYTE =>
                        memory(to_integer(unsigned(addr_wr))) <= wdata(7 downto 0);
                    when d_HALF_WORD =>
                        memory(to_integer(unsigned(addr_wr))) <= wdata(15 downto 8);
                        memory(to_integer(unsigned(addr_wr)+1)) <= wdata(7 downto 0);
                    when d_WORD =>
                        memory(to_integer(unsigned(addr_wr))) <= wdata(31 downto 24);
                        memory(to_integer(unsigned(addr_wr)+1)) <= wdata(23 downto 16);
                        memory(to_integer(unsigned(addr_wr)+2)) <= wdata(15 downto 8);
                        memory(to_integer(unsigned(addr_wr)+3)) <= wdata(7 downto 0);
                    when d_DOUBLE_WORD =>
                        memory(to_integer(unsigned(addr_wr))) <= wdata(63 downto 56);
                        memory(to_integer(unsigned(addr_wr)+1)) <= wdata(55 downto 48);
                        memory(to_integer(unsigned(addr_wr)+2)) <= wdata(47 downto 40);
                        memory(to_integer(unsigned(addr_wr)+3)) <= wdata(39 downto 32);
                        memory(to_integer(unsigned(addr_wr)+4)) <= wdata(31 downto 24);
                        memory(to_integer(unsigned(addr_wr)+5)) <= wdata(23 downto 16);
                        memory(to_integer(unsigned(addr_wr)+6)) <= wdata(15 downto 8);
                        memory(to_integer(unsigned(addr_wr)+7)) <= wdata(7 downto 0);
                end case;
            end if;
        end if;
    end process;
    
    process(data_length, addr_rd)
        variable rdata_temp_byte : std_logic_vector(7 downto 0);
        variable rdata_temp_h_word : std_logic_vector(15 downto 0);
        variable rdata_temp_word : std_logic_vector(31 downto 0);
        variable rdata_temp_d_word : std_logic_vector(63 downto 0);
    begin
        if (r_en = '1') then
            case data_length is
                when d_BYTE =>
                    rdata_temp_byte := memory(to_integer(unsigned(addr_rd)));
                    rdata <= std_logic_vector(resize(unsigned(rdata_temp_byte),64));
                when d_HALF_WORD =>
                    rdata_temp_h_word := memory(to_integer(unsigned(addr_rd))) & memory(to_integer(unsigned(addr_rd)+1));
                    rdata <= std_logic_vector(resize(unsigned(rdata_temp_h_word),64));
                when d_WORD =>
                    rdata_temp_word := memory(to_integer(unsigned(addr_rd))) & memory(to_integer(unsigned(addr_rd)+1)) 
                            & memory(to_integer(unsigned(addr_rd)+2)) & memory(to_integer(unsigned(addr_rd)+3));
                    rdata <= std_logic_vector(resize(unsigned(rdata_temp_word),64));
                when d_DOUBLE_WORD =>
                    rdata_temp_d_word := memory(to_integer(unsigned(addr_rd))) & memory(to_integer(unsigned(addr_rd)+1)) 
                            & memory(to_integer(unsigned(addr_rd)+2)) & memory(to_integer(unsigned(addr_rd)+3)) 
                            & memory(to_integer(unsigned(addr_rd)+4)) & memory(to_integer(unsigned(addr_rd)+5)) 
                            & memory(to_integer(unsigned(addr_rd)+6)) & memory(to_integer(unsigned(addr_rd)+7));
                    rdata <= std_logic_vector(resize(unsigned(rdata_temp_d_word),64));
            end case;
        else
            rdata <= (others => '0');
        end if;
    end process;
    
end Behavioral;
