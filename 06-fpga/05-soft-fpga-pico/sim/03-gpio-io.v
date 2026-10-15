// io_reg.v: 2 本の入力 sw を、クロックの立ち上がりごとに 2 本の出力 led へ写す
module io_reg (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] sw,
    output reg  [1:0] led
);
    always @(posedge clk)
        if (rst)
            led <= 2'b00;
        else
            led <= sw;
endmodule
