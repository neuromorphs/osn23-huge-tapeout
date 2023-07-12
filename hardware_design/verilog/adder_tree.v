module adder_tree
#(
    parameter   n_stage = 5     // Minumum is 1 stage
)
(
    input   [(2**(n_stage+1)-1):0]  wx,
    output  [(n_stage+1):0]         y_out
);

    genvar i, j;
    generate
    // Generate connections
    for (i = 0; i < n_stage; i = i+1) begin : connection
        wire [(i+2):0] sum [(2**(n_stage-1-i)-1):0]; // partial sum
    end

    // Stage 1
    for (j = 0; j < 2**(n_stage-1); j = j+1) begin : first_stage
        nbit_adder_with_sign_extend #(2) adder (
            .A(wx[(4*j+1):(4*j+0)]),
            .B(wx[(4*j+3):(4*j+2)]),
            .S(connection[0].sum[j])
        );
    end

    // Remaining stages
    for (i = 1; i < n_stage; i = i+1) begin : stage_loop
        for (j = 0; j < 2**(n_stage-1-i); j = j+1) begin : stage
            nbit_adder_with_sign_extend #(i+2) adder (
                .A(connection[i-1].sum[2*j+0]),
                .B(connection[i-1].sum[2*j+1]),
                .S(connection[i].sum[j])
            );
        end
    end

    assign y_out = connection[n_stage-1].sum[0];
    endgenerate

endmodule
