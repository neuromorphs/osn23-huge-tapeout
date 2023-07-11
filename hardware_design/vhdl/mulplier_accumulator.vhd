----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/05/2023 06:17:43 PM
-- Design Name: 
-- Module Name: mulplier_accumulator - Behavioral
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

entity mulplier_accumulator is
    generic(n_stage: integer:=6);
    Port ( w,x : in std_logic_vector((2**n_stage)-1 downto 0);
           y_out : out std_logic_vector(n_stage+1 downto 0)); 
end mulplier_accumulator;

architecture Behavioral of mulplier_accumulator is

component adder_tree is
    generic(n_stage: integer:=5); 
    Port ( wx : in std_logic_vector(2*(2**n_stage)-1 downto 0);
           y_out : out std_logic_vector(n_stage+1 downto 0));      
end component;

component multiplier_stage is
    generic(n_stage: integer:=5);
    Port ( w,x : in std_logic_vector((2**n_stage)-1 downto 0);
           mult_out : out std_logic_vector(2*(2**n_stage)-1 downto 0));     
end component;

signal mult_out : std_logic_vector(2*(2**n_stage)-1 downto 0);

begin

mult_uut: multiplier_stage generic map(n_stage=>n_stage)
          Port map ( w=>w, x=>x,mult_out=>mult_out);
          
          
adder_uut: adder_tree generic map(n_stage=>n_stage)
          Port map ( wx=>mult_out, y_out=>y_out);


end Behavioral;
