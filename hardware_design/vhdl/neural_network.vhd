----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/10/2023 11:24:44 PM
-- Design Name: 
-- Module Name: neural_network - Behavioral
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

entity neural_network is
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
end neural_network;

architecture Behavioral of neural_network is

component layer is
generic(n_stage: integer:=8; -- number of inputs = 2**n_stage
        neuron_num: integer:=64);
Port ( x : in std_logic_vector((2**n_stage)-1 downto 0);
       w : in std_logic_vector(neuron_num*(2**n_stage)-1 downto 0);
       beta_shift: in std_logic_vector (2 downto 0);
       minus_teta  : in std_logic_vector(n_stage+1 downto 0);
       BN_factor: in std_logic_vector(4*(neuron_num)-1 downto 0);--(2**n_stage)*(3 downto 0);
       BN_addend: in std_logic_vector((n_stage+2)*(neuron_num)-1 downto 0); --n_stage+1 downto 0
       clk : in STD_LOGIC;
       rst_n : in STD_LOGIC; -- active low reset
       ce : in STD_LOGIC;
       spike_out: out std_logic_vector(neuron_num-1 downto 0)
       ); 
end component;

signal spike_out_first_layer: std_logic_vector(63 downto 0);

signal spike_out_second_layer: std_logic_vector(31 downto 0);
begin

first_layer: layer generic map(n_stage=> in_num_pow2,
       neuron_num=> 64)
       Port map( x => x,
       w => w(16384-1 downto 0),--(2**neuron_num_pow2)*(2**n_stage)=256*64
       beta_shift=> beta_shift(2 downto 0),
       minus_teta => minus_teta(in_num_pow2+1 downto 0),
       BN_factor=> BN_factor(4*64-1 downto 0),
       BN_addend=> BN_addend((in_num_pow2+2)*64-1 downto 0),
       clk => clk,
       rst_n => rst_n,
       ce => ce,
       spike_out=> spike_out_first_layer
       );
       
       
second_layer: layer generic map(n_stage=> 6,
       neuron_num=> 32)
       Port map( x => spike_out_first_layer,
       w => w(16384+2048-1 downto 16384),--(2**neuron_num_pow2)*(2**n_stage)=64*32
       beta_shift=> beta_shift(5 downto 3),
       minus_teta => minus_teta(14 downto 7),
       BN_factor=> BN_factor(4*(64+32)-1 downto 4*64),
       BN_addend=> BN_addend((6+2)*(64+32)-1 downto (6+2)*64),
       clk => clk,
       rst_n => rst_n,
       ce => ce,
       spike_out=> spike_out_second_layer
       );

final_layer: layer generic map(n_stage=> 5,
       neuron_num=> 10)
       Port map( x => spike_out_second_layer,
       w => w(16384+2048+320-1 downto 16384+2048),--(2**neuron_num_pow2)*(2**n_stage)=32*10
       beta_shift=> beta_shift(8 downto 6),
       minus_teta => minus_teta(21 downto 15),
       BN_factor=> BN_factor(4*(64+32+10)-1 downto 4*(64+32)),
       BN_addend=> BN_addend((5+2)*(64+32+10)-1 downto (5+2)*(64+32)),
       clk => clk,
       rst_n => rst_n,
       ce => ce,
       spike_out=> spike_out
       );
       
end Behavioral;
