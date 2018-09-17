library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_mod is 
generic(
    NBITS : natural range 2 to 18 := 16
);
port(
    -- master signal inputs
    in_clk      : in std_logic;
    in_rst      : in std_logic;
    -- module inputs
    in_pcmData  : in std_logic_vector(NBITS-1 downto 0);
    in_mode     : in std_logic; -- 0: triangle, 1: sawtooth
    -- module outputs
    out_pwm     : out std_logic
);
end pwm_mod;

architecture behavior of pwm_mod is
    signal counter  : unsigned(NBITS-1 downto 0);
    -- signal reg_greater  : std_logic;
    signal mode         : std_logic;
    signal pcmData      : unsigned(NBITS-1 downto 0);
begin
    -- Registering inputs
    reginput_proc : process(in_clk, in_rst)
    begin
        if (in_rst='1') then
            mode    <= '0';
            pcmData <= (others=>'0');
        elsif rising_edge(in_clk) then
            mode    <= in_mode;
            pcmData <= unsigned(in_pcmData);
        end if;
    end process;

    -- Process to generate sawtooth/triangle
    counter_proc : process(in_clk, in_rst)
    begin
        if (in_rst='1') then
            counter <= (others=>'0');
        elsif rising_edge(in_clk) then
            case mode is
                when '1' =>
                    counter <= counter + 1;
                when others =>
                    if (counter = (counter'HIGH)) then
                        counter <= (counter - 1);
                    else
                        counter <= (counter + 1);
                    end if;        
            end case;
        end if;
    end process;

    -- Process to generate pwm signal
    pwm_proc : process(in_clk, in_rst)
    begin
        if (in_rst='1') then
            out_pwm <= '0';
        elsif rising_edge(in_clk) then
            out_pwm <= '1' when (pcmData > counter) else '0';
        end if;
    end process;                
end behavior;