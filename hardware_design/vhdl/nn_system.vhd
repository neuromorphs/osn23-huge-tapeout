----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/11/2023 02:07:17 PM
-- Design Name: 
-- Module Name: nn_system - Behavioral
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


entity nn_system is
generic(in_num_pow2: integer:=8; -- number of inputs = 2**in_num_pow2 =256
        weight_number: integer:=18752;--256*64+ 64*32+ 32*10= 16384+2048+320=18752      64 - 32 - 10 
        layer_number: integer:=3
       );
Port (
       clk : in STD_LOGIC;
       rst_n : in STD_LOGIC; -- active low reset
       ce : in STD_LOGIC

 );
end nn_system;



architecture Behavioral of nn_system is

component neural_network is
generic(in_num_pow2: integer:=8; -- number of inputs = 2**in_num_pow2
        weight_number: integer:=18752;--256*64+ 64*32+ 32*10= 16384+2048+320=18752      64 - 32 - 10 
        layer_number: integer:=3
       );
Port ( x : in std_logic_vector((2**in_num_pow2)-1 downto 0);
       w : in std_logic_vector(weight_number-1 downto 0);
       beta_shift: in std_logic_vector (3*layer_number-1 downto 0);
       minus_teta  : in std_logic_vector((in_num_pow2+2)*layer_number-1 downto 0);
       BN_factor: in std_logic_vector(4*106-1 downto 0);-- number of neurons=64+32+10= 106
       BN_addend: in std_logic_vector(966-1 downto 0); --10*64+8*32+7*10
       clk : in STD_LOGIC;
       rst_n : in STD_LOGIC; -- active low reset
       ce : in STD_LOGIC;
       spike_out: out std_logic_vector(10-1 downto 0)
       ); 
end component;


signal x :  std_logic_vector((2**in_num_pow2)-1 downto 0);
signal w :  std_logic_vector(weight_number-1 downto 0);
signal beta_shift:  std_logic_vector (3*layer_number-1 downto 0);
signal minus_teta  :  std_logic_vector((in_num_pow2+2)*layer_number-1 downto 0);
signal BN_factor:  std_logic_vector(4*106-1 downto 0);
signal BN_addend:  std_logic_vector(966-1 downto 0);
signal spike_out:  std_logic_vector(10-1 downto 0);


begin

neural_network_uut: neural_network
generic map(in_num_pow2, weight_number, layer_number )
Port map( x,w ,beta_shift, minus_teta , BN_factor, BN_addend,clk , rst_n ,ce ,spike_out ); 

-- SIPOs




end Behavioral;
