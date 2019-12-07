library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        en : in std_logic;
        wr_addr : in std_logic_vector(4 downto 0);
        wr_data : in std_logic_vector(63 downto 0);
        rd_addr_A : in std_logic_vector(4 downto 0);
        rd_data_A : out std_logic_vector(63 downto 0);
        rd_addr_B : in std_logic_vector(4 downto 0);
        rd_data_B : out std_logic_vector(63 downto 0)
    );
end reg_file;

architecture BHV of reg_file is

    type reg_file_type is array (31 downto 0) of std_logic_vector(63 downto 0);
    signal regs : reg_file_type; -- := (others => (others => '0'));

begin
    process(clk, rst_n)
    begin
        if (rst_n = '0') then
            regs <= (others => (others => '0'));
        elsif (rising_edge(clk)) then
            if (en = '1') then
                regs(to_integer(unsigned(wr_addr))) <= wr_data;
            end if;
        end if;
    end process;
    
    process(rd_addr_A, rd_addr_B,regs)
    begin    
        if (signed(rd_addr_A) = 0) then
            rd_data_A <= (others => '0');
        else
            rd_data_A <= regs(to_integer(unsigned(rd_addr_A)));
        end if;
        
        if (signed(rd_addr_B) = 0) then
            rd_data_B <= (others => '0');
        else
            rd_data_B <= regs(to_integer(unsigned(rd_addr_B)));
        end if;
    end process;
end BHV;