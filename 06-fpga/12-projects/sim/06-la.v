// ロジックアナライザの本体。PC から設定を受けて capture を動かし、貯め終えたら UART で PC へ送る。
//   PC → FPGA: 'A' と 7 バイト = div (上・下)、mask、value、edge (bit7 が有効、bit2〜0 がチャネル)、pre (上・下)
//              'F' = トリガを待たずに止める
//   FPGA → PC: 'D' と 2^AW バイト (トリガの前 pre 個から順に)
module la #(
    parameter CLK_HZ = 27_000_000,
    parameter BAUD   = 115_200,
    parameter AW     = 12
) (
    input        clk,
    input        rst,
    input  [7:0] din,
    input        rxd,
    output       txd,
    output       waiting,     // トリガを待っている
    output       sending      // PC へ送っている
);
    // ---- 受信と、設定のバイトを並べる
    wire [7:0] rx_data;
    wire       rx_valid;
    /* verilator lint_off PINCONNECTEMPTY */    // frame_err と sample は使わない
    uart_rx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
        .clk(clk), .rst(rst), .rxd(rxd), .data(rx_data), .valid(rx_valid),
        .frame_err(), .sample());
    /* verilator lint_on PINCONNECTEMPTY */

    reg [55:0] cfg;           // 受けた 7 バイト。最初のバイトが上
    reg [2:0]  ncfg;          // あと何バイト受けるか
    reg        arm;
    reg        force_trig;

    always @(posedge clk)
        if (rst) begin
            cfg        <= 56'd0;
            ncfg       <= 3'd0;
            arm        <= 1'b0;
            force_trig <= 1'b0;
        end else begin
            arm        <= 1'b0;
            force_trig <= 1'b0;
            if (rx_valid) begin
                if (ncfg != 3'd0) begin
                    cfg  <= {cfg[47:0], rx_data};
                    ncfg <= ncfg - 3'd1;
                    if (ncfg == 3'd1) arm <= 1'b1;   // 7 バイトそろった次のクロックで始める
                end else if (rx_data == "A")
                    ncfg <= 3'd7;
                else if (rx_data == "F")
                    force_trig <= 1'b1;
            end
        end

    wire [15:0] div     = cfg[55:40];
    wire [7:0]  mask    = cfg[39:32];
    wire [7:0]  value   = cfg[31:24];
    wire        edge_en = cfg[23];
    wire [2:0]  edge_ch = cfg[18:16];
    wire [AW-1:0] pre   = cfg[AW-1:0];   // 上の 16 − AW ビットは使わない

    // ---- 貯める
    wire          done;
    wire [AW-1:0] start;
    reg  [AW-1:0] ra;
    wire [7:0]    rd;

    capture #(.AW(AW)) u_cap (
        .clk(clk), .rst(rst), .din(din), .arm(arm), .force_trig(force_trig),
        .div(div), .mask(mask), .value(value), .edge_en(edge_en), .edge_ch(edge_ch),
        .pre(pre), .waiting(waiting), .done(done), .start(start), .ra(ra), .rd(rd));

    // ---- 送る: 'D' のあと、start から 2^AW バイト
    localparam [2:0] D_IDLE = 3'd0, D_HDR = 3'd1, D_RD = 3'd2, D_WAIT = 3'd3, D_SEND = 3'd4;

    reg  [2:0]  dstate;
    reg  [AW:0] left;         // 残りのバイト数
    reg  [7:0]  tx_data;
    reg         tx_start;
    wire        tx_busy;
    reg         done_d;

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
        .clk(clk), .rst(rst), .data(tx_data), .start(tx_start), .txd(txd), .busy(tx_busy));

    assign sending = (dstate != D_IDLE);

    always @(posedge clk)
        if (rst) begin
            dstate   <= D_IDLE;
            left     <= {(AW+1){1'b0}};
            ra       <= {AW{1'b0}};
            tx_data  <= 8'd0;
            tx_start <= 1'b0;
            done_d   <= 1'b0;
        end else begin
            done_d   <= done;
            tx_start <= 1'b0;
            case (dstate)
                D_IDLE:
                    if (done && !done_d) dstate <= D_HDR;     // 貯め終えた瞬間に 1 回だけ送る
                D_HDR:
                    if (!tx_busy && !tx_start) begin
                        tx_data  <= "D";
                        tx_start <= 1'b1;
                        ra       <= start;
                        left     <= {1'b1, {AW{1'b0}}};
                        dstate   <= D_RD;
                    end
                D_RD:                                       // ra を出した。次のクロックで rd に出る
                    dstate <= D_WAIT;
                D_WAIT:
                    dstate <= D_SEND;
                default:                                    // D_SEND
                    if (!tx_busy && !tx_start) begin
                        tx_data  <= rd;
                        tx_start <= 1'b1;
                        ra       <= ra + 1'b1;
                        left     <= left - 1'b1;
                        dstate   <= (left == {{AW{1'b0}}, 1'b1}) ? D_IDLE : D_RD;
                    end
            endcase
        end
endmodule
