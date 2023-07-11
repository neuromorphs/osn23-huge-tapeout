----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/06/2023 01:50:21 PM
-- Design Name: 
-- Module Name: mem_potential_acc - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- u_out(t) = beta*u(t-1) + sum[w*x(t)] - Sout(t-1)*threshold

entity mem_potential_acc is
generic(n_stage: integer:=6);
Port (
    beta_u,sum_wx, minus_teta  : in std_logic_vector(n_stage+1 downto 0); -- was_spike = 1 if at (t-1) there was a spike, 0 otherwise; minus_teta=-threshold
    was_spike: in std_logic;
    u_out : out std_logic_vector(n_stage+1 downto 0)
     );
end mem_potential_acc;

architecture Behavioral of mem_potential_acc is

component nbit_adder is
generic ( n: integer:=4);
Port (
    A, B: in std_logic_vector(n-1 downto 0);
    S: out std_logic_vector(n downto 0)
 );
end component;

signal s_out_1,s_out_reset : std_logic_vector(n_stage+2 downto 0);

begin

-- Adder1 = beta*u(t-1) + sum[w*x(t)] 
Adder_1:  nbit_adder generic map (n=>n_stage+2)  
                         Port map ( A => beta_u, 
                                    B => sum_wx,
                                    S => s_out_1);
                                    
-- Adder2 = beta*u(t-1) + sum[w*x(t)] + minus_teta -- if there was a spike, reset!
Adder_2:  nbit_adder generic map (n=>n_stage+2)  
                         Port map ( A => s_out_1(n_stage+1 downto 0), 
                                    B => minus_teta,
                                    S => s_out_reset);
                                                                       
                                    
u_out<= s_out_reset(n_stage+1 downto 0) when was_spike='1' else -- if there was a spike, reset!
        s_out_1(n_stage+1 downto 0);                                    

end Behavioral;
