// td4x.v  TD4 に 4 つの命令 (OUT A・ADD A,B・JZ・SUB A,B) とゼロフラグを足した物 (11-5)
// 定義のある 12 命令は TD4.v (5-8) と同じに動く。ROM は外に置き、命令 (op) を受けて番地 (pc_out) を出す
module td4x (
    input  wire       clock,
    input  wire       reset_n,
    input  wire [3:0] in_port,
    input  wire [7:0] op,        // ROM の出力
    output wire [3:0] pc_out,    // ROM の番地
    output wire [3:0] out_port,
    output wire       flag_c,    // 桁上げ (1 で桁上げ有り。TD4.v と逆の向きで持つ)
    output wire       flag_z     // ゼロ (1 で結果が 0)
);
    localparam [1:0] TO_A = 2'd0, TO_B = 2'd1, TO_OUT = 2'd2, TO_PC = 2'd3;

    reg [3:0] reg_a, reg_b, reg_out, pc;
    reg       c, z;
    assign out_port = reg_out;
    assign pc_out   = pc;
    assign flag_c   = c;
    assign flag_z   = z;

    wire [3:0] code = op[7:4];
    wire [3:0] im   = op[3:0];

    // 足し算の 2 つの入り口 (x と y) と桁の入り (cin)、書く先 (dst)、飛ぶ条件 (take) を命令で決める
    reg [3:0] x, y;
    reg       cin, take;
    reg [1:0] dst;
    always @* begin
        x = 4'd0; y = im; cin = 1'b0; dst = TO_A; take = 1'b0;
        case (code)
            4'b0000: begin x = reg_a;   dst = TO_A;   end          // ADD A,Im
            4'b0001: begin x = reg_b;   dst = TO_A;   end          // MOV A,B
            4'b0010: begin x = in_port; dst = TO_A;   end          // IN  A
            4'b0011: begin              dst = TO_A;   end          // MOV A,Im
            4'b0100: begin x = reg_a;   dst = TO_B;   end          // MOV B,A
            4'b0101: begin x = reg_b;   dst = TO_B;   end          // ADD B,Im
            4'b0110: begin x = in_port; dst = TO_B;   end          // IN  B
            4'b0111: begin              dst = TO_B;   end          // MOV B,Im
            4'b1000: begin x = reg_a;   dst = TO_OUT; end          // OUT A      (足した)
            4'b1001: begin x = reg_b;   dst = TO_OUT; end          // OUT B
            4'b1010: begin x = reg_a; y = reg_b; dst = TO_A; end   // ADD A,B    (足した)
            4'b1011: begin              dst = TO_OUT; end          // OUT Im
            4'b1100: begin dst = TO_PC; take = z;  end             // JZ  Im     (足した)
            4'b1101: begin x = reg_a; y = ~reg_b; cin = 1'b1; dst = TO_A; end  // SUB A,B (足した)
            4'b1110: begin dst = TO_PC; take = ~c; end             // JNC Im
            default: begin dst = TO_PC; take = 1'b1; end           // JMP Im (1111)
        endcase
    end

    wire [4:0] sum = {1'b0, x} + {1'b0, y} + {4'd0, cin};

    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            reg_a   <= 4'd0;
            reg_b   <= 4'd0;
            reg_out <= 4'd0;
            pc      <= 4'd0;
            c       <= 1'b0;
            z       <= 1'b0;
        end else begin
            if (dst == TO_A)   reg_a   <= sum[3:0];
            if (dst == TO_B)   reg_b   <= sum[3:0];
            if (dst == TO_OUT) reg_out <= sum[3:0];
            pc <= (dst == TO_PC && take) ? sum[3:0] : pc + 4'd1;
            c  <= sum[4];                 // フラグは TD4 と同じく毎命令で書き直す
            z  <= (sum[3:0] == 4'd0);
        end
    end
endmodule

// td4x_rom  td4x に 16 番地の ROM をつないだ物。ROM の中身は $readmemh で読む
// ファイルは +rom=<名前> で替えられる (既定は ROMFILE)
module td4x_rom #(parameter ROMFILE = "05-td4x-sum.hex") (
    input  wire       clock,
    input  wire       reset_n,
    input  wire [3:0] in_port,
    output wire [3:0] pc_out,
    output wire [7:0] op,
    output wire [3:0] out_port,
    output wire       flag_c,
    output wire       flag_z
);
    reg [7:0]       rom [0:15];
    reg [8*256-1:0] fname;
    initial begin
`ifdef SYNTHESIS
        fname = 0;
        $readmemh(ROMFILE, rom);
`else
        if ($value$plusargs("rom=%s", fname)) $readmemh(fname, rom);
        else                                  $readmemh(ROMFILE, rom);
`endif
    end
    assign op = rom[pc_out];
    td4x cpu (.clock(clock), .reset_n(reset_n), .in_port(in_port), .op(op),
              .pc_out(pc_out), .out_port(out_port), .flag_c(flag_c), .flag_z(flag_z));
endmodule
