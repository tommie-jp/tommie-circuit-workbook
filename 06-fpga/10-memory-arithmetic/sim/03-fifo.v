// fifo4x4.v  4 ビット幅 × 4 語の FIFO。dout は先頭の語を常に見せる
module fifo4x4 (
    input  wire       clk,
    input  wire       rst,
    input  wire       push,      // 1 のとき、立ち上がりで din を入れる (full なら無視)
    input  wire [3:0] din,
    input  wire       pop,       // 1 のとき、立ち上がりで先頭を捨てる (empty なら無視)
    output wire [3:0] dout,      // 先頭の語。empty のときは意味が無い
    output wire       full,
    output wire       empty,
    output wire [2:0] count      // 入っている語の数 (0〜4)
);
    reg [3:0] mem [0:3];
    reg [2:0] wptr;              // 書く番地。下位 2 ビットが番地、最上位は「何周したか」
    reg [2:0] rptr;              // 読む番地。同じ形

    assign empty = (wptr == rptr);
    assign full  = (wptr[1:0] == rptr[1:0]) && (wptr[2] != rptr[2]);
    assign count = wptr - rptr;
    assign dout  = mem[rptr[1:0]];

    wire do_push = push && !full;
    wire do_pop  = pop  && !empty;

    always @(posedge clk) begin
        if (rst) begin
            wptr <= 3'd0;
            rptr <= 3'd0;
        end else begin
            if (do_push) begin
                mem[wptr[1:0]] <= din;
                wptr <= wptr + 3'd1;
            end
            if (do_pop)
                rptr <= rptr + 3'd1;
        end
    end
endmodule
