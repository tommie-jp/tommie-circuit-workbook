// tb_rom.v  番地を 0 から 15 まで進め、読んだ語を期待値と比べる
module tb_rom;
    reg  [3:0] addr;
    wire [7:0] data;
    reg  [7:0] expected [0:15];
    integer i;
    integer ng;

    rom16x8 #(.INIT("prog.hex")) u (.addr(addr), .data(data));

    initial begin
        // 期待値は Soft-FPGA-TD4 の TD4.v に書いてある ROM の中身
        expected[0] = 8'hb3; expected[1] = 8'hb6; expected[2]  = 8'hbc; expected[3]  = 8'hb8;
        expected[4] = 8'hb8; expected[5] = 8'hbc; expected[6]  = 8'hb6; expected[7]  = 8'hb3;
        expected[8] = 8'hb1; expected[9] = 8'hf0; expected[10] = 8'h00; expected[11] = 8'h00;
        expected[12] = 8'h00; expected[13] = 8'h00; expected[14] = 8'h00; expected[15] = 8'h00;

        $dumpfile("rom.vcd");
        $dumpvars(0, tb_rom);
        ng = 0;
        for (i = 0; i < 16; i = i + 1) begin
            addr = i[3:0];
            #1;                                   // 1 us ごとに番地を進める
            $display("番地 %h: %h (%b)", addr, data, data);
            if (data !== expected[i]) ng = ng + 1;
        end
        if (ng == 0) $display("PASS: 16 語とも期待値と同じ");
        else         $display("FAIL: %0d 語が違う", ng);
        $finish;
    end
endmodule
