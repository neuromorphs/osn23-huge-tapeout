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
    Generic (N : integer := 4;
             M: integer := 64);
    Port ( serial_in : in STD_LOGIC_VECTOR(N-1 downto 0);
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           ce : in STD_LOGIC;
           parallel_out : out STD_LOGIC_VECTOR (M-1 downto 0));
end SIPO;

architecture Structural of SIPO is

component reg_N is
    Generic (N : integer := 16);
    Port ( d : in STD_LOGIC_VECTOR (N-1 downto 0);
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           ce : in STD_LOGIC;
           q : out STD_LOGIC_VECTOR (N-1 downto 0));
end component;


signal x : STD_LOGIC_VECTOR (M-1 downto 0);

begin
    
    SH_REG:
       for i in 0 to M/N-1 generate
          begin
          
            first_reg:if i=0 generate
            begin
                 r : reg_N generic map (N=>N) port map (d=>serial_in, clk=>clk, rst_n=>rst_n, ce=>ce, q=>x(N-1 downto 0));
            end generate;
            
            other_regs: if i>0 generate
            begin
                 r : reg_N generic map (N=>N) port map (d=>x(i*N-1 downto (i-1)*N), clk=>clk, rst_n=>rst_n, ce=>ce, q=>x((i+1)*N-1 downto i*N));
            end generate;
            
       end generate;
       
       
   parallel_out<=x;
       
end Structural;
