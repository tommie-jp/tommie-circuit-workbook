module tb_fig;
    reg clk = 0, rst = 1;
    wire [7:0] seg, seg_b; wire [3:0] dig, dig_b; wire [15:0] value, value_b;
    dyn7seg #(.CLK_HZ(1000), .BLANK(0)) u (.clk(clk), .rst(rst), .seg(seg),   .dig(dig),   .value(value));
    dyn7seg #(.CLK_HZ(1000), .BLANK(1)) b (.clk(clk), .rst(rst), .seg(seg_b), .dig(dig_b), .value(value_b));
    always #1 clk = ~clk;
    integer i;
    reg [19:0] d1, d2, d3, d4, a, f, d1b, d2b, d3b, d4b, ab, fb;
    initial begin
        repeat (3) @(posedge clk); @(negedge clk); rst = 0;
        repeat (215_500) @(negedge clk);
        // DIG1 が光るクロックの 1 つ前から始める (図 3 は -1 ms から)
        while (!(dig == 4'b0001)) @(negedge clk);
        for (i = 0; i < 11; i = i + 1) begin
            d1[i] = dig[3]; d2[i] = dig[2]; d3[i] = dig[1]; d4[i] = dig[0]; a[i] = seg[0]; f[i] = seg[5];
            @(negedge clk);
        end
        $display("value=%h", value);
        $display("DRV1 %b", {d1[0],d1[1],d1[2],d1[3],d1[4],d1[5],d1[6],d1[7],d1[8],d1[9],d1[10]});
        $display("DRV2 %b", {d2[0],d2[1],d2[2],d2[3],d2[4],d2[5],d2[6],d2[7],d2[8],d2[9],d2[10]});
        $display("DRV3 %b", {d3[0],d3[1],d3[2],d3[3],d3[4],d3[5],d3[6],d3[7],d3[8],d3[9],d3[10]});
        $display("DRV4 %b", {d4[0],d4[1],d4[2],d4[3],d4[4],d4[5],d4[6],d4[7],d4[8],d4[9],d4[10]});
        $display("SA   %b", {a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10]});
        $display("SF   %b", {f[0],f[1],f[2],f[3],f[4],f[5],f[6],f[7],f[8],f[9],f[10]});
        // 消す版: DIG1 が光る 1 つ前の 2 クロック分から 20 クロック
        while (!(dig_b == 4'b0001)) @(negedge clk);
        for (i = 0; i < 20; i = i + 1) begin
            d1b[i] = dig_b[3]; d2b[i] = dig_b[2]; d3b[i] = dig_b[1]; d4b[i] = dig_b[0]; ab[i] = seg_b[0]; fb[i] = seg_b[5];
            @(negedge clk);
        end
        $display("value_b=%h", value_b);
        $write("DRV1b "); for (i=0;i<20;i=i+1) $write("%b", d1b[i]); $write("\n");
        $write("DRV2b "); for (i=0;i<20;i=i+1) $write("%b", d2b[i]); $write("\n");
        $write("DRV3b "); for (i=0;i<20;i=i+1) $write("%b", d3b[i]); $write("\n");
        $write("DRV4b "); for (i=0;i<20;i=i+1) $write("%b", d4b[i]); $write("\n");
        $write("SAb   "); for (i=0;i<20;i=i+1) $write("%b", ab[i]); $write("\n");
        $write("SFb   "); for (i=0;i<20;i=i+1) $write("%b", fb[i]); $write("\n");
        $finish;
    end
endmodule
