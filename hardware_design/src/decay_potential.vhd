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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decay_potential is
generic(n_stage: integer:=10);
Port (
    u : in std_logic_vector(n_stage+1 downto 0);
    shift: in std_logic_vector (2 downto 0); -- beta    |  shitf
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

begin
    
    with shift select
    beta_u <= '0' & u(n_stage+1 downto 1) when "001",
              "00" & u(n_stage+1 downto 2) when "010",
              "000" & u(n_stage+1 downto 3) when "011",
              "0000" & u(n_stage+1 downto 4) when "100",
              "00000" & u(n_stage+1 downto 5) when "101",
              "000000" & u(n_stage+1 downto 6) when "110",
              "0000000" & u(n_stage+1 downto 7) when "111",
              u when others;
    

end Behavioral;
