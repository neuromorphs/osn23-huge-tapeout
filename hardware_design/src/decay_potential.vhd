----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/06/2023 01:48:05 PM
-- Design Name: 
-- Module Name: decay_potential - Behavioral
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

entity decay_potential is
generic(n_stage: integer:=10);
Port (
    u : in std_logic_vector(n_stage+1 downto 0);
    shift: in std_logic_vector (2 downto 0); -- beta    |  shift   -- gamma=1-beta
                                             --  1      |    0
                                             -- 0.5     |    1
                                             -- 0.75    |    2
                                             -- 0.875   |    3
                                             -- 0.9375  |    4
                                             -- 0.96875 |    5
                                             -- 0.98438 |    6
                                             -- 0.99219 |    7
    beta_u: out std_logic_vector(n_stage+1 downto 0)

 );
end decay_potential;

architecture Behavioral of decay_potential is

signal  gamma_u, not_gamma_u, Cout:  std_logic_vector(n_stage+1 downto 0);


component full_adder is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           Cin : in STD_LOGIC;
           S : out STD_LOGIC;
           Cout : out STD_LOGIC);
end component;

begin
        
    with shift select
    gamma_u <= std_logic_vector(unsigned(u) srl 1) when "001",
              std_logic_vector(unsigned(u) srl 2) when "010",
              std_logic_vector(unsigned(u) srl 3) when "011",
              std_logic_vector(unsigned(u) srl 4) when "100",
              std_logic_vector(unsigned(u) srl 5) when "101",
              std_logic_vector(unsigned(u) srl 6) when "110",
              std_logic_vector(unsigned(u) srl 7) when "111",
              u when others;    

    not_gamma_u<= not(gamma_u);
    
    
    -- beta*u = u - gamma*u
    adder: for i in 0 to n_stage+1 generate
    begin
      first_ha: if i=0 generate begin
           first_fa_i : full_adder port map (A=>u(i), B=>not_gamma_u(i),Cin => '1', S=>beta_u(i), Cout=>Cout(i));
      end generate;
        
      other_fa: if i>0 generate begin
           other_fa_i : full_adder port map (A=>u(i), B=>not_gamma_u(i),Cin => Cout(i-1), S=>beta_u(i), Cout=>Cout(i));
      end generate;
        
    end generate;

end Behavioral;
