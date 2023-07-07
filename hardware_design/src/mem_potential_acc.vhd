----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/06/2023 01:50:21 PM
-- Design Name: 
-- Module Name: mem_potential_acc - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- u_out = beta*u + sum(w*x)

entity mem_potential_acc is
generic(n_stage: integer:=10);
Port (
    u_in,y_out : in std_logic_vector(n_stage+1 downto 0); -- y_out=sum(w*x)
    u_out : out std_logic_vector(n_stage+1 downto 0)
     );
end mem_potential_acc;

architecture Behavioral of mem_potential_acc is

component nbit_adder is
generic ( n: integer:=4);
Port (
    A, B: in std_logic_vector(n-1 downto 0);
    S: out std_logic_vector(n downto 0)
 );
end component;

signal s_out : std_logic_vector(n_stage+2 downto 0);

begin

adders_i:  nbit_adder generic map (n=>n_stage+2)  
                         Port map ( A => u_in, 
                                    B => y_out,
                                    S => s_out);
                                    
u_out<=s_out(n_stage+1 downto 0);                                    

end Behavioral;
