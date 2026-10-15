// td4_74.v  TD4 を 74HC の IC の模型でつないだもの (11-4 の割り付け)
// IC ごとに 1 つのモジュール。TIMED = 1 で、TI のデータシートの 4.5 V・25 °C の
// 最大の遅れ (CL = 50 pF) を入れる。TIMED = 0 なら遅れ 0 (働きだけを比べる)。
`timescale 1ns/1ps

// 74HC161 4 ビットの同期カウンタ。LOAD_n = 0 なら D を、ENP と ENT が 1 なら +1 を取り込む。
// 準備時間 (setup) は、D と LOAD_n を TSU だけ遅らせて真似る (遅れて着いた値は、その分だけ遅く見える)。
module hc161 #(parameter real TCO = 0.0, TSU_D = 0.0, TSU_L = 0.0) (
    input  wire       clk,
    input  wire       clr_n,
    input  wire       load_n,
    input  wire       enp,
    input  wire       ent,
    input  wire [3:0] d,
    output wire [3:0] q
);
    reg  [3:0] r;
    wire [3:0] d_s;
    wire       load_s;
    assign #(TSU_D) d_s    = d;
    assign #(TSU_L) load_s = load_n;
    always @(posedge clk or negedge clr_n)
        if (!clr_n)        r <= 4'd0;
        else if (!load_s)  r <= d_s;
        else if (enp && ent) r <= r + 4'd1;
    assign #(TCO) q = r;
endmodule

// 74HC74 の片方 (D フリップフロップ)。CLR_n で Q = 0、Q_n = 1
module hc74 #(parameter real TCO = 0.0, TSU = 0.0) (
    input  wire clk,
    input  wire clr_n,
    input  wire d,
    output wire q,
    output wire q_n
);
    reg  r;
    wire d_s;
    assign #(TSU) d_s = d;
    always @(posedge clk or negedge clr_n)
        if (!clr_n) r <= 1'b0;
        else        r <= d_s;
    assign #(TCO) q   = r;
    assign #(TCO) q_n = ~r;
endmodule

// 74HC153 の片方 (4 入力のセレクタ 1 つ)。G は L に固定した形
// 選ぶ線 (A・B) から Y までが TS、データ (C0〜C3) から Y までが TD
module hc153_half #(parameter real TS = 0.0, TD = 0.0) (
    input  wire [1:0] s,      // {B, A}
    input  wire [3:0] c,      // C3..C0
    output wire       y
);
    wire [1:0] s_d;
    assign #(TS - TD) s_d = s;
    assign #(TD) y = c[s_d];
endmodule

// 74HC283 4 ビットの全加算器
module hc283 #(parameter real TS = 0.0, TC = 0.0) (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] s,
    output wire       cout
);
    wire [4:0] t = {1'b0, a} + {1'b0, b} + {4'd0, cin};
    assign #(TS) s    = t[3:0];
    assign #(TC) cout = t[4];
endmodule

module td4_74 #(parameter TIMED = 0, parameter real T_ROM_RC = 0.0) (
    input  wire       clock,
    input  wire       reset_n,
    input  wire [3:0] in_port,
    output wire [3:0] pc_out,
    output wire [7:0] op,
    output wire [3:0] out_port
);
    // 4.5 V・25 °C の最大値 [ns] (TI のデータシート、CL = 50 pF)
    localparam real T161_CO = TIMED ? 41.0 : 0.0;  // CLK → Q
    localparam real T161_SD = TIMED ? 30.0 : 0.0;  // D の準備時間
    localparam real T161_SL = TIMED ? 27.0 : 0.0;  // LOAD_n の準備時間
    localparam real T74_CO  = TIMED ? 35.0 : 0.0;  // CLK → Q
    localparam real T74_SU  = TIMED ? 20.0 : 0.0;  // D の準備時間
    localparam real T154    = TIMED ? 35.0 : 0.0;  // 番地 → 出力
    localparam real T540    = TIMED ? 20.0 : 0.0;  // A → Y
    localparam real T32     = TIMED ? 20.0 : 0.0;  // OR
    localparam real T10     = TIMED ? 19.0 : 0.0;  // 3 入力 NAND
    localparam real T153_S  = TIMED ? 30.0 : 0.0;  // 選ぶ線 → Y
    localparam real T153_D  = TIMED ? 28.0 : 0.0;  // データ → Y
    localparam real T283_S  = TIMED ? 42.0 : 0.0;  // A・B → S
    localparam real T283_C  = TIMED ? 39.0 : 0.0;  // A・B → C4

    // ---- ROM: 74HC154 で PC を 16 本に解き、DIP スイッチとダイオードで 8 ビットを作り、74HC540 で受ける
    reg  [7:0] rom [0:15];
    wire [3:0] pc;
    wire [7:0] opcode;
    assign #(T154 + T540 + T_ROM_RC) opcode = rom[pc];
    assign op     = opcode;
    assign pc_out = pc;

    // ---- 命令の解読: 74HC32 (OR 4 つ) と 74HC10 (3 入力 NAND 3 つ)
    wire op7 = opcode[7], op6 = opcode[6], op5 = opcode[5], op4 = opcode[4];
    wire [3:0] im = opcode[3:0];
    wire c_n;                       // 74HC74 の Q_n。1 なら桁上げ無し
    wire op6_n, s0, s1;
    wire lda_n, ldb_n, ldo_n, ldp_n, x;
    assign #(T10) op6_n = ~(op6 & op6 & op6);      // 74HC10 の 1: 反転に使う
    assign #(T10) ldo_n = ~(op7 & op6_n & 1'b1);   // 74HC10 の 2: OUT に書く (10xx)
    assign #(T10) ldp_n = ~(op7 & op6 & x);        // 74HC10 の 3: PC に書く (11xx で、JMP か桁上げ無し)
    assign #(T32) s0    = op4 | op7;               // 74HC32 の 1: セレクタの A
    assign #(T32) lda_n = op7 | op6;               // 74HC32 の 2: A に書く (00xx)
    assign #(T32) ldb_n = op7 | op6_n;             // 74HC32 の 3: B に書く (01xx)
    assign #(T32) x     = op4 | c_n;               // 74HC32 の 4: JMP か、桁上げ無し
    assign s1 = op5;                               // セレクタの B は命令のビット 5 そのまま

    // ---- セレクタ: 74HC153 × 2 (C0 = A、C1 = B、C2 = IN、C3 = 0)
    wire [3:0] reg_a, reg_b, reg_out;
    wire [3:0] sel;
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_sel
            hc153_half #(.TS(T153_S), .TD(T153_D)) u153 (
                .s({s1, s0}), .c({1'b0, in_port[i], reg_b[i], reg_a[i]}), .y(sel[i]));
        end
    endgenerate

    // ---- 加算器: 74HC283 (B に即値、Cin は GND)
    wire [3:0] sum;
    wire       c4;
    hc283 #(.TS(T283_S), .TC(T283_C)) u283 (.a(sel), .b(im), .cin(1'b0), .s(sum), .cout(c4));

    // ---- レジスタ: 74HC161 × 4 と 74HC74
    hc161 #(.TCO(T161_CO), .TSU_D(T161_SD), .TSU_L(T161_SL)) ua (
        .clk(clock), .clr_n(reset_n), .load_n(lda_n), .enp(1'b0), .ent(1'b0), .d(sum), .q(reg_a));
    hc161 #(.TCO(T161_CO), .TSU_D(T161_SD), .TSU_L(T161_SL)) ub (
        .clk(clock), .clr_n(reset_n), .load_n(ldb_n), .enp(1'b0), .ent(1'b0), .d(sum), .q(reg_b));
    hc161 #(.TCO(T161_CO), .TSU_D(T161_SD), .TSU_L(T161_SL)) uo (
        .clk(clock), .clr_n(reset_n), .load_n(ldo_n), .enp(1'b0), .ent(1'b0), .d(sum), .q(reg_out));
    hc161 #(.TCO(T161_CO), .TSU_D(T161_SD), .TSU_L(T161_SL)) up (
        .clk(clock), .clr_n(reset_n), .load_n(ldp_n), .enp(1'b1), .ent(1'b1), .d(sum), .q(pc));
    wire c_q_unused;
    hc74 #(.TCO(T74_CO), .TSU(T74_SU)) uc (
        .clk(clock), .clr_n(reset_n), .d(c4), .q(c_q_unused), .q_n(c_n));

    assign out_port = reg_out;
endmodule
