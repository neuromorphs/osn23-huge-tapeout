----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/03/2023 02:55:14 PM
-- Design Name: 
-- Module Name: nbit_adder - Behavioral
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

entity nbit_adder is
generic ( n: integer:=25);
Port (
    A, B: in std_logic_vector(n-1 downto 0);
    S: out std_logic_vector(n downto 0)
 );
end nbit_adder;

architecture Behavioral of nbit_adder is

component full_adder is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           Cin : in STD_LOGIC;
           S : out STD_LOGIC;
           Cout : out STD_LOGIC);
end component;

component half_adder is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           S : out STD_LOGIC;
           Cout : out STD_LOGIC);
end component;

signal Cout,Cin: std_logic_vector(n downto 0);

begin
    
    adder: for i in 0 to N-1 generate
    begin
        first_ha: if i=0 generate begin
             ha1 : half_adder port map (A=>A(i), B=>B(i), S=>S(i), Cout=>Cout(i));
        end generate;
        
        other_fa: if i>0 generate begin
             other_fa_i : full_adder port map (A=>A(i), B=>B(i),Cin => Cout(i-1), S=>S(i), Cout=>Cout(i));
        end generate;
        
    end generate;
            
    S(N)<=Cout(N-1);
        
end Behavioral;
