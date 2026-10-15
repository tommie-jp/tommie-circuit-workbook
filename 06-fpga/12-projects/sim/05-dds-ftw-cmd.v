// 周波数の設定 (ftw) を決める。
//   UART: 16 進 8 桁のあとに改行 (CR か LF) が来たら、その 8 桁を ftw にする。8 桁より多ければ最後の 8 桁
//   ボタン: next が 1 になるたびに、4 つのプリセット (1 kHz・10 kHz・100 kHz・1 MHz) を順に選ぶ
module ftw_cmd #(
    parameter [31:0] P0 = 32'd159073,       // 1 kHz   (27 MHz のとき)
    parameter [31:0] P1 = 32'd1590729,      // 10 kHz
    parameter [31:0] P2 = 32'd15907286,     // 100 kHz
    parameter [31:0] P3 = 32'd159072863     // 1 MHz
) (
    input             clk,
    input             rst,
    input       [7:0] rx_data,
    input             rx_valid,
    input             next,
    output reg [31:0] ftw
);
    reg [31:0] acc;     // 受けた 16 進の桁を左から詰める
    reg [3:0]  ndig;    // 続けて受けた桁の数 (8 で止める)
    reg [1:0]  sel;     // いまのプリセット

    wire is_dec = (rx_data >= "0") && (rx_data <= "9");
    wire is_hex = is_dec || ((rx_data >= "a") && (rx_data <= "f"))
                         || ((rx_data >= "A") && (rx_data <= "F"));
    wire [3:0] nib = is_dec ? rx_data[3:0] : rx_data[3:0] + 4'd9;    // 'a' = 0x61 → 1 + 9 = 10
    wire is_eol = (rx_data == 8'h0d) || (rx_data == 8'h0a);

    function [31:0] preset(input [1:0] k);
        case (k)
            2'd0:    preset = P0;
            2'd1:    preset = P1;
            2'd2:    preset = P2;
            default: preset = P3;
        endcase
    endfunction

    always @(posedge clk)
        if (rst) begin
            ftw  <= P0;
            sel  <= 2'd0;
            acc  <= 32'd0;
            ndig <= 4'd0;
        end else if (next) begin
            sel <= sel + 2'd1;
            ftw <= preset(sel + 2'd1);
        end else if (rx_valid) begin
            if (is_hex) begin
                acc <= {acc[27:0], nib};
                if (ndig != 4'd8) ndig <= ndig + 4'd1;
            end else begin
                if (is_eol && ndig == 4'd8) ftw <= acc;
                ndig <= 4'd0;                 // 改行もほかの字も、桁の数を 0 に戻す
            end
        end
endmodule
