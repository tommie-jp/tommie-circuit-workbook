// ram (256 語 × 8 ビット) に 3 つ書き、読み出しが 1 クロック遅れることを見る
module tb_ram;
    reg        clk = 1'b0;
    reg        we = 1'b0;
    reg  [7:0] addr = 8'd0;
    reg  [7:0] din = 8'd0;
    wire [7:0] dout;

    ram #(.ABITS(8), .WIDTH(8)) dut (.clk(clk), .we(we), .addr(addr), .din(din), .dout(dout));

    always #5 clk = ~clk;

    task step(input w, input [7:0] a, input [7:0] d);
        begin
            we = w; addr = a; din = d;
            @(posedge clk); #1;
            $display("t=%0t  we=%b addr=%h din=%h  dout=%h", $time, w, a, d, dout);
        end
    endtask

    initial begin
        @(posedge clk); #1;
        step(1'b1, 8'h10, 8'hA5);   // 0x10 番地に A5 を書く
        step(1'b1, 8'h11, 8'h3C);
        step(1'b1, 8'h12, 8'h7E);
        step(1'b0, 8'h10, 8'h00);   // 0x10 番地を読む
        step(1'b0, 8'h11, 8'h00);
        step(1'b0, 8'h12, 8'h00);
        step(1'b0, 8'h20, 8'h00);   // 書いていない番地
        $finish;
    end
endmodule
