`timescale 1ns / 1ps
// (1) Pico 2 の設定 (13 µs・4800 bps): 4800 bps ちょうどで送る送り手 (AD3 の Protocol の代わり) から 'A' を送り、
//     読んだ時刻と valid の時刻を書く。続けて 0x00〜0xFF を送って突き合わせる
// (2) 7-1 の uart_tx から uart_rx へつなぎ、0x00〜0xFF を突き合わせる
// (3) FPGA の設定 (27 MHz・9600 bps): 16 倍の刻みを 176 クロックの分周で作る。0x00〜0xFF を突き合わせる
module tb_rx;
    // ---- (1)(2) 13 µs のクロック
    reg clk;
    initial begin
        clk = 1'b0;
        forever #6500 clk = ~clk;
    end
    reg rst;

    reg        line;                 // 送り手の線
    wire [7:0] d1;
    wire       v1, e1, s1;
    uart_rx dut1 (.clk(clk), .rst(rst), .rxd(line),
                  .data(d1), .valid(v1), .frame_err(e1), .sample(s1));

    reg  [7:0] tdat;
    reg        tstart;
    wire       txd, tbusy;
    wire [7:0] d2;
    wire       v2, e2, s2;
    uart_tx dut_tx (.clk(clk), .rst(rst), .data(tdat), .start(tstart), .txd(txd), .busy(tbusy));
    uart_rx dut2 (.clk(clk), .rst(rst), .rxd(txd),
                  .data(d2), .valid(v2), .frame_err(e2), .sample(s2));

    // ---- (3) 27 MHz のクロック
    reg clk27;
    initial begin
        clk27 = 1'b0;
        forever #18.518 clk27 = ~clk27;
    end
    reg        line27;
    wire [7:0] d3;
    wire       v3, e3, s3;
    uart_rx #(.CLK_HZ(27_000_000), .BAUD(9600)) dut3 (.clk(clk27), .rst(rst), .rxd(line27),
                  .data(d3), .valid(v3), .frame_err(e3), .sample(s3));

    // 送り手: 4800 bps (line) と 9600 bps (line27) で 8N1 を送る
    localparam real BIT4800 = 1.0e9 / 4800.0;
    localparam real BIT9600 = 1.0e9 / 9600.0;
    task automatic send4800(input [7:0] b);
        integer k;
        begin
            line = 1'b0; #(BIT4800);
            for (k = 0; k < 8; k = k + 1) begin line = b[k]; #(BIT4800); end
            line = 1'b1; #(BIT4800);
        end
    endtask
    task automatic send9600(input [7:0] b);
        integer k;
        begin
            line27 = 1'b0; #(BIT9600);
            for (k = 0; k < 8; k = k + 1) begin line27 = b[k]; #(BIT9600); end
            line27 = 1'b1; #(BIT9600);
        end
    endtask

    // 受けた字を数えて突き合わせる
    integer n1 = 0, n2 = 0, n3 = 0, err = 0;
    reg     trace = 1'b0;
    realtime tstart_edge;
    // 出力はクロックの立ち下がりで見る (立ち上がりで変わった値を、半周期後に読む)
    always @(negedge clk) begin
        if (v1) begin
            if (trace) $display("(1) valid    from start + %8.1f us, data = %02h '%c'", ($realtime - 6500 - tstart_edge) / 1000.0, d1, d1);
            else if (d1 !== n1[7:0]) begin err = err + 1; $display("(1) NG %02h %02h", n1[7:0], d1); end
            if (!trace) n1 = n1 + 1;
        end
        if (s1 && trace) $display("(1) sample from start + %8.1f us, shreg = %b", ($realtime - 6500 - tstart_edge) / 1000.0, dut1.shreg);
        if (v2) begin
            if (d2 !== n2[7:0]) begin err = err + 1; $display("(2) NG %02h %02h", n2[7:0], d2); end
            n2 = n2 + 1;
        end
        if (e1 || e2) begin err = err + 1; $display("frame error"); end
    end
    always @(negedge clk27) begin
        if (v3) begin
            if (d3 !== n3[7:0]) begin err = err + 1; $display("(3) NG %02h %02h", n3[7:0], d3); end
            n3 = n3 + 1;
        end
        if (e3) begin err = err + 1; $display("frame error (3)"); end
    end

    integer i;
    initial begin
        rst = 1'b1; line = 1'b1; line27 = 1'b1; tstart = 1'b0; tdat = 8'h00;
        #30000 rst = 1'b0;
        #100000;
        // (1) 'A' を 1 字、読む時刻を書く
        trace = 1'b1;
        tstart_edge = $realtime;
        send4800("A");
        #500000;
        trace = 1'b0;
        fork
            // (1) 0x00〜0xFF (字の間をあけずに続けて)
            for (i = 0; i < 256; i = i + 1) send4800(i[7:0]);
            // (2) uart_tx → uart_rx
            begin : loop2
                integer j;
                for (j = 0; j < 256; j = j + 1) begin
                    @(negedge clk);
                    while (tbusy) @(negedge clk);
                    tdat = j[7:0]; tstart = 1'b1;
                    @(negedge clk); tstart = 1'b0;
                    @(negedge clk);
                end
            end
            // (3) 27 MHz・9600 bps
            begin : loop3
                integer m;
                for (m = 0; m < 256; m = m + 1) send9600(m[7:0]);
            end
        join
        #5000000;
        $display("(1) 4800 bps sender -> rx @13us : %0d bytes", n1);
        $display("(2) uart_tx -> uart_rx @13us    : %0d bytes", n2);
        $display("(3) 9600 bps sender -> rx @27MHz: %0d bytes", n3);
        $display("errors %0d", err);
        if (n1 == 256 && n2 == 256 && n3 == 256 && err == 0) $display("PASS");
        else                                                 $display("FAIL");
        $finish;
    end
endmodule
