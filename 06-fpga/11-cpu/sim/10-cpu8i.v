// cpu8i.v  cpu8 (11-11) に割り込みを足した物 (11-10)
// 足したもの: 割り込みの入力 irq と受け付けの合図 iack、割り込み許可 ie、戻り番地 epc とフラグの退避、
// 命令 EI (許可)・DI (禁止)・RETI (戻る)。ベクタは 0x02 番地。HLT は割り込みで起きる
module cpu8i (
    input  wire       clk,
    input  wire       rst,        // 同期リセット (1 で PC = 0)
    output reg  [7:0] addr,
    input  wire [7:0] rdata,
    output wire [7:0] wdata,
    output wire       we,
    input  wire [7:0] in_port,
    output reg  [7:0] out_port,
    output reg        out_stb,    // OUT を実行したクロックだけ 1
    output wire       halted,
    output wire [7:0] pc_out,
    output wire [1:0] state_out,
    input  wire       irq,        // 割り込みの要求 (1 の間、要求が続く)
    output reg        iack,       // 割り込みを受け付けたクロックだけ 1
    output wire       ie_out
);
    localparam [1:0] S_FETCH = 2'd0, S_ARG = 2'd1, S_EXEC = 2'd2, S_HALT = 2'd3;
    localparam [7:0] NOP  = 8'h00, LDI  = 8'h01, LD   = 8'h02, ST   = 8'h03,
                     ADD  = 8'h04, SUB  = 8'h05, ADDI = 8'h06, SUBI = 8'h07,
                     AND_ = 8'h08, OR_  = 8'h09, XOR_ = 8'h0A, SHL  = 8'h0B,
                     SHR  = 8'h0C, JMP  = 8'h10, JZ   = 8'h11, JNZ  = 8'h12,
                     JC   = 8'h13, JNC  = 8'h14, IN   = 8'h18, OUT  = 8'h19,
                     HLT  = 8'h1F, EI   = 8'h20, DI   = 8'h21, RETI = 8'h22;
    localparam [7:0] VECTOR = 8'h02;               // 割り込みで飛ぶ番地

    reg [7:0] pc, ir, arg, acc;
    reg       z, c;
    reg [1:0] state;
    reg       ie;                                  // 割り込み許可
    reg [7:0] epc;                                 // 戻り番地
    reg       ez, ec;                              // 退避したフラグ
    reg       hold;                                // EI・RETI の次の 1 命令は受け付けない
    assign halted    = (state == S_HALT);
    assign ie_out    = ie;
    // 受け付けるのは、命令の切れ目 (取り出しの前) か HLT で止まっている間だけ。
    // EI と RETI の次の 1 命令が終わるまでは待つ (RETI の直後にまた入ると、元の処理が 1 命令も進まない)
    wire take_irq = irq && ie && !hold && (state == S_FETCH || state == S_HALT);
    assign pc_out    = pc;
    assign state_out = state;

    // 番地: 取り出しの間は PC、実行の間は引数 (LD・ST・ADD などのメモリの番地)
    always @* addr = (state == S_EXEC) ? arg : pc;
    assign wdata = acc;
    assign we    = (state == S_EXEC) && (ir == ST);

    // 演算: 実行の 1 クロックで、新しい A と桁上げを決める。足し算器は 1 つを足し算と引き算で使い回す
    wire       use_imm = (ir == LDI) || (ir == ADDI) || (ir == SUBI);
    wire       is_sub  = (ir == SUB) || (ir == SUBI);
    wire [7:0] b       = use_imm ? arg : rdata;    // 引数そのものか、メモリの値
    // 引き算は A + (~b) + 1。桁上げは「借りが無い」(A >= b) で 1 になる
    wire [8:0] sum     = {1'b0, acc} + {1'b0, is_sub ? ~b : b} + {8'd0, is_sub};
    reg  [8:0] r;                               // {桁上げ, 結果}
    reg        wr_acc, wr_c;
    always @* begin
        r = {c, acc}; wr_acc = 1'b0; wr_c = 1'b0;
        case (ir)
            LDI, LD:              begin r = {c, b};   wr_acc = 1'b1; end
            ADD, ADDI, SUB, SUBI: begin r = sum;      wr_acc = 1'b1; wr_c = 1'b1; end
            AND_: begin r = {c, acc & b};               wr_acc = 1'b1; end
            OR_:  begin r = {c, acc | b};               wr_acc = 1'b1; end
            XOR_: begin r = {c, acc ^ b};               wr_acc = 1'b1; end
            SHL:  begin r = {acc[7], acc[6:0], 1'b0};   wr_acc = 1'b1; wr_c = 1'b1; end
            SHR:  begin r = {acc[0], 1'b0, acc[7:1]};   wr_acc = 1'b1; wr_c = 1'b1; end
            IN:   begin r = {c, in_port};               wr_acc = 1'b1; end
            default: ;
        endcase
    end

    reg take;                                   // 飛ぶか
    always @* begin
        case (ir)
            JMP:     take = 1'b1;
            JZ:      take = z;
            JNZ:     take = ~z;
            JC:      take = c;
            JNC:     take = ~c;
            default: take = 1'b0;
        endcase
    end

    always @(posedge clk) begin
        out_stb <= 1'b0;
        iack    <= 1'b0;
        if (rst) begin
            pc <= 8'd0; ir <= NOP; arg <= 8'd0; acc <= 8'd0;
            z <= 1'b0; c <= 1'b0; out_port <= 8'd0; state <= S_FETCH;
            ie <= 1'b0; epc <= 8'd0; ez <= 1'b0; ec <= 1'b0; hold <= 1'b0;
        end else if (take_irq) begin
            // 割り込みに入る (1 クロック): 戻り番地とフラグを退避し、許可を落とし、ベクタへ
            epc   <= pc;
            ez    <= z;
            ec    <= c;
            ie    <= 1'b0;
            pc    <= VECTOR;
            iack  <= 1'b1;
            state <= S_FETCH;
        end else begin
            case (state)
                S_FETCH: begin ir  <= rdata; pc <= pc + 8'd1; state <= S_ARG;  end
                S_ARG:   begin arg <= rdata; pc <= pc + 8'd1; state <= S_EXEC; end
                S_EXEC: begin
                    state <= (ir == HLT) ? S_HALT : S_FETCH;
                    hold  <= (ir == EI) || (ir == RETI);   // ほかの命令を 1 つ終えたら下ろす
                    if (wr_acc) begin
                        acc <= r[7:0];
                        z   <= (r[7:0] == 8'd0);    // A に書く命令はゼロフラグも書く
                    end
                    if (wr_c) c <= r[8];
                    if (take) pc <= arg;
                    if (ir == OUT) begin out_port <= acc; out_stb <= 1'b1; end
                    if (ir == EI) ie <= 1'b1;
                    if (ir == DI) ie <= 1'b0;
                    if (ir == RETI) begin             // 戻る: 番地とフラグを戻し、許可を上げる
                        pc <= epc;
                        z  <= ez;
                        c  <= ec;
                        ie <= 1'b1;
                    end
                end
                default: ;                           // S_HALT: 割り込み (許可されていれば) かリセットまで止まる
            endcase
        end
    end
endmodule
