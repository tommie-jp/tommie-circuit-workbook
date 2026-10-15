// td4_xrom.v  TD4 の ROM を外に出した物 (11-4)。中身は 5-8 の TD4.v と同じ
// 命令 (op) を外から受け、番地 (pc_out) を外へ出す。IC 版の「IC 10 個」と同じ範囲を合成で数えるため
// 元: asfdrwe/simpleTD4 の TD4.v (MIT)。Copyright (c) 2020 asfdrwe
// SPDX-License-Identifier: MIT
module td4_xrom (
    input  wire       clock,
    input  wire       reset_n,
    input  wire [3:0] in_port,
    input  wire [7:0] op,        // ROM の出力
    output wire [3:0] pc_out,    // ROM の番地
    output wire [3:0] out_port
);
    reg [3:0] reg_a, reg_b, reg_out, pc;
    reg       cflag;
    assign out_port = reg_out;
    assign pc_out   = pc;

    wire [1:0] alu_sel  = (op[7:6] == 2'b11) ? 2'b11 : op[5:4];
    wire [1:0] load_sel = op[7:6];
    wire       jmp      = op[4];
    wire [3:0] im       = op[3:0];

    wire [3:0] alu_in = (alu_sel == 2'b00) ? reg_a   :
                        (alu_sel == 2'b01) ? reg_b   :
                        (alu_sel == 2'b10) ? in_port :
                                             4'b0000;
    wire [3:0] alu_out;
    wire       nextcflag;
    assign {nextcflag, alu_out} = alu_in + im;

    wire load_pc = (load_sel == 2'b11) && (jmp || cflag);

    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            reg_a   <= 4'b0;
            reg_b   <= 4'b0;
            reg_out <= 4'b0;
            cflag   <= 1'b1;
            pc      <= 4'b0;
        end else begin
            if (load_sel == 2'b00) reg_a   <= alu_out;
            if (load_sel == 2'b01) reg_b   <= alu_out;
            if (load_sel == 2'b10) reg_out <= alu_out;
            cflag <= ~nextcflag;
            pc    <= load_pc ? alu_out : pc + 4'd1;
        end
    end
endmodule
