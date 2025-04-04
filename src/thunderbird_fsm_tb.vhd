--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is

    -- Component declaration
    component thunderbird_fsm is
        port (
            i_clk       : in  std_logic;
            i_reset     : in  std_logic;
            i_left      : in  std_logic;
            i_right     : in  std_logic;
            o_lights_L  : out std_logic_vector(2 downto 0);
            o_lights_R  : out std_logic_vector(2 downto 0)
        );
    end component;

    -- Signals to connect to the FSM
    signal tb_clk      : std_logic := '0';
    signal tb_reset    : std_logic := '0';
    signal tb_left     : std_logic := '0';
    signal tb_right    : std_logic := '0';
    signal tb_lights_L : std_logic_vector(2 downto 0);
    signal tb_lights_R : std_logic_vector(2 downto 0);

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Connect the FSM to test signals
    uut: thunderbird_fsm
        port map (
            i_clk       => tb_clk,
            i_reset     => tb_reset,
            i_left      => tb_left,
            i_right     => tb_right,
            o_lights_L  => tb_lights_L,
            o_lights_R  => tb_lights_R
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            tb_clk <= '0';
            wait for CLK_PERIOD / 2;
            tb_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Main test process
    stim_proc : process
    begin
        -- Reset the FSM
        tb_reset <= '1';
        wait for 20 ns;
        tb_reset <= '0';
        wait for 20 ns;

        -- Test Left turn signal
        tb_left <= '1';
        tb_right <= '0';
        wait for 300 ns;
        tb_left <= '0';
        wait for 100 ns;

        -- Test Right turn signal
        tb_left <= '0';
        tb_right <= '1';
        wait for 300 ns;
        tb_right <= '0';
        wait for 100 ns;

        -- Test Hazard lights
        tb_left <= '1';
        tb_right <= '1';
        wait for 300 ns;
        tb_left <= '0';
        tb_right <= '0';

        -- Stop simulation
        wait;
    end process;

end test_bench;
