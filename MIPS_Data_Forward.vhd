library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.config_pkg.all;

entity MIPS_Data_Forward is
    generic (reg_num : integer);
    Port (
        clk : in std_logic;
        rst_n : in std_logic;
        addr_in : in std_logic_vector(4 downto 0);
        data_in : in std_logic_vector(63 downto 0);
        addr_out : out addr_array(0 to reg_num-1);
        data_out : out data_array(0 to reg_num-1)
    );
end MIPS_Data_Forward;

architecture Behavioral of MIPS_Data_Forward is
    signal data_regs : data_array(0 to reg_num-1);
    signal addr_regs : addr_array(0 to reg_num-1);
begin
    U_SLIDE_BUFF : for i in 0 to reg_num-2 generate
        process(clk, rst_n)
        begin
            if (rst_n = '0') then
                data_regs(i) <= (others => '0');
                addr_regs(i) <= (others => '0');
            elsif (rising_edge(clk)) then
                addr_regs(i) <= addr_regs(i+1);
                data_regs(i) <= data_regs(i+1);   
            end if;
        end process;
    end generate;
    
    process(clk, rst_n)
    begin
        if (rst_n = '0') then
            data_regs(reg_num-1) <= (others => '0');
            addr_regs(reg_num-1) <= (others => '0');
        elsif (rising_edge(clk)) then
            addr_regs(reg_num-1) <= addr_in;
            if (unsigned(addr_in) = 0) then
                data_regs(reg_num-1) <= (others => '0');
            else
                data_regs(reg_num-1) <= data_in;   
            end if;
        end if;
    end process;
    
    process(data_regs,addr_regs)
    begin
        for i in 0 to reg_num-1 loop
            data_out(i) <= data_regs(i);
            addr_out(i) <= addr_regs(i);
        end loop;
    end process;
end Behavioral;
