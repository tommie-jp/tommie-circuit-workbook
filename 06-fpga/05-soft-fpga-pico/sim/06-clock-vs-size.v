// N 本の 32 ビットのカウンタを並べ、全部の XOR を出す (回路の規模を N で変える)
module many #(
    parameter N = 16
) (
    input         clk,
    input         rst,
    output [31:0] sum
);
    reg [31:0] r [0:N-1];
    reg [31:0] x;
    integer i;

    always @(posedge clk)
        for (i = 0; i < N; i = i + 1)
            if (rst) r[i] <= 32'd0;
            else     r[i] <= r[i] + i[31:0] + 32'd1;

    always @(*) begin
        x = 32'd0;
        for (i = 0; i < N; i = i + 1) x = x ^ r[i];
    end

    assign sum = x;
endmodule
