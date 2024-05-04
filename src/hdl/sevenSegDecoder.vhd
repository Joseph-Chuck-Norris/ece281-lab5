----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2024 02:09:33 PM
-- Design Name: 
-- Module Name: sevenSegDecoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sevenSegDecoder is
--  Port ( );
    port(
       i_D : in std_logic_vector (3 downto 0);
       o_S : out std_logic_vector (6 downto 0)
    );	
end sevenSegDecoder;

architecture Behavioral of sevenSegDecoder is
    
    
begin
--A
o_S(0) <= '1' when ((i_D = x"1") or
                    (i_D = x"4") or
                    (i_D = x"C") or
                    (i_D = x"D") or
                    (i_D = x"B")) else '0';
--(i_D(2) and not i_D(1) and not i_D(0)) or (i_D(3) and i_D(2) and not i_D(1)) or (i_D(3) and not i_D(2) and i_D(1) and i_D(0));

--B
o_S(1) <= '1' when ((i_D = x"5") or
                    (i_D = x"6") or
                    (i_D = x"B") or
                    (i_D = x"C") or
                    (i_D = x"E") or
                    (i_D = x"F")) else '0';
--(i_D(2) and i_D(1) and not i_D(0)) or (i_D(3) and i_D(1) and i_D(0)) or (i_D(3) and i_D(2) and not i_D(0)) or (not i_D(3) and i_D(2) and not i_D(1) and i_D(0));

--C
o_S(2) <= (i_D(3) and i_D(2) and not i_D(0)) or (i_D(3) and i_D(2) and i_D(1)) or (not i_D(3) and not i_D(2) and i_D(1) and not i_D(0));

--D
o_S(3) <= (not i_D(2) and not i_D(1) and i_D(0)) or (i_D(2) and i_D(1) and i_D(0)) or (i_D(3) and not i_D(2) and i_D(1) and not i_D(0)) or (not i_D(3) and i_D(2) and not i_D(1) and not i_D(0));

--E
o_S(4) <= (not i_D(3) and i_D(0)) or (not i_D(2) and not i_D(1) and i_D(0)) or (not i_D(3) and i_D(2) and not i_D(1));

--F
o_S(5) <= (i_D(3) and i_D(2) and not i_D(1)) or (not i_D(3) and i_D(1) and i_D(0)) or (not i_D(3) and not i_D(2) and i_D(0)) or (not i_D(3) and not i_D(2) and i_D(1));

--G
o_S(6) <= (not i_D(3) and not i_D(2) and not i_D(1)) or (not i_D(3) and i_D(2) and i_D(1) and i_D(0));

end Behavioral;
