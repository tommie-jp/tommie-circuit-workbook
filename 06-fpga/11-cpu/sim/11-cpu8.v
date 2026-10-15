// cpu8.v  8 ビットのアキュムレータ型 CPU (11-11)
// 命令は 2 語 (命令 1 語 + 引数 1 語)。取り出し 2 クロック + 実行 1 クロックの 3 クロックで 1 命令
// メモリは外に置く (番地 addr、読む値 rdata、書く値 wdata、書く合図 we)。読みは同じクロックで返る形
module cpu8 (
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
    output wire [1:0] state_out
);
    localparam [1:0] S_FETCH = 2'd0, S_ARG = 2'd1, S_EXEC = 2'd2, S_HALT = 2'd3;
    localparam [7:0] NOP  = 8'h00, LDI  = 8'h01, LD   = 8'h02, ST   = 8'h03,
                     ADD  = 8'h04, SUB  = 8'h05, ADDI = 8'h06, SUBI = 8'h07,
                     AND_ = 8'h08, OR_  = 8'h09, XOR_ = 8'h0A, SHL  = 8'h0B,
                     SHR  = 8'h0C, JMP  = 8'h10, JZ   = 8'h11, JNZ  = 8'h12,
                     JC   = 8'h13, JNC  = 8'h14, IN   = 8'h18, OUT  = 8'h19,
                     HLT  = 8'h1F;

    reg [7:0] pc, ir, arg, acc;
    reg       z, c;
    reg [1:0] state;
    assign halted    = (state == S_HALT);
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
        if (rst) begin
            pc <= 8'd0; ir <= NOP; arg <= 8'd0; acc <= 8'd0;
            z <= 1'b0; c <= 1'b0; out_port <= 8'd0; state <= S_FETCH;
        end else begin
            case (state)
                S_FETCH: begin ir  <= rdata; pc <= pc + 8'd1; state <= S_ARG;  end
                S_ARG:   begin arg <= rdata; pc <= pc + 8'd1; state <= S_EXEC; end
                S_EXEC: begin
                    state <= (ir == HLT) ? S_HALT : S_FETCH;
                    if (wr_acc) begin
                        acc <= r[7:0];
                        z   <= (r[7:0] == 8'd0);    // A に書く命令はゼロフラグも書く
                    end
                    if (wr_c) c <= r[8];
                    if (take) pc <= arg;
                    if (ir == OUT) begin out_port <= acc; out_stb <= 1'b1; end
                end
                default: ;                           // S_HALT: リセットまで止まる
            endcase
        end
    end
endmodule
