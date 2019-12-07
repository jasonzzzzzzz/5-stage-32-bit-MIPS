library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_pkg.all;

entity MIPS_CTRL is
    Port ( 
        clk : in std_logic;
        rst_n : in std_logic;
        go : in std_logic;
        done : out std_logic;

        IF_inst : in std_logic_vector(31 downto 0);
        IF_next_inst : in std_logic_vector(31 downto 0);

        ctrl_PC_en : out std_logic;
        ctrl_decoder_en : out std_logic;
        ctrl_EX_en : out std_logic
    );
end MIPS_CTRL;

architecture Behavioral of MIPS_CTRL is
    type STATE_TYPE is (S_INIT, S_WORKING, S_DATA_HAZARD, S_CONTROL_HAZARD, S_DONE);
    signal state, next_state : STATE_TYPE;
    signal next_done : std_logic;
    signal hazard_detected : T_HAZARD;
    signal IF_inst_type : T_INST;
    signal IF_next_inst_type : T_INST;
    signal DHS,DHS_state : signed(4 downto 0);
    signal CHS,CHS_state : signed(4 downto 0);
begin

-- Instruction Interpreter
    U_SIMPLE_II1 : entity work.MIPS_simple_InstIntprtr
        port map(
            IF_inst => IF_inst,
            ID_inst_descript_temp => IF_inst_type
        );
    U_SIMPLE_II2 : entity work.MIPS_simple_InstIntprtr
        port map(
            IF_inst => IF_next_inst,
            ID_inst_descript_temp => IF_next_inst_type
        );
        
-- Hazard Detector
    process(IF_inst,IF_next_inst,IF_inst_type,IF_next_inst_type)
    begin
        hazard_detected <= h_NO;
        case IF_inst_type is
            when i_BEQ|i_BNE|i_J =>
                hazard_detected <= h_CONTROL;
                
           
                    when others => null;

        end case;
    end process;

-- 2-process FSM
    process(clk, rst_n)
    begin
        if (rst_n = '0') then
            state <= S_INIT;
            done <= '0';
            CHS <= (others => '0');
            DHS <= (others => '0');
        elsif (rising_edge(clk)) then 
            state <= next_state;
            done <= next_done;
            CHS <= CHS_state;
            DHS <= DHS_state;
        end if;
    end process;
    
    process(state, go, hazard_detected,CHS,DHS)
    begin
    
        ctrl_PC_en <= '0';
        ctrl_decoder_en <= '0';
        ctrl_EX_en <= '0';
        next_state <= state;
        next_done <= '0';
        CHS_state <= CHS;
        DHS_state <= DHS;
        
        case state is
            when S_INIT =>
                if (go = '1') then
                    next_state <= S_WORKING;
                end if;
                
            when S_WORKING =>
                if (hazard_detected = h_NO) then
                    ctrl_PC_en <= '1';
                    ctrl_decoder_en <= '1';
                    ctrl_EX_en <= '1';
                elsif (hazard_detected = h_DATA) then
                    ctrl_PC_en <= '0';
                    ctrl_decoder_en <= '1';
                    ctrl_EX_en <= '1';
                    DHS_state <= to_signed(1,5);
                    next_state <= S_DATA_HAZARD;
                elsif (hazard_detected = h_CONTROL) then
                    ctrl_PC_en <= '0';
                    ctrl_decoder_en <= '1';
                    ctrl_EX_en <= '1';
                    CHS_state <= to_signed(2,5);
                    next_state <= S_CONTROL_HAZARD;
                end if;
                
            when S_DATA_HAZARD =>
                if (DHS_state > 0) then
                    ctrl_PC_en <= '0';
                    ctrl_decoder_en <= '1';
                    ctrl_EX_en <= '1';
                    DHS_state <= DHS_state - 1;
                else
                    ctrl_PC_en <= '0';
                    ctrl_decoder_en <= '1';
                    ctrl_EX_en <= '1';
                    next_state <= S_WORKING;
                end if;
                
            when S_CONTROL_HAZARD =>
                if (CHS_state > 0) then
                    ctrl_PC_en <= '0';
                    ctrl_decoder_en <= '1';
                    ctrl_EX_en <= '1';
                    CHS_state <= CHS_state - 1;
                else
                    ctrl_PC_en <= '0';
                    ctrl_decoder_en <= '1';
                    ctrl_EX_en <= '1';
                    next_state <= S_WORKING;
                end if;          

            when S_DONE =>
                next_done <= '1';
                next_state <= S_INIT;
            when others => null;
        end case;
    end process;    

end Behavioral;
