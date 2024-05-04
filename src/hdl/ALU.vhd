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
--|
--| ALU OPCODES:
--|
--|     ADD     000
--|
--|
--|
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;



entity ALU is
    port (
    i_A : in STD_LOGIC_VECTOR (7 DOWNTO 0);
    i_B : in STD_LOGIC_VECTOR (7 DOWNTO 0);
    i_op : in STD_LOGIC_VECTOR (2 DOWNTO 0);
    o_results : out STD_LOGIC_VECTOR (7 DOWNTO 0);
    o_flags : out STD_LOGIC_VECTOR (2 DOWNTO 0)
    );
end ALU;

architecture behavioral of ALU is 
  
	-- declare components and signals
    --signal w_decoderOne : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal w_adder : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal w_output : STD_LOGIC_VECTOR(7 DOWNTO 0);
    --signal w_SEL : STD_LOGIC_VECTOR(1 DOWNTO 0);
    --signal w_D_IN : STD_LOGIC_VECTOR(3 DOWNTO 0);

    
begin
	-- PORT MAPS ----------------------------------------
	    
	    --w_decoderOne <= not i_B when i_op(2) = '1' else 
	    --           i_B;
        --w_adder <= (std_logic_vector(unsigned(i_A) + unsigned(w_decoderOne))) when i_op(2) = '0'else
          --         (std_logic_vector(unsigned(i_A) + unsigned(not w_decoderOne) + 1));
        w_adder <= std_logic_vector(unsigned(i_A) + unsigned(i_B));
--        with i_op(1 DOWNTO 0) select
--            w_output <= w_adder when "00",
----                          when "01", and/nand
----                          when "10", or/nor
----                          when "11", shift
--                         "00000000" when others;
       w_output <= w_adder;
	   o_results <= w_output;
	
	-- CONCURRENT STATEMENTS ----------------------------
	   --o_flags(0) <= w_output(7); -- negative flag
	   --o_flags(1) <= '1' when (w_output = "00000000") else '0'; -- zero flag
	   
	
	
end behavioral;
