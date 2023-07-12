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
--generic(in_num_pow2: integer:=8; -- number of inputs = 2**in_num_pow2 =256
--        weight_number: integer:=18752;--256*64+ 64*32+ 32*10= 16384+2048+320=18752      64 - 32 - 10 
--        layer_number: integer:=3
--       );
Port (
       nn_parameters : in std_logic_vector(1 downto 0);
       inputs : in std_logic_vector(127 downto 0);
       fifo_w_ce: in std_logic;
       fifo_beta_shift_ce: in std_logic;
       fifo_minus_teta_ce: in std_logic;
       fifo_BN_factor_ce: in std_logic;
       fifo_BN_addend_ce: in std_logic;
       fifo_inputs_ce: in std_logic;
              
       clk : in STD_LOGIC;
       rst_n : in STD_LOGIC; -- active low reset
       ce : in STD_LOGIC;
       outputs : out std_logic_vector(9 downto 0)

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


component SIPO is
    Generic (N : integer := 4;
             M: integer := 64);
    Port ( serial_in : in STD_LOGIC_VECTOR(N-1 downto 0);
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           ce : in STD_LOGIC;
           parallel_out : out STD_LOGIC_VECTOR (M-1 downto 0));
end component;

signal x :  std_logic_vector((2**8)-1 downto 0);-- std_logic_vector((2**in_num_pow2)-1 downto 0);
signal w :  std_logic_vector(18752-1 downto 0);--std_logic_vector(weight_number-1 downto 0);
signal beta_shift:  std_logic_vector (3*3-1 downto 0);--std_logic_vector (3*layer_number-1 downto 0);
signal minus_teta  :  std_logic_vector((8+2)*3-1 downto 0);--std_logic_vector((in_num_pow2+2)*layer_number-1 downto 0);
signal BN_factor:  std_logic_vector(4*106-1 downto 0);
signal BN_addend:  std_logic_vector(966-1 downto 0);
signal spike_out:  std_logic_vector(10-1 downto 0);
signal beta_shift_SIPO_out:  std_logic_vector(10-1 downto 0);


begin

neural_network_uut: neural_network
generic map(8, 18752, 3 )
port map(
x => x, 
w  => w, 
beta_shift => beta_shift, 
minus_teta  => minus_teta, 
BN_factor => BN_factor, 
BN_addend => BN_addend, 
clk  => clk, 
rst_n  => rst_n, 
ce  => ce, 
spike_out => spike_out
);
--Port map( x,w ,beta_shift, minus_teta , BN_factor, BN_addend,clk , rst_n ,ce ,spike_out ); 

----------SIPOs------------------------------------------------------
-- SIPOs for weights
SIPO_w: SIPO Generic map (N => 2, M=> 18752)
    Port map ( serial_in=> nn_parameters,clk => clk, rst_n => rst_n, ce => FIFO_w_ce, parallel_out => w);
-- SIPOs for beta_shifts
SIPO_beta_shift: SIPO Generic map (N => 2, M=> 10) --(3*layer_number-1 downto 0);
    Port map ( serial_in=> nn_parameters,clk => clk, rst_n => rst_n, ce => FIFO_beta_shift_ce, parallel_out => beta_shift_SIPO_out);
    
beta_shift<=beta_shift_SIPO_out(8 downto 0);
-- SIPOs for minus_teta
SIPO_minus_teta: SIPO Generic map (N => 2, M=> 30) --((in_num_pow2+2)*layer_number-1 downto 0); 10*3
    Port map ( serial_in=> nn_parameters,clk => clk, rst_n => rst_n, ce => FIFO_minus_teta_ce, parallel_out => minus_teta);
-- SIPOs for BN_factor
SIPO_BN_factor: SIPO Generic map (N => 2, M=> 4*106)
    Port map ( serial_in=> nn_parameters,clk => clk, rst_n => rst_n, ce => FIFO_BN_factor_ce, parallel_out => BN_factor);
 -- SIPOs for BN_addend
SIPO_BN_addend: SIPO Generic map (N => 2, M=> 966) 
    Port map ( serial_in=> nn_parameters,clk => clk, rst_n => rst_n, ce => FIFO_BN_addend_ce, parallel_out => BN_addend);
SIPO_inputs: SIPO Generic map (N => 128, M=> 256) 
    Port map ( serial_in=> inputs, clk => clk, rst_n => rst_n, ce => FIFO_inputs_ce, parallel_out => x);
    
outputs<= spike_out;

end Behavioral;
