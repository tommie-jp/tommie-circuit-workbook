// Apple-I を FPGA の中に組む: 65C02 のコア + RAM + ROM + PIA の代わりの UART。
// メモリは番地を出した次のクロックにデータが出る形 (ブロック RAM)。コアがその形を前提にしている
//   $0000-$1FFF  RAM 8 KB (RAM_AW = 13)
//   $D010-$D013  PIA (A4 = 1 の $D0xx はどれも同じ 4 つ。BASIC は $D0F2 に書く)
//   $E000-$FFFF  ROM 8 KB ($E000 Integer BASIC、$FF00 Woz Monitor)
module apple1_fpga #(
    parameter CLK_HZ  = 27_000_000,
    parameter BAUD    = 115_200,
    parameter RAM_AW  = 13,
    parameter ROM_HEX = "rom.hex"
) (
    input  clk,
    input  rst,
    input  rxd,
    output txd,
    output kbd_stb,
    output dsp_stb,
    output sync        // opcode が CPU に届いたクロックで 1 (試験で命令を数える)
);
    wire [15:0] ab;
    wire [7:0]  dout;
    wire        we;
    reg  [7:0]  di;

    /* verilator lint_off PINCONNECTEMPTY */     // 観測用の出力 (o_a など) は使わない
    cpu_65c02 u_cpu (
        .clk(clk), .reset(rst), .AB(ab), .DI(di), .DO(dout), .WE(we),
        .IRQ(1'b0), .NMI(1'b0), .RDY(1'b1), .SYNC(sync),
        .o_a(), .o_x(), .o_y(), .o_sp(), .o_pc(), .o_p(), .o_state());
    /* verilator lint_on PINCONNECTEMPTY */

    // ---- 番地を分ける ----
    wire is_ram = (ab[15:RAM_AW] == {(16 - RAM_AW){1'b0}});
    wire is_pia = ((ab & 16'hFF10) == 16'hD010);
    wire is_rom = (ab[15:13] == 3'b111);

    // ---- RAM: 書くのは WE のクロック、読みは次のクロックに出る ----
    reg [7:0] ram [0:(1 << RAM_AW) - 1];
    reg [7:0] ram_q;
    always @(posedge clk) begin
        if (we && is_ram) ram[ab[RAM_AW-1:0]] <= dout;
        ram_q <= ram[ab[RAM_AW-1:0]];
    end

    // ---- ROM: 中身は合成のときに ROM_HEX から入れる ----
    reg [7:0] rom [0:8191];
    reg [7:0] rom_q;
    initial $readmemh(ROM_HEX, rom);
    always @(posedge clk) rom_q <= rom[ab[12:0]];

    // ---- PIA の代わり ----
    wire [7:0] pia_q;
    pia_uart #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_pia (
        .clk(clk), .rst(rst), .cs(is_pia), .rs(ab[1:0]), .we(we), .wdata(dout), .rdata(pia_q),
        .rxd(rxd), .txd(txd), .kbd_stb(kbd_stb), .dsp_stb(dsp_stb));

    // ---- どこを読んだかを 1 クロック覚えて、次のクロックにそのデータを選ぶ ----
    localparam [1:0] SEL_NONE = 2'd0, SEL_RAM = 2'd1, SEL_ROM = 2'd2, SEL_PIA = 2'd3;
    reg [1:0] sel;
    always @(posedge clk)
        sel <= is_ram ? SEL_RAM : is_rom ? SEL_ROM : is_pia ? SEL_PIA : SEL_NONE;

    always @(*)
        case (sel)
            SEL_RAM: di = ram_q;
            SEL_ROM: di = rom_q;
            SEL_PIA: di = pia_q;
            default: di = 8'hFF;      // 何も無い番地
        endcase
endmodule
