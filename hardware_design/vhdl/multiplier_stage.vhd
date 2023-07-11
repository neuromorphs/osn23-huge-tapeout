----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/05/2023 05:55:16 PM
-- Design Name: 
-- Module Name: multiplier_stage - Behavioral
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

entity multiplier_stage is
    generic(n_stage: integer:=5);
    
    Port ( w,x : in std_logic_vector((2**n_stage)-1 downto 0);
           mult_out : out std_logic_vector(2*(2**n_stage)-1 downto 0));
           
end multiplier_stage;

architecture Behavioral of multiplier_stage is

component multiplier is
Port ( 
    xi,wi: in std_logic;
    y: out std_logic_vector(1 downto 0)
);
end component;

begin
    
    multiplier_uut: for i in 0 to 2**n_stage-1 generate
    begin
    
    mult_i: multiplier Port map( xi=>x(i), wi=>w(i), y=>mult_out(2*i+1 downto 2*i));
           
    
    end generate;

end Behavioral;
