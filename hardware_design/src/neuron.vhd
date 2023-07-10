----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2023 03:13:06 PM
-- Design Name: 
-- Module Name: neuron - Behavioral
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

entity neuron is
generic(n_stage: integer:=2);
Port ( w,x : in std_logic_vector((2**n_stage)-1 downto 0);
       shift: in std_logic_vector (2 downto 0);
       previus_u,minus_teta  : in std_logic_vector(n_stage+1 downto 0); 
       was_spike: in std_logic;
       u_out : out std_logic_vector(n_stage+1 downto 0);
       is_spike: out std_logic
       ); 
end neuron;

architecture Behavioral of neuron is


component mulplier_accumulator is
    generic(n_stage: integer:=6);
    Port ( w,x : in std_logic_vector((2**n_stage)-1 downto 0);
           y_out : out std_logic_vector(n_stage+1 downto 0)); 
end component;

component decay_potential is
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
end component;


component spike_generator is
generic(n_stage: integer:=6);
Port (
    u,minus_teta  : in std_logic_vector(n_stage+1 downto 0); 
    is_spike: out std_logic
     );
end component;


component mem_potential_acc is
generic(n_stage: integer:=6);
Port (
    beta_u,sum_wx, minus_teta  : in std_logic_vector(n_stage+1 downto 0); -- was_spike = 1 if at (t-1) there was a spike, 0 otherwise; minus_teta=-threshold
    was_spike: in std_logic;
    u_out : out std_logic_vector(n_stage+1 downto 0)
     );
end component;

signal y_out : std_logic_vector(n_stage+1 downto 0);
signal beta_u,u_out_temp: std_logic_vector(n_stage+1 downto 0);


begin

multiplier_accumulator_uut:  mulplier_accumulator
    generic map(n_stage)
    Port map ( w,x,y_out);
    
decay_potential_uut: decay_potential
generic map(n_stage)
Port map (previus_u, shift, beta_u);   

mem_potential_acc_uut: mem_potential_acc
generic map(n_stage)
Port map (
    beta_u,y_out, minus_teta,was_spike,u_out_temp);

spike_generator_uut: spike_generator
generic map(n_stage)
Port map(u_out_temp,minus_teta,is_spike);

u_out<=u_out_temp;

end Behavioral;
