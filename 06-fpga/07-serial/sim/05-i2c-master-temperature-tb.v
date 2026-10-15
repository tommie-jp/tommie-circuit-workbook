`timescale 1ns / 1ps
// LM75 の動きを真似た模型 (アドレス ADDR、ポインタで温度レジスタを選び、上位・下位の順に 2 バイト返す) に
// i2c_temp_top をつなぎ、UART の出力 (4800 bps) を読んで書き出す。SDA と SCL はオープンドレイン (どちらかが 0 を引けば 0)
module tb_i2c;
    parameter [6:0] MODEL_ADDR = 7'h48;

    reg clk;
    initial begin
        clk = 1'b0;
        forever #6500 clk = ~clk;          // 13 us
    end
    reg rst;

    wire sda_low, scl_low, txd;
    reg  slv_low;                           // 模型が SDA を 0 に引く
    wire sda = ~(sda_low | slv_low);        // 外のプルアップが 1 を作る
    wire scl = ~scl_low;

    i2c_temp_top dut (.clk(clk), .rst(rst), .sda_in(sda),
                      .sda_low(sda_low), .scl_low(scl_low), .txd(txd));

    // ---- LM75 の模型
    reg [7:0] t_hi, t_lo, ptr_reg;
    integer   n_read;
    task automatic recv_byte(output [7:0] b);
        integer i;
        begin
            b = 8'h00;
            for (i = 0; i < 8; i = i + 1) begin
                @(posedge scl);
                b = {b[6:0], sda};
            end
        end
    endtask
    task automatic send_ack;
        begin
            @(negedge scl); slv_low = 1'b1;     // 8 ビット目の次の SCL の間、0 を引く
            @(negedge scl); slv_low = 1'b0;
        end
    endtask
    task automatic send_byte(input [7:0] v, output ack);
        integer i;
        begin
            slv_low = ~v[7];                    // 直前の negedge の直後なので、最上位ビットをここで出す
            for (i = 6; i >= 0; i = i - 1) begin
                @(negedge scl);
                slv_low = ~v[i];
            end
            @(negedge scl);
            slv_low = 1'b0;                     // 9 つ目のクロックは放す。マスタが ACK か NACK を返す
            @(posedge scl);
            ack = ~sda;
            @(negedge scl);                     // この negedge の直後に次のバイトの最上位ビットを出す
        end
    endtask

    reg [7:0] rb;
    reg       a;
    initial begin
        slv_low = 1'b0; t_hi = 8'h19; t_lo = 8'h80; ptr_reg = 8'h00; n_read = 0;
        forever begin
            @(negedge sda);
            if (scl) begin                          // START
                recv_byte(rb);
                if (rb[7:1] == MODEL_ADDR && !rb[0]) begin
                    send_ack;
                    recv_byte(rb);                  // ポインタ
                    ptr_reg = rb;
                    send_ack;
                    @(negedge sda);                 // 再 START
                    recv_byte(rb);
                    if (rb[7:1] == MODEL_ADDR && rb[0]) begin
                        send_ack;
                        send_byte(t_hi, a);
                        send_byte(t_lo, a);         // マスタの NACK のあとは何もしない
                        slv_low = 1'b0;
                        n_read = n_read + 1;
                    end
                end else begin
                    // 自分のアドレスでなければ ACK を返さない (SDA は 1 のまま)
                end
            end
        end
    end

    // ---- UART の受信 (4800 bps ちょうど)
    localparam real BIT_NS = 1.0e9 / 4800.0;
    reg [7:0] rx;
    integer   b;
    integer   nchar = 0;
    reg [8*8-1:0] line;
    integer   ll = 0;
    initial begin
        #1000;
        forever begin
            @(negedge txd);
            #(BIT_NS * 1.5);
            for (b = 0; b < 8; b = b + 1) begin
                rx[b] = txd;
                #(BIT_NS);
            end
            nchar = nchar + 1;
            if (rx == 8'h0A) begin
                $display("  uart line (%0d reads): %0s", n_read, line);
                line = 0; ll = 0;
            end else if (rx != 8'h0D) begin
                line = {line[8*7-1:0], rx};
                ll = ll + 1;
            end
        end
    end

    // ---- 変わり目の記録 (最初の 1 回の読み出し。logic の図の元)
    realtime t0, tlast;
    integer  go = 0;
    always @(sda or scl) begin
        if (!rst && n_read < 2 && (go == 0 || $realtime - t0 < 2700000.0)) begin
            if (go == 0) t0 = $realtime;
            $display("EDGE %9.1f scl=%b sda=%b", ($realtime - t0) / 1000.0, scl, sda);
            go = go + 1;
        end
    end

    // ---- UART の TXD の変わり目 (最初の 1 行。最初の START からの時刻)
    realtime tstart_i2c;
    reg got_start = 0;
    always @(negedge sda) if (scl && !got_start && !rst) begin tstart_i2c = $realtime; got_start = 1; end
    always @(txd)
        if (got_start && n_read < 2 && $realtime - tstart_i2c < 22000000.0)
            $display("TXD %9.1f %b", ($realtime - tstart_i2c) / 1000.0, txd);

    initial begin
        #4000000000 $finish;               // 返事が無い試験のための打ち切り (4 s)
    end

    initial begin
        rst = 1'b1;
        #26000 rst = 1'b0;
        wait (n_read == 1);
        #(12 * BIT_NS * 7);
        $display("--- 温度を -25.0 C (0xE7 0x00) に変える");
        t_hi = 8'hE7; t_lo = 8'h00;
        wait (n_read == 2); wait (n_read == 3);
        #(12 * BIT_NS * 7);
        $display("--- 0x7D 0x00 (+125 C)");
        t_hi = 8'h7D; t_lo = 8'h00;
        wait (n_read == 5);
        #(12 * BIT_NS * 7);
        $finish;
    end
endmodule
