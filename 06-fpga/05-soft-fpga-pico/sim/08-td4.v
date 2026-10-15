// TD4 (4 ビット CPU)。asfdrwe/simpleTD4 の TD4.v (MIT) を元にした
// tommie-jp/Soft-FPGA-TD4 の TD4.v から、$monitor・#1・初期値を除いたもの。
// 初期値の代わりに、動かす前に reset_n を 0 にする。
// Copyright (c) 2020 asfdrwe (asfdrwe@gmail.com)
// SPDX-License-Identifier: MIT
module TD4 (
    input  wire       clock,
    input  wire       reset_n,
    input  wire [3:0] in_port,
    output wire [3:0] pc_out,
    output wire [7:0] op,
    output wire [3:0] out_port,
    output wire [3:0] alu_data
);
    reg [3:0] reg_a, reg_b, reg_out;
    reg [3:0] pc;
    reg       cflag;
    assign out_port = reg_out;
    assign pc_out = pc;

    reg [7:0] rom [0:15];
    initial begin
        rom[4'b0000] = 8'b1011_0011; // OUT 0011
        rom[4'b0001] = 8'b1011_0110; // OUT 0110
        rom[4'b0010] = 8'b1011_1100; // OUT 1100
        rom[4'b0011] = 8'b1011_1000; // OUT 1000
        rom[4'b0100] = 8'b1011_1000; // OUT 1000
        rom[4'b0101] = 8'b1011_1100; // OUT 1100
        rom[4'b0110] = 8'b1011_0110; // OUT 0110
        rom[4'b0111] = 8'b1011_0011; // OUT 0011
        rom[4'b1000] = 8'b1011_0001; // OUT 0001
        rom[4'b1001] = 8'b1111_0000; // JMP 0000
        rom[4'b1010] = 8'b0000_0000; // ADD A,0 (何もしない)
        rom[4'b1011] = 8'b0000_0000;
        rom[4'b1100] = 8'b0000_0000;
        rom[4'b1101] = 8'b0000_0000;
        rom[4'b1110] = 8'b0000_0000;
        rom[4'b1111] = 8'b0000_0000;
    end

    wire [7:0] opcode = rom[pc];
    assign op = opcode;

    wire [1:0] alu_sel  = (opcode[7:6] == 2'b11) ? 2'b11 : opcode[5:4];
    wire [1:0] load_sel = opcode[7:6];
    wire       jmp      = opcode[4];
    wire [3:0] im       = opcode[3:0];

    wire [3:0] alu_in = (alu_sel == 2'b00) ? reg_a   :
                        (alu_sel == 2'b01) ? reg_b   :
                        (alu_sel == 2'b10) ? in_port :
                                             4'b0000;

    wire [3:0] alu_out;
    wire       nextcflag;
    assign {nextcflag, alu_out} = alu_in + im;
    assign alu_data = alu_out;

    // 負論理の書き込み許可 (0 で書く)
    wire load_a   = (load_sel == 2'b00) ? 1'b0 : 1'b1;
    wire load_b   = (load_sel == 2'b01) ? 1'b0 : 1'b1;
    wire load_out = (load_sel == 2'b10) ? 1'b0 : 1'b1;
    wire load_pc  = (load_sel == 2'b11 && (jmp == 1'b1 || cflag)) ? 1'b0 : 1'b1;

    wire [3:0] next_pc = (load_pc == 1'b0) ? alu_out : pc + 4'd1;

    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            reg_a   <= 4'b0;
            reg_b   <= 4'b0;
            reg_out <= 4'b0;
            cflag   <= 1'b1;
            pc      <= 4'b0;
        end else begin
            reg_a   <= (load_a   == 1'b0) ? alu_out : reg_a;
            reg_b   <= (load_b   == 1'b0) ? alu_out : reg_b;
            reg_out <= (load_out == 1'b0) ? alu_out : reg_out;
            cflag   <= ~nextcflag;  // 負論理の桁上げ
            pc      <= next_pc;
        end
    end
endmodule
