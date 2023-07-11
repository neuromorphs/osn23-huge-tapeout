----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2023 03:06:05 PM
-- Design Name: 
-- Module Name: spike_generator - Behavioral
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

entity spike_generator is
generic(n_stage: integer:=2);
Port (
    u,minus_teta  : in std_logic_vector(n_stage+1 downto 0); 
    is_spike: out std_logic
     );
end spike_generator;

architecture Behavioral of spike_generator is

component nbit_adder is
generic ( n: integer:=4);
Port (
    A, B: in std_logic_vector(n-1 downto 0);
    S: out std_logic_vector(n downto 0)
 );
end component;

signal s_out  :  std_logic_vector(n_stage+2 downto 0); 

begin


Adder_1:  nbit_adder generic map (n=>n_stage+2)  
                         Port map ( A => u, 
                                    B => minus_teta,
                                    S => s_out);
          
is_spike <= not (s_out(n_stage+2));


end Behavioral;
