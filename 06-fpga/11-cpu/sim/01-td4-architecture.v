// 11-1 TD4 を部品に分けて書く。5-8 の TD4.v と同じ働きを、
// レジスタ・PC・データセレクタ・加算器・命令デコーダ・ROM の 6 つのモジュールに分けた。
// soft-fpga の 01-counter に載せるため、最上位は counter (clk・rst・count[7:0]) の形にしてある。
// TD4 の命令の決め方は asfdrwe/simpleTD4 (MIT) の TD4.v に合わせた。
// 1 つのファイルに 9 つのモジュールを置くので、ファイル名とモジュール名の食い違いの警告を切る。
/* verilator lint_off DECLFILENAME */

// 4 ビットのレジスタ。load_n が 0 のときだけ d を取り込む (A・B・OUT に使う)
module td4_reg4 (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       load_n,
    input  wire [3:0] d,
    output reg  [3:0] q
);
    always @(posedge clk or negedge reset_n)
        if (!reset_n)     q <= 4'd0;
        else if (!load_n) q <= d;
endmodule

// プログラムカウンタ。load_n が 0 なら d を取り込み、1 なら 1 を足す
module td4_pc (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       load_n,
    input  wire [3:0] d,
    output reg  [3:0] q
);
    always @(posedge clk or negedge reset_n)
        if (!reset_n)     q <= 4'd0;
        else if (!load_n) q <= d;
        else              q <= q + 4'd1;
endmodule

// キャリーフラグ。負論理で持つ (c_n が 1 なら桁上げ無し)。毎クロック書き直す
module td4_cflag (
    input  wire clk,
    input  wire reset_n,
    input  wire carry,
    output reg  c_n
);
    always @(posedge clk or negedge reset_n)
        if (!reset_n) c_n <= 1'b1;
        else          c_n <= ~carry;
endmodule

// データセレクタ。4 つの入力から 1 つを選ぶ (3 番は 0 につないである)
module td4_sel4 (
    input  wire [1:0] sel,
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [3:0] in_port,
    output wire [3:0] y
);
    assign y = (sel == 2'd0) ? a       :
               (sel == 2'd1) ? b       :
               (sel == 2'd2) ? in_port :
                               4'd0;
endmodule

// 4 ビットの加算器。片方は即値 im
module td4_add4 (
    input  wire [3:0] x,
    input  wire [3:0] im,
    output wire [3:0] s,
    output wire       carry
);
    assign {carry, s} = x + im;
endmodule

// 命令デコーダ。上 4 ビット (オペコード) と c_n から、選ぶ入力と書く先を決める
module td4_decode (
    input  wire [3:0] opc,
    input  wire       c_n,
    output wire [1:0] sel,
    output wire       load_a_n,
    output wire       load_b_n,
    output wire       load_out_n,
    output wire       load_pc_n
);
    wire [1:0] dst = opc[3:2];          // 書く先: 00 A、01 B、10 OUT、11 PC
    assign sel = (dst == 2'b11) ? 2'b11 : opc[1:0];
    assign load_a_n   = ~(dst == 2'b00);
    assign load_b_n   = ~(dst == 2'b01);
    assign load_out_n = ~(dst == 2'b10);
    assign load_pc_n  = ~(dst == 2'b11 && (opc[0] || c_n));   // JMP か、桁上げ無しの JNC
endmodule

// CPU の本体。ROM は外に置く (番地 rom_addr を出し、命令 rom_data を受ける)
module td4_core (
    input  wire       clk,
    input  wire       reset_n,
    input  wire [3:0] in_port,
    output wire [3:0] rom_addr,
    input  wire [7:0] rom_data,
    output wire [3:0] out_port,
    output wire [3:0] reg_a,      // 観測用
    output wire [3:0] reg_b,      // 観測用
    output wire       c_n         // 観測用 (負論理の桁上げ)
);
    wire [1:0] sel;
    wire       load_a_n, load_b_n, load_out_n, load_pc_n;
    wire [3:0] alu_in, alu_out;
    wire       carry;

    td4_decode u_dec (.opc(rom_data[7:4]), .c_n(c_n), .sel(sel),
                      .load_a_n(load_a_n), .load_b_n(load_b_n),
                      .load_out_n(load_out_n), .load_pc_n(load_pc_n));
    td4_sel4   u_sel (.sel(sel), .a(reg_a), .b(reg_b), .in_port(in_port), .y(alu_in));
    td4_add4   u_add (.x(alu_in), .im(rom_data[3:0]), .s(alu_out), .carry(carry));
    td4_reg4   u_a   (.clk(clk), .reset_n(reset_n), .load_n(load_a_n),   .d(alu_out), .q(reg_a));
    td4_reg4   u_b   (.clk(clk), .reset_n(reset_n), .load_n(load_b_n),   .d(alu_out), .q(reg_b));
    td4_reg4   u_out (.clk(clk), .reset_n(reset_n), .load_n(load_out_n), .d(alu_out), .q(out_port));
    td4_pc     u_pc  (.clk(clk), .reset_n(reset_n), .load_n(load_pc_n),  .d(alu_out), .q(rom_addr));
    td4_cflag  u_c   (.clk(clk), .reset_n(reset_n), .carry(carry), .c_n(c_n));
endmodule

// 16 番地 × 8 ビットの ROM。この題のプログラム: A を 1 ずつ増やして OUT に出す
module td4_rom (
    input  wire [3:0] addr,
    output reg  [7:0] data
);
    always @(*)
        case (addr)
            4'h0:    data = 8'b0000_0001;  // ADD A,0001   A <- A + 1
            4'h1:    data = 8'b0100_0000;  // MOV B,A      B <- A
            4'h2:    data = 8'b1001_0000;  // OUT B        OUT <- B
            4'h3:    data = 8'b1111_0000;  // JMP 0000
            default: data = 8'b0000_0000;  // ADD A,0000 (何もしない)
        endcase
endmodule

// soft-fpga の 01-counter に合わせた最上位。count の上 4 ビットが PC、下 4 ビットが OUT
module counter (
    input  wire       clk,
    input  wire       rst,
    output wire [7:0] count
);
    wire [3:0] pc, op_out, a, b;
    wire [7:0] code;
    wire       c_n;

    td4_core u_cpu (.clk(clk), .reset_n(~rst), .in_port(4'd0),
                    .rom_addr(pc), .rom_data(code), .out_port(op_out),
                    .reg_a(a), .reg_b(b), .c_n(c_n));
    td4_rom  u_rom (.addr(pc), .data(code));

    assign count = {pc, op_out};

    wire unused = &{1'b0, a, b, c_n};   // 観測用の出力はここでは使わない
endmodule
