----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/10/2023 04:44:58 PM
-- Design Name: 
-- Module Name: neuron_struct - Behavioral
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

entity neuron_struct is
generic(n_stage: integer:=8);
Port ( w,x : in std_logic_vector((2**n_stage)-1 downto 0);
       shift: in std_logic_vector (2 downto 0);
       minus_teta  : in std_logic_vector(n_stage+1 downto 0);
       BN_factor: in std_logic_vector(3 downto 0);
       BN_addend: in std_logic_vector(n_stage+1 downto 0);
       clk : in STD_LOGIC;
       rst_n : in STD_LOGIC; -- active low reset
       ce : in STD_LOGIC;
       spike_out: out std_logic
       ); 
end neuron_struct;

architecture Behavioral of neuron_struct is


component neuron is
generic(n_stage: integer:=2);
Port ( w,x : in std_logic_vector((2**n_stage)-1 downto 0);
       shift: in std_logic_vector (2 downto 0);
       previus_u,minus_teta  : in std_logic_vector(n_stage+1 downto 0); 
       was_spike: in std_logic;
       BN_factor: in std_logic_vector(3 downto 0);
       BN_addend: in std_logic_vector(n_stage+1 downto 0);
       u_out : out std_logic_vector(n_stage+1 downto 0);
       is_spike: out std_logic
       ); 
end component;


component reg_N is
    Generic (N : integer := 16);
    Port ( d : in STD_LOGIC_VECTOR (N-1 downto 0);
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC; -- active low reset
           ce : in STD_LOGIC;
           q : out STD_LOGIC_VECTOR (N-1 downto 0));
end component;

component reg_1b is
    Port ( d : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC; -- active low reset
           ce : in STD_LOGIC;
           q : out STD_LOGIC);
end component;


signal BN_u_in, BN_u_out :  std_logic_vector(n_stage+1 downto 0);
signal is_spike, was_spike:  std_logic;

signal previus_u, u_out : std_logic_vector(n_stage+1 downto 0); 

begin

neuron_uut: neuron generic map (n_stage)
Port map ( w,x,shift,previus_u,minus_teta,was_spike,BN_factor,BN_addend,u_out,is_spike); 

is_spike_FF: reg_1b Port map( d => is_spike,
           clk => clk, 
           rst_n => rst_n,
           ce => ce,
           q =>was_spike);
           
pot_membrane_FF: reg_N generic map(n_stage+2)
            Port map( d => u_out,
            clk => clk, 
            rst_n => rst_n,
            ce => ce,
            q =>previus_u);    
           



spike_out <= was_spike;
end Behavioral;
