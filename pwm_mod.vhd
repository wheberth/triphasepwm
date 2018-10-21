--    triphasepwm - Hardware description in vhdl of a 3-phase pwm modulator
--    Copyright (C) 2018 Wheberth Dias <wheberth@gmail.com>
-----------------------------------------------------------------------------
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------

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
    in_pcmData_A: in std_logic_vector(NBITS-1 downto 0);
    in_pcmData_B: in std_logic_vector(NBITS-1 downto 0);
    in_pcmData_C: in std_logic_vector(NBITS-1 downto 0);
    in_mode     : in std_logic; -- 0: triangle, 1: sawtooth
    -- module outputs
    out_pwm_A   : out std_logic;
    out_pwm_B   : out std_logic;
    out_pwm_C   : out std_logic;
    out_sync    : out std_logic
);
end pwm_mod;

architecture behavior of pwm_mod is
    signal counter  : unsigned(NBITS-1 downto 0);
    signal mode         : std_logic;
    signal pcmData_A    : unsigned(NBITS-1 downto 0);
    signal pcmData_B    : unsigned(NBITS-1 downto 0);
    signal pcmData_C    : unsigned(NBITS-1 downto 0);
    signal countDown    : std_logic;
    signal start        : std_logic := '0';
    constant MAXVAL     : unsigned(NBITS-1 downto 0) := (others=>'1');
    constant MINVAL     : unsigned(NBITS-1 downto 0) := (others=>'0');

begin
    -- Registering inputs
    reginput_proc : process(in_clk, in_rst)
    begin
        if (in_rst='1') then
            mode    <= '0';
            pcmData_A <= (others=>'0');
            pcmData_B <= (others=>'0');
            pcmData_C <= (others=>'0');
        elsif rising_edge(in_clk) and ((counter=MINVAL) or (counter=MAXVAL)) then
            -- Update PWM inputs twice in one PWM period
            mode    <= in_mode;
            pcmData_A <= unsigned(in_pcmData_A);
            pcmData_B <= unsigned(in_pcmData_B);
            pcmData_C <= unsigned(in_pcmData_C);
        end if;
    end process;

    -- Process to generate sawtooth/triangle
    counter_proc : process(in_clk, in_rst)
    begin
        if (in_rst='1') then
            counter     <= (others=>'0');
            countDown   <= '0';
            out_sync    <= '0';
        elsif rising_edge(in_clk)  then
            out_sync <= '1' when (counter=MINVAL) else '0'; 
            case mode is
                when '1' =>
                    countDown <= '0';
                    counter <= counter + 1;
                when others =>
                    -- Invert counter
                    if (counter = MINVAL) then
                        countDown <= '0';
                        counter <= (counter + 1);   
                    elsif (counter = MAXVAL) then
                        countDown <= '1';
                        counter <= (counter - 1);
                    else
                        counter <= (counter + 1) when (countDown='0') else (counter - 1);
                    end if;
            end case;
        end if;
    end process;

    -- Process to generate pwm signal
    pwm_proc : process(in_clk, in_rst)
    begin
        if (in_rst='1') then
            -- async reset output 
            out_pwm_A <= '0';
            out_pwm_B <= '0';
            out_pwm_C <= '0';
        elsif rising_edge(in_clk) then
            case mode is
                when '0' =>
                    --out_pwm <= '1' when (pcmData > counter) else '0';
                    out_pwm_A <= 
                        '0' when ((pcmData_A=counter) and (countDown='0')) else
                        '1' when ((pcmData_A=counter) and (countDown='1')) ;
                    out_pwm_B <= 
                        '0' when ((pcmData_B=counter) and (countDown='0')) else
                        '1' when ((pcmData_B=counter) and (countDown='1')) ;
                    out_pwm_C <= 
                        '0' when ((pcmData_C=counter) and (countDown='0')) else
                        '1' when ((pcmData_C=counter) and (countDown='1')) ;
                
                when others =>
                    out_pwm_A <= 
                        '1' when (counter=MINVAL) else
                        '0' when (pcmData_A=counter);
                    out_pwm_B <= 
                        '1' when (counter=MINVAL) else
                        '0' when (pcmData_B=counter); 
                    out_pwm_C <= 
                        '1' when (counter=MINVAL) else
                        '0' when (pcmData_C=counter); 
            end case;
        end if;
    end process;                
end behavior;
