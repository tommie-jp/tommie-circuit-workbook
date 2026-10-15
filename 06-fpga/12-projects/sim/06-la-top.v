// Tang Nano 9K に載せる最上位。8 本のピンを 27 MHz の分周で読み、ボードの USB シリアルで PC へ送る
module top (
    input        clk,        // 52 番ピン。ボードの 27 MHz
    input  [7:0] ch,         // 40・35・41・42・51・53・54・55 番ピン。3.3 V の入力
    input        rxd,        // 18 番ピン。PC → FPGA (ボードの BL702)
    output       txd,        // 17 番ピン。FPGA → PC
    output       txd_mon,    // 21 番ピン。txd と同じ物 (17 番はヘッダに出ていないので、AD3 で見るため)
    output [1:0] led_n       // 10・11 番ピン。ボードの LED (0 で点く)
);
    reg [3:0] por;
    initial por = 4'd0;      // 電源を入れた直後の 15 クロックをリセットにする (12-4)
    always @(posedge clk)
        if (por != 4'hf) por <= por + 4'd1;
    wire rst = (por != 4'hf);

    wire waiting, sending;
    la u_la (.clk(clk), .rst(rst), .din(ch), .rxd(rxd), .txd(txd), .waiting(waiting), .sending(sending));

    assign led_n   = ~{sending, waiting};
    assign txd_mon = txd;
endmodule
