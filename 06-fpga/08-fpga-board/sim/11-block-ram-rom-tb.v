module tb_rom;
    reg clk = 1'b0;
    reg [7:0] addr = 8'd0;
    wire [7:0] dout;
    integer i;
    rom256 dut (.clk(clk), .addr(addr), .dout(dout));
    always #5 clk = ~clk;
    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            addr = (i == 3) ? 8'd255 : i[7:0];
            @(posedge clk); #1;
            $display("addr=%0d dout=%h", addr, dout);
        end
        $finish;
    end
endmodule
