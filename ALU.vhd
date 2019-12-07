library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_pkg.ALL;

entity ALU is
    port(
        op0 : in std_logic_vector(63 downto 0);
        op1 : in std_logic_vector(63 downto 0);
        immed : in std_logic_vector(31 downto 0);
        NPC : in std_logic_vector(31 downto 0);
        ctrl_signal : in T_INST;
        result : out std_logic_vector(63 downto 0);
        zero_branch : out std_logic
    );
end ALU;

architecture BHV of ALU is

begin
    process(op0,op1,immed,NPC,ctrl_signal)
        variable result_temp : unsigned(31 downto 0);
        variable offset : std_logic_vector(31 downto 0);
    begin
        zero_branch <= '0';
        result <= (others => '0');
        case ctrl_signal is
            when i_ADD =>
                result <= std_logic_vector(resize((signed(op0) + signed(op1)),64));
            when i_ADDI =>
                result <= std_logic_vector(signed(op0) + resize(signed(immed),64));
            when i_SUB =>
                result <= std_logic_vector(resize((signed(op0) - signed(op1)),64));
            when i_AND =>
                result <= op0 and op1;
            when i_ANDI =>
                result <= op1 and std_logic_vector(resize(signed(immed),64));
            when i_OR =>
                result <= op0 or op1;
            when i_ORI =>
                result <= op1 or std_logic_vector(resize(signed(immed),64));
            when i_SLL =>
                result <= std_logic_vector(unsigned(op0) sll to_integer(unsigned(op1)));
            when i_SRL =>
                result <= std_logic_vector(unsigned(op0) srl to_integer(unsigned(op1)));
            when i_BEQ =>
                offset := std_logic_vector(unsigned(immed) sll 2);
                result <= std_logic_vector(resize(signed(NPC) + signed(offset), 64));
                if (op0 = op1) then
                    zero_branch <= '1';
                else
                    zero_branch <= '0';
                end if;
            when i_BNE =>
                offset := std_logic_vector(unsigned(immed) sll 2);
                result <= std_logic_vector(resize(signed(NPC) + signed(offset), 64));
                if (op0 /= op1) then
                    zero_branch <= '1';
                else
                    zero_branch <= '0';
                end if;
            when i_J =>
                result_temp(31 downto 28) := unsigned(NPC(31 downto 28));
                result_temp(27 downto 2) := unsigned(op0(25 downto 0));
                result_temp(1 downto 0) := to_unsigned(0,2);
                result <= std_logic_vector(resize(result_temp,64));
                zero_branch <= '1';
            when others => null;
        end case;
        
    end process;
end BHV;
