----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/05/2023 01:26:02 PM
-- Design Name: 
-- Module Name: adder_tree - Behavioral
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

entity adder_tree is
    generic(n_stage: integer:=3);
    Port ( wx : in std_logic_vector(2*(2**n_stage)-1 downto 0);
           y_out : out std_logic_vector(n_stage+1 downto 0));          
end adder_tree;

architecture Behavioral of adder_tree is

component nbit_adder is
generic ( n: integer:=4);
Port (
    A, B: in std_logic_vector(n-1 downto 0);
    S: out std_logic_vector(n downto 0)
 );
end component;


type INTERNAL is array (n_stage-1 downto 0) of STD_LOGIC_VECTOR (2*(n_stage+2)*(2**(n_stage-1)-1)-1 downto 0);
signal s_out, s_in : INTERNAL;



begin

adder_tree_uut: for i in 1 to n_stage generate
begin
    
    first_stage: if i=1 generate begin
        adders: for j in 1 to (2**(n_stage-1)) generate begin
            adders_i:  nbit_adder generic map (n=>i+1)  
                         Port map ( A => wx(2*(i+1)*(j-1)+i downto 2*(i+1)*(j-1)), 
                                    B => wx(2*(i+1)*(j-1)+2*(i+1)-1 downto 2*(i+1)*(j-1)+i+1),
                                    S => s_out(i-1)((i+2)*(j-1)+(i+2)-1 downto (i+2)*(j-1)));
        end generate;
    end generate;
         
    
    other_stages: if i>1 generate begin
        adders: for j in 1 to (2**(n_stage-i)) generate begin
            s_in(i-2)(2*(i+1)*(j-1)+i downto 2*(i+1)*(j-1))<= s_out(i-2)(2*(i+1)*(j-1)+i-1) & s_out(i-2)(2*(i+1)*(j-1)+i-1 downto 2*(i+1)*(j-1));
            s_in(i-2)(2*(i+1)*(j-1)+2*(i+1)-1 downto 2*(i+1)*(j-1)+i+1) <= s_out(i-2)(2*(i+1)*(j-1)+2*(i+1)-2) & s_out(i-2)(2*(i+1)*(j-1)+2*(i+1)-2 downto 2*(i+1)*(j-1)+i+1);
      
            adders_i:  nbit_adder generic map (n=>i+1)  
                         Port map ( A => s_in(i-2)(2*(i+1)*(j-1)+i downto 2*(i+1)*(j-1)),  
                                    B => s_in(i-2)(2*(i+1)*(j-1)+2*(i+1)-1 downto 2*(i+1)*(j-1)+i+1),
                                    S => s_out(i-1)((i+2)*(j-1)+(i+2)-1 downto (i+2)*(j-1)));
        end generate;
    end generate;
    
--    other_stages: if i>1 generate begin
--        adders: for j in 1 to (2**(n_stage-i)) generate begin
--        s_in (i-2) <= s_out(i-2)(2*(i+1)*(j-1)+i) & s_out(i-2)(2*(i+1)*(j-1)+i-1 downto 2*(i+1)*(j-1));
--            adders_i:  nbit_adder generic map (n=>i+1)  
--                         Port map ( A => s_out(i-2)(2*(i+1)*(j-1)+i downto 2*(i+1)*(j-1)),  
--                                    B => s_out(i-2)(2*(i+1)*(j-1)+2*(i+1)-1 downto 2*(i+1)*(j-1)+i+1),
--                                    S => s_out(i-1)((i+2)*(j-1)+(i+2)-1 downto (i+2)*(j-1)));
--        end generate;
--    end generate;

end generate;

y_out<=s_out(n_stage-1)(n_stage+1 downto 0);

end Behavioral;
