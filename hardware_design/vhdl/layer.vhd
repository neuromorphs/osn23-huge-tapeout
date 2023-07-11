----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/10/2023 10:48:29 PM
-- Design Name: 
-- Module Name: layer - Behavioral
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

entity layer is
generic(n_stage: integer:=8; -- number of inputs = 2**n_stage
        neuron_num: integer:=64);
Port ( x : in std_logic_vector((2**n_stage)-1 downto 0);
       w : in std_logic_vector(neuron_num*(2**n_stage)-1 downto 0);
       beta_shift: in std_logic_vector (2 downto 0);
       minus_teta  : in std_logic_vector(n_stage+1 downto 0);
       BN_factor: in std_logic_vector(4*(2**n_stage)-1 downto 0);--(2**n_stage)*(3 downto 0);
       BN_addend: in std_logic_vector((n_stage+2)*(2**n_stage)-1 downto 0); --n_stage+1 downto 0
       clk : in STD_LOGIC;
       rst_n : in STD_LOGIC; -- active low reset
       ce : in STD_LOGIC;
       spike_out: out std_logic_vector(neuron_num-1 downto 0)
       ); 
end layer;

--generic(n_stage: integer:=8; -- number of inputs = 2**n_stage
--        neuron_num_pow2: integer:=4); -- number of neurons =2**neuron_num_pow2
--Port ( x : in std_logic_vector((2**n_stage)-1 downto 0);
--       w : in std_logic_vector((2**neuron_num_pow2)*(2**n_stage)-1 downto 0);
--       beta_shift: in std_logic_vector (2 downto 0);
--       minus_teta  : in std_logic_vector(n_stage+1 downto 0);
--       BN_factor: in std_logic_vector(4*(2**n_stage)-1 downto 0);--(2**n_stage)*(3 downto 0);
--       BN_addend: in std_logic_vector((n_stage+2)*(2**n_stage)-1 downto 0); --n_stage+1 downto 0
--       clk : in STD_LOGIC;
--       rst_n : in STD_LOGIC; -- active low reset
--       ce : in STD_LOGIC;
--       spike_out: out std_logic_vector((2**neuron_num_pow2)-1 downto 0)
--       ); 
--end layer;

architecture Behavioral of layer is

component neuron_struct is
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
end component;

begin

neurons: for i in neuron_num-1 downto 0 generate
begin
   neuron_i:neuron_struct generic map (n_stage=> n_stage )
            Port map ( w => w ((i+1)*(2**n_stage)-1 downto i*(2**n_stage)),
            x => x,
            shift => beta_shift ,
            minus_teta => minus_teta,
            BN_factor => BN_factor (4*(i+1)-1 downto i*4),
            BN_addend => BN_addend ((i+1)*(n_stage+2)-1 downto i*(n_stage+2)),
            clk  => clk,
            rst_n  => rst_n,
            ce  => ce,
            spike_out => spike_out(i)
       ); 
end generate;


end Behavioral;
