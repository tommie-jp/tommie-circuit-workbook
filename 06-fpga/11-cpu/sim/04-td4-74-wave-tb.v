// tb_td4_74_wave.v  遅れを入れた IC の模型で、1 命令の中の信号の落ち着き方を VCD に取る (11-4 の図)
// MOV B,9 / MOV A,2 / ADD A,1 / MOV A,B を、周期 300 ns で回す
`timescale 1ns/1ps
module tb_td4_74_wave;
    reg        clock = 0;
    reg        reset_n = 1;   // 0 に下げた時 (negedge) に非同期リセットが効く
    wire [3:0] pc, out_port;
    wire [7:0] op;
    integer    a;
    td4_74 #(.TIMED(1)) t_cpu (.clock(clock), .reset_n(reset_n), .in_port(4'd0),
                               .pc_out(pc), .op(op), .out_port(out_port));
    initial begin
        t_cpu.rom[0] = 8'b0111_1001;   // MOV B,9
        t_cpu.rom[1] = 8'b0011_0010;   // MOV A,2
        t_cpu.rom[2] = 8'b0000_0001;   // ADD A,1
        t_cpu.rom[3] = 8'b0001_0000;   // MOV A,B
        for (a = 4; a < 16; a = a + 1) t_cpu.rom[a] = 8'b1111_0100;  // JMP 0100
        $dumpfile("td4_74_wave.vcd");
        $dumpvars(0, tb_td4_74_wave);
        #1 reset_n = 0;
        #299 reset_n = 1;
        #150;
        repeat (5) begin clock = 1; #150; clock = 0; #150; end
        $display("A = %0d (9 のはず)", t_cpu.reg_a);
        if (t_cpu.reg_a == 4'd9) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
