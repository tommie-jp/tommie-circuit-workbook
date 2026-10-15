// tb_td4_74.v  IC の模型 (td4_74) と TD4.v (5-8) を同じプログラムで並べて走らせる
//  1. 遅れ 0 の模型と TD4.v を、定義のある 12 命令だけの乱数のプログラムで比べる (全部一致するはず)
//  2. 定義の無い 4 命令 (1000・1010・1100・1101) を混ぜて、違いが出るかを数える (出るはず)
//  3. 遅れを入れた模型を、クロックの周期を縮めながら比べ、合う最短の周期を探す
// iverilog -g2012 で回す (遅れの # を使うので Verilator ではなく iverilog)
`timescale 1ns/1ps
module tb_td4_74;
    reg        clock = 0;
    reg        reset_n = 1;   // 0 に下げた時 (negedge) に非同期リセットが効く
    reg  [3:0] in_port = 0;
    wire [3:0] pc_r, out_r, pc_z, out_z, pc_t, out_t, pc_u, out_u;
    wire [7:0] op_r, op_z, op_t, op_u;
    wire [3:0] alu_unused;

    TD4 ref_cpu (.clock(clock), .reset_n(reset_n), .in_port(in_port),
                 .pc_out(pc_r), .op(op_r), .out_port(out_r), .alu_data(alu_unused));
    td4_74 #(.TIMED(0)) z_cpu (.clock(clock), .reset_n(reset_n), .in_port(in_port),
                 .pc_out(pc_z), .op(op_z), .out_port(out_z));
    td4_74 #(.TIMED(1)) t_cpu (.clock(clock), .reset_n(reset_n), .in_port(in_port),
                 .pc_out(pc_t), .op(op_t), .out_port(out_t));
    // ROM のダイオードと引き上げ抵抗の遅れを 140 ns と仮定した物 (10 kΩ × 20 pF × 0.69)
    td4_74 #(.TIMED(1), .T_ROM_RC(140.0)) u_cpu (.clock(clock), .reset_n(reset_n), .in_port(in_port),
                 .pc_out(pc_u), .op(op_u), .out_port(out_u));

    // ROM を外に出した td4_xrom (合成で数える物) も、ROM を tb に置いて並べる
    reg  [7:0] rom_c [0:15];
    wire [3:0] pc_c, out_c;
    td4_xrom c_cpu (.clock(clock), .reset_n(reset_n), .in_port(in_port),
                    .op(rom_c[pc_c]), .pc_out(pc_c), .out_port(out_c));

    integer seed;
    integer k, n, p, cyc, bad, total_bad, progs_bad, ng;
    real    period;
    reg [3:0] defined [0:11];
    reg [7:0] prog [0:15];

    // 状態 (PC・OUT・A・B・桁上げ無し) を 1 つの数にまとめる
    function [16:0] st_ref(input dummy);
        st_ref = {pc_r, out_r, ref_cpu.reg_a, ref_cpu.reg_b, ref_cpu.cflag};
    endfunction
    function [16:0] st_z(input dummy);
        st_z = {pc_z, out_z, z_cpu.reg_a, z_cpu.reg_b, z_cpu.c_n};
    endfunction
    function [16:0] st_c(input dummy);
        st_c = {pc_c, out_c, c_cpu.reg_a, c_cpu.reg_b, c_cpu.cflag};
    endfunction
    function [16:0] st_t(input dummy);
        st_t = {pc_t, out_t, t_cpu.reg_a, t_cpu.reg_b, t_cpu.c_n};
    endfunction
    function [16:0] st_u(input dummy);
        st_u = {pc_u, out_u, u_cpu.reg_a, u_cpu.reg_b, u_cpu.c_n};
    endfunction

    task load_rom;
        integer a;
        for (a = 0; a < 16; a = a + 1) begin
            ref_cpu.rom[a] = prog[a];
            z_cpu.rom[a]   = prog[a];
            t_cpu.rom[a]   = prog[a];
            u_cpu.rom[a]   = prog[a];
            rom_c[a]       = prog[a];
        end
    endtask

    // 乱数のプログラムを作る。extra が 16 未満なら、その命令を 1/4 の割合で混ぜる
    task make_prog(input integer extra);
        integer a, r;
        for (a = 0; a < 16; a = a + 1) begin
            r = $random(seed);
            if (extra < 16 && (r & 3) == 0)
                prog[a] = {extra[3:0], r[7:4]};
            else
                prog[a] = {defined[((r >>> 8) & 32'h00ff_ffff) % 12], r[7:4]};
        end
    endtask

    // which: 0 = 遅れ 0 の模型、1 = 遅れ入り、2 = 遅れ入り + ROM の RC、3 = td4_xrom。不一致のクロック数を返す
    task run_prog(input integer which, input integer cycles, output integer nbad);
        integer c, rnd;
        reg [16:0] sr, sd;
        begin
            nbad = 0;
            clock = 0;
            reset_n = 0;
            load_rom;
            #(period);
            reset_n = 1;
            #(period / 2.0);
            for (c = 0; c < cycles; c = c + 1) begin
                clock = 1;
                #1 rnd = $random(seed);
                in_port = rnd[3:0];
                #(period / 2.0 - 1.0);
                clock = 0;
                #(period / 2.0 - 1.0);
                sr = st_ref(0);
                sd = (which == 0) ? st_z(0) : (which == 1) ? st_t(0) :
                     (which == 2) ? st_u(0) : st_c(0);
                if (sr !== sd || ^sr === 1'bx) nbad = nbad + 1;   // x が残っていても不一致に数える
                #1;
            end
        end
    endtask

    // その周期で、乱数のプログラム 30 本 × 64 クロックがすべて合うか
    task try_period(input integer which, input real per, output integer ok);
        integer q, nb;
        begin
            period = per;
            seed = 2024;
            ok = 1;
            for (q = 0; q < 30; q = q + 1) begin
                make_prog(16);
                run_prog(which, 64, nb);
                if (nb != 0) ok = 0;
            end
        end
    endtask

    integer ok, min_t, min_u, demo_i;
    initial begin
        defined[0] = 4'h0; defined[1] = 4'h1; defined[2] = 4'h2;  defined[3] = 4'h3;
        defined[4] = 4'h4; defined[5] = 4'h5; defined[6] = 4'h6;  defined[7] = 4'h7;
        defined[8] = 4'h9; defined[9] = 4'hB; defined[10] = 4'hE; defined[11] = 4'hF;
        ng = 0;

        // ---- 1. 定義のある 12 命令だけ: 遅れ 0 の模型と TD4.v
        period = 1000.0;
        seed = 1;
        total_bad = 0;
        for (n = 0; n < 500; n = n + 1) begin
            make_prog(16);
            run_prog(0, 64, bad);
            total_bad = total_bad + bad;
        end
        $display("1. 12 命令の乱数プログラム 500 本 x 64 クロック: 不一致 %0d クロック", total_bad);
        if (total_bad != 0) ng = ng + 1;
        seed = 1;
        total_bad = 0;
        for (n = 0; n < 500; n = n + 1) begin
            make_prog(16);
            run_prog(3, 64, bad);
            total_bad = total_bad + bad;
        end
        $display("   同じ 500 本で td4_xrom (ROM を外に出した物) と TD4.v: 不一致 %0d クロック", total_bad);
        if (total_bad != 0) ng = ng + 1;

        // ---- 2. 定義の無い命令を混ぜる
        for (k = 0; k < 4; k = k + 1) begin
            p = (k == 0) ? 8 : (k == 1) ? 10 : (k == 2) ? 12 : 13;
            seed = 7 + k;
            progs_bad = 0;
            for (n = 0; n < 200; n = n + 1) begin
                make_prog(p);
                run_prog(0, 64, bad);
                if (bad != 0) progs_bad = progs_bad + 1;
            end
            $display("2. 命令 %b を混ぜた 200 本: 違いが出た本数 %0d", p[3:0], progs_bad);
            // 4 つとも、IC 版ではセレクタの選び方が TD4.v と違うので、違いが出るはず
            if (progs_bad == 0) ng = ng + 1;
        end

        // 違いの例: MOV A,3 / MOV B,5 / 1000_0000 / 1010_0010 (IN = 6) / 1101_0001
        prog[0] = 8'b0011_0011; prog[1] = 8'b0111_0101; prog[2] = 8'b1000_0000;
        prog[3] = 8'b1010_0010; prog[4] = 8'b1101_0001;
        for (demo_i = 5; demo_i < 16; demo_i = demo_i + 1) prog[demo_i] = 8'b1011_1111; // OUT 1111
        load_rom;
        period = 1000.0;
        clock = 0; reset_n = 0; in_port = 4'd6;
        #(period); reset_n = 1; #(period / 2.0);
        for (demo_i = 0; demo_i < 5; demo_i = demo_i + 1) begin
            clock = 1; #(period / 2.0); clock = 0; #(period / 2.0);
            $display("   例 %0d 命令目のあと: TD4.v は OUT = %0d・PC = %0d、IC 版は OUT = %0d・PC = %0d",
                     demo_i + 1, out_r, pc_r, out_z, pc_z);
        end

        // ---- 3. 遅れを入れた模型: 合う最短の周期 (300 ns から 1 ns ずつ縮める)
        min_t = 0;
        for (k = 300; k >= 100; k = k - 1) begin
            try_period(1, k, ok);
            if (ok && min_t == 0) min_t = -1;
            if (!ok && min_t == -1) begin min_t = k + 1; k = 0; end
        end
        $display("3. 遅れ入り (ROM の RC なし): 合う最短の周期 %0d ns", min_t);
        min_u = 0;
        for (k = 500; k >= 200; k = k - 1) begin
            try_period(2, k, ok);
            if (ok && min_u == 0) min_u = -1;
            if (!ok && min_u == -1) begin min_u = k + 1; k = 0; end
        end
        $display("   遅れ入り (ROM の RC 140 ns を仮定): 合う最短の周期 %0d ns", min_u);
        if (min_t <= 0 || min_u <= 0) ng = ng + 1;

        if (ng == 0) $display("PASS");
        else         $display("FAIL: %0d 件", ng);
        $finish;
    end
endmodule
