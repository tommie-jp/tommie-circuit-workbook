// I2C のマスタ (100 kHz 以下のスタンダードモード、7 ビットアドレス)。
// LM75 のレジスタを 1 つ読む決まった手順だけを行う:
//   START - (ADDR<<1|0) - ACK - PTR - ACK - 再START - (ADDR<<1|1) - ACK - 上位バイト - ACK - 下位バイト - NACK - STOP
// SDA と SCL は「0 を引く」か「放す」かだけ。1 は外のプルアップが作る (オープンドレイン)
module i2c_read #(
    parameter [6:0] ADDR = 7'h48,   // LM75 は A2・A1・A0 を GND に落とすと 0x48
    parameter [7:0] PTR  = 8'h00,   // 読むレジスタ。0 が温度
    parameter integer QTR = 1       // SCL の 1/4 周期のクロック数。1 なら SCL = クロック / 4
) (
    input            clk,
    input            rst,
    input            start,         // 1 クロック 1 で読み始める
    input            sda_in,        // SDA 線の今の値 (GPIO の入力)
    output reg       sda_low,       // 1 のとき SDA を GND へ引く。0 なら放す
    output reg       scl_low,       // 1 のとき SCL を GND へ引く。0 なら放す
    output           busy,
    output reg       done,          // 読み終えたクロックだけ 1
    output reg       nack,          // done のとき 1 なら、アドレスかレジスタ番号に ACK が返らなかった
    output reg [7:0] data_hi,       // 温度の上位バイト
    output reg [7:0] data_lo        // 温度の下位バイト
);
    localparam integer QW = (QTR > 1) ? $clog2(QTR) : 1;

    reg            active;
    reg [5:0]      slot;            // 0〜47
    reg [1:0]      ph;              // 枠の中の 1/4 周期 0〜3
    reg [QW-1:0]   qcnt;
    reg            nack_acc;
    reg [7:0]      sh_in;

    assign busy = active;

    // 枠 slot の種類。
    //  0: START  1〜8: アドレス(書き)  9: ACK  10〜17: レジスタ番号  18: ACK  19: 再START
    //  20〜27: アドレス(読み)  28: ACK  29〜36: 上位バイトを受ける  37: ACK を返す
    //  38〜45: 下位バイトを受ける  46: NACK を返す  47: STOP
    wire [7:0] addr_w = {ADDR, 1'b0};
    wire [7:0] addr_r = {ADDR, 1'b1};

    // 枠の番号から、8 ビットのうち何ビット目 (7 が最初) を出すか。3 ビットで足りるので下位だけ使う
    wire [2:0] bit_a = 3'd0 - slot[2:0];   // 枠 1〜8   → 7〜0
    wire [2:0] bit_p = 3'd1 - slot[2:0];   // 枠 10〜17 → 7〜0
    wire [2:0] bit_r = 3'd3 - slot[2:0];   // 枠 20〜27 → 7〜0

    // 枠が出すビット (master → slave の枠だけ意味がある)。
    reg out_bit;
    always @(*) begin
        out_bit = 1'b1;
        if (slot >= 6'd1  && slot <= 6'd8)  out_bit = addr_w[bit_a];
        if (slot >= 6'd10 && slot <= 6'd17) out_bit = PTR[bit_p];
        if (slot >= 6'd20 && slot <= 6'd27) out_bit = addr_r[bit_r];
        if (slot == 6'd37)                  out_bit = 1'b0;     // 上位バイトに ACK を返す (0 を引く)
        if (slot == 6'd46)                  out_bit = 1'b1;     // 下位バイトに NACK を返す (放す)
    end

    wire is_start = (slot == 6'd0)  || (slot == 6'd19);
    wire is_stop  = (slot == 6'd47);
    wire is_ackin = (slot == 6'd9)  || (slot == 6'd18) || (slot == 6'd28);
    wire is_din   = (slot >= 6'd29 && slot <= 6'd36) || (slot >= 6'd38 && slot <= 6'd45);
    wire q_last   = (qcnt == QTR[QW-1:0] - 1'b1);

    always @(posedge clk)
        if (rst) begin
            active   <= 1'b0;
            slot     <= 6'd0;
            ph       <= 2'd0;
            qcnt     <= {QW{1'b0}};
            sda_low  <= 1'b0;
            scl_low  <= 1'b0;
            done     <= 1'b0;
            nack     <= 1'b0;
            nack_acc <= 1'b0;
            sh_in    <= 8'h00;
            data_hi  <= 8'h00;
            data_lo  <= 8'h00;
        end else begin
            done <= 1'b0;
            if (!active) begin
                if (start) begin
                    active   <= 1'b1;
                    slot     <= 6'd0;
                    ph       <= 2'd0;
                    qcnt     <= {QW{1'b0}};
                    nack_acc <= 1'b0;
                    sda_low  <= 1'b0;     // バスは両方放した状態から始める
                    scl_low  <= 1'b0;
                end
            end else begin
                // ---- 1/4 周期ごとに線を動かす (枠の頭 ph == 0 で SDA、ph == 1 で SCL を上げる、…)
                if (qcnt == {QW{1'b0}}) begin
                    case (ph)
                        2'd0: begin
                            // SCL を低くしたまま SDA を決める
                            if (is_stop) begin scl_low <= 1'b1; sda_low <= 1'b1; end
                            else begin
                                scl_low <= 1'b1;
                                if (is_start)      sda_low <= 1'b0;          // 放す (1)
                                else if (is_ackin || is_din) sda_low <= 1'b0;  // 相手に任せる
                                else               sda_low <= ~out_bit;
                            end
                        end
                        2'd1: scl_low <= 1'b0;                                // SCL を放して上げる
                        2'd2: begin
                            if (is_start) sda_low <= 1'b1;                    // SCL が高いうちに SDA を下げる = START
                            if (is_ackin && sda_in) nack_acc <= 1'b1;         // ACK の枠で 1 なら返事が無い
                            if (is_din) sh_in <= {sh_in[6:0], sda_in};        // SCL の高い真ん中で読む
                        end
                        default: begin
                            if (is_stop) sda_low <= 1'b0;                     // SCL が高いうちに SDA を放す = STOP
                            else scl_low <= 1'b1;                             // SCL を下げる
                        end
                    endcase
                end
                // ---- 時間を進める
                if (!q_last) qcnt <= qcnt + 1'b1;
                else begin
                    qcnt <= {QW{1'b0}};
                    if (ph != 2'd3) ph <= ph + 2'd1;
                    else begin
                        ph <= 2'd0;
                        // 枠の終わりで、読んだバイトを置く
                        if (slot == 6'd36) data_hi <= sh_in;
                        if (slot == 6'd45) data_lo <= sh_in;
                        if (slot == 6'd47) begin
                            active <= 1'b0;
                            done   <= 1'b1;
                            nack   <= nack_acc;
                        end else
                            slot <= slot + 6'd1;
                    end
                end
            end
        end
endmodule
