// tb_td4x.v  td4x の試験 (11-5)
//  1. 5+4+3+2+1 のプログラム: OUT = 15、止まるまでのクロック数
//  2. 比べるプログラム: IN = 0〜15 で、OUT = (IN >= 5)
//  3. 両方にある 13 命令 (定義のある 12 と、TD4.v でも OUT A に動く 1000) の乱数プログラムで、
//     td4x と td4_xrom (11-4。5-8 の TD4.v と同じ動き) を比べる
`timescale 1us/1ns
module tb_td4x;
    reg        clock = 0;
    reg        reset_n = 1;
    reg  [3:0] in_port = 0;
    reg  [7:0] rom [0:15];
    integer    seed = 1;
    integer    n, c, bad, ng, rnd, clocks;
    reg  [3:0] shared [0:12];

    wire [3:0] pc_x, out_x, pc_r, out_r;
    wire       c_x, z_x;
    td4x     ux (.clock(clock), .reset_n(reset_n), .in_port(in_port), .op(rom[pc_x]),
                 .pc_out(pc_x), .out_port(out_x), .flag_c(c_x), .flag_z(z_x));
    td4_xrom ur (.clock(clock), .reset_n(reset_n), .in_port(in_port), .op(rom[pc_r]),
                 .pc_out(pc_r), .out_port(out_r));

    wire [3:0] pc_s, out_s, pc_m, out_m;
    wire [7:0] op_s, op_m;
    wire       c_s, z_s, c_m, z_m;
    td4x_rom #(.ROMFILE("05-td4x-sum.hex")) us (.clock(clock), .reset_n(reset_n), .in_port(in_port),
        .pc_out(pc_s), .op(op_s), .out_port(out_s), .flag_c(c_s), .flag_z(z_s));
    td4x_rom #(.ROMFILE("05-td4x-cmp.hex")) um (.clock(clock), .reset_n(reset_n), .in_port(in_port),
        .pc_out(pc_m), .op(op_m), .out_port(out_m), .flag_c(c_m), .flag_z(z_m));

    task tick;
        begin
            clock = 1; #5;
            clock = 0; #5;
        end
    endtask

    task do_reset;
        begin
            reset_n = 0; #5; reset_n = 1; #5;
        end
    endtask

    initial begin
        shared[0] = 4'h0; shared[1] = 4'h1; shared[2]  = 4'h2; shared[3]  = 4'h3;
        shared[4] = 4'h4; shared[5] = 4'h5; shared[6]  = 4'h6; shared[7]  = 4'h7;
        shared[8] = 4'h8; shared[9] = 4'h9; shared[10] = 4'hB; shared[11] = 4'hE;
        shared[12] = 4'hF;
        ng = 0;

        // ---- 1. 5+4+3+2+1 (+vcd を付けると、ここだけ波形を残す)
        if ($test$plusargs("vcd")) begin
            $dumpfile("td4x_sum.vcd");
            $dumpvars(0, us);
        end
        do_reset;
        clocks = 0;
        while (pc_s != 4'd7 && clocks < 100) begin tick; clocks = clocks + 1; end
        $display("1. 5+4+3+2+1: OUT = %0d、7 番地 (JMP 7) に着くまで %0d クロック", out_s, clocks);
        tick; tick;                  // 止まった後も OUT が変わらないことを波形に残す
        $dumpoff;
        if (out_s != 4'd15) ng = ng + 1;

        // ---- 2. IN と 5 を比べる
        bad = 0;
        for (n = 0; n < 16; n = n + 1) begin
            in_port = n[3:0];
            #1;
            do_reset;
            for (c = 0; c < 6; c = c + 1) tick;      // 0〜3 番地 + OUT の 5 命令 (余り 1)
            if (out_m !== ((n >= 5) ? 4'd1 : 4'd0)) bad = bad + 1;
        end
        $display("2. IN = 0〜15 と 5 を比べる: 違った数 %0d / 16", bad);
        if (bad != 0) ng = ng + 1;

        // ---- 3. 13 命令の乱数プログラム 500 本 x 64 クロック
        bad = 0;
        for (n = 0; n < 500; n = n + 1) begin
            for (c = 0; c < 16; c = c + 1) begin
                rnd = $random(seed);
                rom[c] = {shared[((rnd >>> 8) & 32'h00ff_ffff) % 13], rnd[3:0]};
            end
            do_reset;
            for (c = 0; c < 64; c = c + 1) begin
                rnd = $random(seed);
                in_port = rnd[3:0];
                #1;                      // 立ち上がりと同じ時刻に入力を変えない (競合を避ける)
                tick;
                if ({pc_x, out_x, ux.reg_a, ux.reg_b, c_x} !==
                    {pc_r, out_r, ur.reg_a, ur.reg_b, ~ur.cflag}) bad = bad + 1;
            end
        end
        $display("3. 13 命令の乱数プログラム 500 本 x 64 クロック: td4x と TD4 の不一致 %0d クロック", bad);
        if (bad != 0) ng = ng + 1;

        if (ng == 0) $display("PASS");
        else         $display("FAIL: %0d 件", ng);
        $finish;
    end
endmodule
