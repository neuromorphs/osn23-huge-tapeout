----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/11/2023 02:36:22 PM
-- Design Name: 
-- Module Name: sipo - Behavioral
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


entity SIPO is
    Generic (N : integer := 16;
             M: integer := 16);
    Port ( SERIAL_IN : in STD_LOGIC_VECTOR(N-1 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           ce : in STD_LOGIC;
           O_1 : out STD_LOGIC_VECTOR (N-1 downto 0);
           O_2 : out STD_LOGIC_VECTOR (N-1 downto 0);
           O_3 : out STD_LOGIC_VECTOR (N-1 downto 0);
           O_4 : out STD_LOGIC_VECTOR (N-1 downto 0);
           O_5 : out STD_LOGIC_VECTOR (N-1 downto 0));
end SIPO;

architecture Structural of SIPO is

component reg_N is
    Generic (N : integer := 16);
    Port ( d : in STD_LOGIC_VECTOR (N-1 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           ce : in STD_LOGIC;
           q : out STD_LOGIC_VECTOR (N-1 downto 0));
end component;

type INTERNAL_NODES is array(5 downto 0) of STD_LOGIC_VECTOR(N-1 downto 0);
signal x : INTERNAL_NODES;

begin
    x(0)<=serial_in;
    SH_REG:
       for i in 0 to 4 generate
          begin
             r : reg_N generic map (N=>N) port map (d=>x(i), clk=>clk, rst=>rst, ce=>ce, q=>x(i+1));
       end generate;
    O_1<=x(1);
    O_2<=x(2);
    O_3<=x(3);
    O_4<=x(4);
    O_5<=x(5);
end Structural;
