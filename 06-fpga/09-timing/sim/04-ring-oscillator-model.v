// ring_model.v  リングオシレータの「模型」。インバータ 1 段に tpd だけの遅れを # で与える (実物の遅れではない)
module ring_model #(
    parameter N = 5,
    parameter real TPD = 0.5     // 1 段の遅れ (ns)。模型のために決めた値
) (
    input  wire en,
    output wire y
);
    wire [N-1:0] w;

    assign #(TPD) w[0] = ~(w[N-1] & en);

    genvar i;
    generate
        for (i = 1; i < N; i = i + 1) begin : stage
            assign #(TPD) w[i] = ~w[i-1];
        end
    endgenerate

    assign y = w[N-1];
endmodule
