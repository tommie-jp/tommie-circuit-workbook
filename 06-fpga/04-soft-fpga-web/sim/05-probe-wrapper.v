// 薄いラッパ: uart_top を中身ごと包み、ポートはそのまま通す。
// 外に出ていない送信機・受信機のビット計数 clk_cnt を、階層の名前で読んで出力にする。
module uart_probe_top #(
    parameter CLKS_PER_BIT = 16
) (
    input         clk,
    input         rst,
    input  [7:0]  tx_data,
    input         tx_valid,
    output        tx_ready,
    output [7:0]  o_rx_data,
    output        o_rx_valid,
    output        o_rx_error,
    output [1:0]  o_tx_state,
    output [1:0]  o_rx_state,
    output [2:0]  o_tx_bit,
    output [2:0]  o_rx_bit,
    output [7:0]  o_tx_data,
    output        o_txd,
    output        o_rxd,
    // ここから下が足した観測用の出力
    output [15:0] o_tx_cnt,
    output [15:0] o_rx_cnt
);
    uart_top #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_core (
        .clk        (clk),
        .rst        (rst),
        .tx_data    (tx_data),
        .tx_valid   (tx_valid),
        .tx_ready   (tx_ready),
        .o_rx_data  (o_rx_data),
        .o_rx_valid (o_rx_valid),
        .o_rx_error (o_rx_error),
        .o_tx_state (o_tx_state),
        .o_rx_state (o_rx_state),
        .o_tx_bit   (o_tx_bit),
        .o_rx_bit   (o_rx_bit),
        .o_tx_data  (o_tx_data),
        .o_txd      (o_txd),
        .o_rxd      (o_rxd)
    );

    assign o_tx_cnt = u_core.u_tx.clk_cnt;
    assign o_rx_cnt = u_core.u_rx.clk_cnt;
endmodule
