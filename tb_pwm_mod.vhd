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

entity tb_pwm_mod is
end tb_pwm_mod;

architecture behavior of tb_pwm_mod is
     
    -- component declaration
    component pwm_mod
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
    end component;
    
    -- testbench signal declarations    
    signal tb_clock     : std_logic := '0';
    signal tb_reset     : std_logic := '0';
    signal tb_pwm_A     : std_logic := '0';
    signal tb_pwm_B     : std_logic := '0';
    signal tb_pwm_C     : std_logic := '0';
    signal tb_mode     : std_logic := '0';
    constant tb_NBITS   : natural := 10;
    constant clk_period : time := 3.0 ns;

    begin
        -- component
        pwmMod_inst : pwm_mod 
        generic map(
            NBITS => tb_NBITS
        )
        port map (
            in_clk      => tb_clock, 
            in_rst      => tb_reset,
            in_pcmData_A  => std_logic_vector(to_unsigned(1000, tb_NBITS)),
            in_pcmData_B  => std_logic_vector(to_unsigned(500, tb_NBITS)),
            in_pcmData_C  => std_logic_vector(to_unsigned(100, tb_NBITS)),
            
            in_mode     => tb_mode,
            out_pwm_A   => tb_pwm_A,
            out_pwm_B   => tb_pwm_B,
            out_pwm_C   => tb_pwm_C
        );
        -- concurrent statements

        tb_mode <= '1' after 200 us; 


        -- processess
        clk_process : process
        begin
             tb_clock <= '0';
             wait for clk_period/2;
             tb_clock <= '1';
             wait for clk_period/2;
        end process;

        rst_process : process
        begin
            tb_reset <= '1';
            wait for clk_period;
            tb_reset <= '0';
            wait;
        end process;
    end;
