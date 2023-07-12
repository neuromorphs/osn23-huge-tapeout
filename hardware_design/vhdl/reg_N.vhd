----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/10/2023 04:41:42 PM
-- Design Name: 
-- Module Name: reg_N - Behavioral
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

entity reg_N is
    Generic (N : integer := 16);
    Port ( d : in STD_LOGIC_VECTOR (N-1 downto 0);
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC; -- active low reset
           ce : in STD_LOGIC;
           q : out STD_LOGIC_VECTOR (N-1 downto 0));
end reg_N;

architecture Behavioral of reg_N is

begin
 process (clk)
   begin
     if clk'event and clk='1' then
        if rst_n='0' then
           q <= (others=>'0');
        elsif ce ='1' then
           q <= d;
        end if;
     end if;
   end process;

end Behavioral;
