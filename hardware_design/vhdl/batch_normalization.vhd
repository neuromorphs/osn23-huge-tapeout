----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/10/2023 06:17:39 PM
-- Design Name: 
-- Module Name: batch_normalization - Behavioral
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

entity batch_normalization is
generic(n_stage: integer:=2);
Port ( BN_u_in : in std_logic_vector(n_stage+1 downto 0);
       BN_factor: in std_logic_vector(3 downto 0);
       BN_addend: in std_logic_vector(n_stage+1 downto 0);
       BN_u_out : out std_logic_vector(n_stage+1 downto 0)
       ); 
end batch_normalization;


architecture Behavioral of batch_normalization is

component nbit_adder is
generic ( n: integer:=4);
Port (
    A, B: in std_logic_vector(n-1 downto 0);
    S: out std_logic_vector(n downto 0)
 );
end component;

signal shift_1_out, shift_2_out, adder2_in : std_logic_vector(n_stage+1 downto 0);
signal adder1_out,adder2_out : std_logic_vector(n_stage+2 downto 0);

begin


with BN_factor(1 downto 0) select
shift_1_out <= std_logic_vector(unsigned(BN_u_in) srl 1) when "01",
          std_logic_vector(unsigned(BN_u_in) sll 1) when "10",
          std_logic_vector(unsigned(BN_u_in) sll 3) when "11",
          (others=>'0') when others;   --00
              
 
with BN_factor(3 downto 2) select
shift_2_out <= BN_u_in when "01",
          std_logic_vector(unsigned(BN_u_in) srl 2) when "10",
          std_logic_vector(unsigned(BN_u_in) sll 2) when "11",
          (others=>'0') when others;   --00             


adder_1: nbit_adder generic map ( n=>n_stage+2 )
Port map (
    A=> shift_1_out, B=> shift_2_out,
    S=> adder1_out );

adder2_in<=adder1_out(n_stage+1 downto 0);

adder_2: nbit_adder generic map ( n=>n_stage+2 )
Port map (
    A=> BN_addend, B=> adder2_in,
    S=> adder2_out);
    
    
BN_u_out<=adder2_out(n_stage+1 downto 0);    
    
end Behavioral;
