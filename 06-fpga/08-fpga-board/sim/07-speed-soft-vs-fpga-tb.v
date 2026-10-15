// q3 と q4 が何クロックごとに変わるかを数える
module tb_count;
    reg clk = 0;
    reg rst_n = 0;
    wire q3, q4;
    integer cycles = 0, last3 = 0, last4 = 0, n3 = 0, n4 = 0;
    reg p3 = 0, p4 = 0;

    top_count u (.clk(clk), .rst_n(rst_n), .q3(q3), .q4(q4));

    always #1 clk = ~clk;

    always @(posedge clk) if (rst_n) begin
        cycles <= cycles + 1;
        p3 <= q3;
        p4 <= q4;
        if (q3 !== p3 && n3 < 4) begin $display("q3=%b at clock %0d (%0d clocks)", q3, cycles, cycles - last3); last3 <= cycles; n3 <= n3 + 1; end
        if (q4 !== p4 && n4 < 3) begin $display("q4=%b at clock %0d (%0d clocks)", q4, cycles, cycles - last4); last4 <= cycles; n4 <= n4 + 1; end
    end

    initial begin
        #5 rst_n = 1;
        #200 $finish;
    end
endmodule
