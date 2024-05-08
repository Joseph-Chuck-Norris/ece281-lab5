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
    signal w_adder : STD_LOGIC_VECTOR(8 DOWNTO 0);
    signal w_and_nand : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal w_or_nor : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal w_shift : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal w_output : STD_LOGIC_VECTOR(7 DOWNTO 0);


    
begin
       w_adder <= std_logic_vector(unsigned('0'&i_A) + unsigned('0'&i_B)) when i_op(2) = '0' else
                  std_logic_vector(unsigned('0'&i_A) + unsigned(not('0'&i_B)) + 1);
       w_and_nand <= i_A AND i_B when i_op(2) = '0' else
                     NOT(i_A AND i_B);
       w_or_nor <= i_A OR i_B when i_op(2) = '0' else
                   NOT(i_A OR i_B);
     
       w_shift <= std_logic_vector(shift_left(unsigned(i_A), to_integer(unsigned(i_B(2 downto 0))))) when i_op(2) = '0' else
                  std_logic_vector(shift_right(unsigned(i_A), to_integer(unsigned(i_B(2 downto 0)))));
       
       --w_adder <= std_logic_vector(unsigned(i_A) + unsigned(i_B));
       w_output <= w_adder(7 DOWNTO 0) when i_op(1 DOWNTO 0) = "00" else
                   w_and_nand(7 DOWNTO 0) when i_op(1 DOWNTO 0) = "01" else
                   w_or_nor(7 DOWNTO 0) when i_op(1 DOWNTO 0) = "10" else
                   w_shift(7 DOWNTO 0);
	   o_results <= w_output;
	   o_flags(2) <= '1' when (w_output(7) = '1') else '0';
	   o_flags(0) <= w_adder(8) when i_op(1 DOWNTO 0) = "00" else
	                 '0'; -- C out
	   o_flags(1) <= '1' when (w_output = "00000000") else '0'; -- zero flag
	   
	
	
end behavioral;
