module full_adder (
    input A,
    input B,
    input Cin,
    output S,
    output Cout
);

    // Define internal signals
    wire ha1_S;
    wire ha1_Cout;
    wire ha2_Cout;

    // Instantiate half adders
    half_adder ha1 (
        .A(A),
        .B(B),
        .S(ha1_S),
        .Cout(ha1_Cout)
    );
    half_adder ha2 (
        .A(ha1_S),
        .B(Cin),
        .S(S),
        .Cout(ha2_Cout)
    );

    // Calculate Cout
    assign Cout = ha1_Cout | ha2_Cout;

endmodule
