module shift_nb (
    input  clk,
    input  d,
    output reg q1,
    output reg q2
);
    always @(posedge clk) begin
        q1 <= d;
        q2 <= q1;
    end
endmodule

module shift_bl (
    input  clk,
    input  d,
    output reg q1,
    output reg q2
);
    always @(posedge clk) begin
        q1 = d;
        q2 = q1;
    end
endmodule

module shift_bl_rev (
    input  clk,
    input  d,
    output reg q1,
    output reg q2
);
    always @(posedge clk) begin
        q2 = q1;
        q1 = d;
    end
endmodule
