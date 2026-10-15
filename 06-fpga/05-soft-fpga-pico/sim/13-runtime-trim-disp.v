module p_disp (
    input        clk,
    input        rst,
    output [3:0] count
);
    reg [3:0] r;
    assign count = r;
    always @(posedge clk) begin
        if (rst) r <= 4'd0;
        else     r <= r + 4'd1;
        if (r == 4'd9) begin
            $display("count reached %0d", r);
            $finish;
        end
    end
endmodule
