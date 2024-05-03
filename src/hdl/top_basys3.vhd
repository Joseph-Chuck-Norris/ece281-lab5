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
-- TODO 
    port(
         clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0);
        btnU    :   in std_logic; -- master_reset
        btnC    :   in std_logic; -- clk_reset
        
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
        
);
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
    
    -- declare components and signals
    component TDM4 is
        generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
        Port ( 
            i_clk        : in  STD_LOGIC;
            i_reset      : in  STD_LOGIC; -- asynchronous
            i_D3         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            i_D2         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            i_D1         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            i_D0         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            o_data       : out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            o_sel        : out STD_LOGIC_VECTOR (3 downto 0)    -- selected data line (one-cold)
        );
    end component TDM4;
    
    component twoscomp_decimal is
        Port (
            i_binary: in std_logic_vector(7 downto 0);
            o_negative: out std_logic;
            o_hundreds: out std_logic_vector(3 downto 0);
            o_tens: out std_logic_vector(3 downto 0);
            o_ones: out std_logic_vector(3 downto 0)
        );
    end component twoscomp_decimal;            
    
    component clock_divider is
    generic ( constant k_DIV : natural := 2    ); -- How many clk cycles until slow clock toggles
                                            -- Effectively, you divide the clk double this 
                                 -- number (e.g., k_DIV := 2 --> clock divider of 4)
        Port (
            i_clk    : in std_logic;
            i_reset  : in std_logic;           -- asynchronous
            o_clk    : out std_logic           -- divided (slow) clock
        );
    end component clock_divider;
    
    component sevenSegDecoder is
        Port(
            i_D : in std_logic_vector (3 downto 0);
            o_S : out std_logic_vector (6 downto 0)
        );    
    end component sevenSegDecoder;     
    
    component controller_fsm is
        Port (
            i_reset   : in  STD_LOGIC;
            i_adv : in  STD_LOGIC;
            o_cycle   : out STD_LOGIC_VECTOR (3 downto 0)           
        );
    end component controller_fsm;
    
    component ALU is
        Port (
            i_A : in STD_LOGIC_VECTOR (7 DOWNTO 0);
            i_B : in STD_LOGIC_VECTOR (7 DOWNTO 0);
            i_op : in STD_LOGIC_VECTOR (2 DOWNTO 0);
            o_results : out STD_LOGIC_VECTOR (7 DOWNTO 0);
            o_flags : out STD_LOGIC_VECTOR (2 DOWNTO 0)
        );
    end component ALU;   
    
    component REG is
        port (
            i_LD: in std_logic;
            i_D : in std_logic_vector (7 downto 0);
            o_D : out std_logic_vector (7 downto 0)
        );
    end component REG;  
    
    signal w_cycle : STD_LOGIC_VECTOR (3 DOWNTO 0);
    signal w_clk : STD_LOGIC;
    signal w_A : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal w_B : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal w_results : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal w_bin : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal w_sign : STD_LOGIC_VECTOR (3 DOWNTO 0);
    signal w_hund : STD_LOGIC_VECTOR (3 DOWNTO 0);
    signal w_tens : STD_LOGIC_VECTOR (3 DOWNTO 0);
    signal w_ones : STD_LOGIC_VECTOR (3 DOWNTO 0);
    signal w_data : STD_LOGIC_VECTOR (3 DOWNTO 0);
    signal w_sel : STD_LOGIC_VECTOR (3 DOWNTO 0);
    signal w_flags : STD_LOGIC_VECTOR (2 DOWNTO 0);
    signal w_an : STD_LOGIC_VECTOR (3 DOWNTO 0);
begin
	-- PORT MAPS ----------------------------------------
    TDM4_inst: TDM4
    port map(
        i_clk => w_clk,
        i_reset => '0',
        i_D3 => w_ones,
        i_D2 => w_tens,
        i_D1 => w_hund,
        i_D0 => w_sign,
        o_data => w_data,
        o_sel => w_sel
    );
    
    twoscomp_decimal_inst: twoscomp_decimal
    port map(
        i_binary => w_bin,
        o_negative => w_sign(0),
        o_hundreds => w_hund,
        o_tens => w_tens,
        o_ones => w_ones
    );
    
    clkdiv_inst: clock_divider
    generic map ( k_DIV => 208333)
    port map (
        i_clk => clk,
        i_reset => '0',
        o_clk => w_clk
    );
    
    sevenSeg_inst: sevenSegDecoder
    port map (
    i_D => w_data,
    o_S => seg
    );
    
    controllerFSM_inst: controller_fsm
    port map (
    i_reset => btnU,
    i_adv => btnC,
    o_cycle => w_cycle
    );
    
    ALU_inst: ALU
    port map (
        i_A => w_A,
        i_B => w_B,
        i_op => sw(2 DOWNTO 0),
        o_results => w_results,
        o_flags => w_flags
	);
	
	REG_A_inst: REG
	port map (
	    i_LD => w_cycle(3),
        i_D => sw(7 DOWNTO 0),
        o_D => w_A
	);
	
	REG_B_inst: REG
        port map (
            i_LD => w_cycle(2),
            i_D => sw(7 DOWNTO 0),
            o_D => w_A
        );
	
	-- CONCURRENT STATEMENTS ----------------------------
	
	w_an <= x"F" when w_cycle(0) = '1' else
	        w_sel;
	w_bin <= w_A when w_cycle(3) = '1' else
	         w_B when w_cycle(2) = '1' else
	         w_results when w_cycle(1) = '1';
	
	led(15 DOWNTO 13) <= w_flags;
	led(3 DOWNTO 0) <= w_cycle;
	an(3 DOWNTO 0) <= w_an;
	
	
end top_basys3_arch;
