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


module neuron #(parameter n_stage = 2) (
    input wire [((2**n_stage)-1):0] w,
    input wire [((2**n_stage)-1):0] x,
    input wire [2:0] shift,
    input wire [(n_stage+1):0] previus_u,
    input wire [(n_stage+1):0] minus_teta,
    input wire was_spike,
    output wire [(n_stage+1):0] u_out,
    output wire is_spike
);

    wire [(n_stage+1):0] y_out;
    wire [(n_stage+1):0] beta_u;
    wire [(n_stage+1):0] u_out_temp;

    mulplier_accumulator #(n_stage) multiplier_accumulator_uut (
        .w(w),
        .x(x),
        .y_out(y_out)
    );
     // --    beta |  shift   -- gamma=1-beta
     // --  1      |    0
     // -- 0.5     |    1
     // -- 0.75    |    2
     // -- 0.875   |    3
     // -- 0.9375  |    4
     // -- 0.96875 |    5
     // -- 0.98438 |    6
     // -- 0.99219 |    7
    decay_potential #(n_stage) decay_potential_uut (
        .u(previus_u),
        .shift(shift),
        .beta_u(beta_u)
    );

    mem_potential_acc #(n_stage) mem_potential_acc_uut (
        .beta_u(beta_u),
        .sum_wx(y_out),
        .minus_teta(minus_teta),
        .was_spike(was_spike),
        .u_out(u_out_temp)
    );

    spike_generator #(n_stage) spike_generator_uut (
        .u(u_out_temp),
        .minus_teta(minus_teta),
        .is_spike(is_spike)
    );

    assign u_out = u_out_temp;

endmodule
