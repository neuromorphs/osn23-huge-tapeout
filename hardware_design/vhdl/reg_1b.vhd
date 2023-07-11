----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/10/2023 04:53:05 PM
-- Design Name: 
-- Module Name: reg_1b - Behavioral
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

entity reg_1b is
    Port ( d : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC; -- active low reset
           ce : in STD_LOGIC;
           q : out STD_LOGIC);
end reg_1b;

architecture Behavioral of reg_1b is

begin
 process (clk)
   begin
     if clk'event and clk='1' then
        if rst_n='0' then
           q <='0';
        elsif ce ='1' then
           q <= d;
        end if;
     end if;
   end process;

end Behavioral;
