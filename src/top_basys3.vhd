--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2018 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : top_basys3.vhd
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 02/22/2018
--| DESCRIPTION   : This file implements the top level module for a BASYS 3 to 
--|					drive a Thunderbird taillight controller FSM.
--|
--|					Inputs:  clk 	--> 100 MHz clock from FPGA
--|                          sw(15) --> left turn signal
--|                          sw(0)  --> right turn signal
--|                          btnL   --> clk reset
--|                          btnR   --> FSM reset
--|							 
--|					Outputs:  led(15:13) --> left turn signal lights
--|					          led(2:0)   --> right turn signal lights
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm.vhd, clock_divider.vhd
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

entity top_basys3 is
    port (
        CLK100MHZ : in std_logic;
        SW        : in std_logic_vector(15 downto 0);
        LED       : out std_logic_vector(15 downto 0)
    );
end top_basys3;

architecture struct of top_basys3 is

    -- Signal declarations
    signal w_clk_slow     : std_logic;
    signal w_lights_L     : std_logic_vector(2 downto 0);
    signal w_lights_R     : std_logic_vector(2 downto 0);

    -- Clock divider component
    component clock_divider is
        generic (
            k_DIV : natural := 12500000  -- divide 100 MHz down to 4 Hz (100M / 25M = 4 Hz)
        );
        port (
            i_clk   : in  std_logic;
            o_clk   : out std_logic
        );
    end component;

    -- FSM component
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

begin

    -- Instantiate clock divider
    u_clk_div : clock_divider
        generic map(k_DIV => 25000000)  -- for 4 Hz from 100 MHz
        port map(
            i_clk => CLK100MHZ,
            o_clk => w_clk_slow
        );

    -- Instantiate FSM
    u_fsm : thunderbird_fsm
        port map(
            i_clk       => w_clk_slow,
            i_reset     => SW(0),         -- SW0: Reset
            i_left      => SW(1),         -- SW1: Left signal
            i_right     => SW(2),         -- SW2: Right signal
            o_lights_L  => w_lights_L,
            o_lights_R  => w_lights_R
        );

    -- Assign FSM outputs to LEDs
    LED(2 downto 0)  <= w_lights_L;  -- LED0-2: Left signals (LC, LB, LA)
    LED(5 downto 3)  <= w_lights_R;  -- LED3-5: Right signals (RA, RB, RC)
    LED(15 downto 6) <= (others => '0'); -- unused

end struct;

