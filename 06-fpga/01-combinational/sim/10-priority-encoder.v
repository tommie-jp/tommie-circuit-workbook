// pri_casez.v  casez で書いた 4 入力のプライオリティエンコーダ
module pri_casez (
    input  wire [3:0] req,
    output reg  [1:0] code,
    output reg        valid
);
    always @(*) begin
        casez (req)
            4'b1???: begin code = 2'd3; valid = 1'b1; end
            4'b01??: begin code = 2'd2; valid = 1'b1; end
            4'b001?: begin code = 2'd1; valid = 1'b1; end
            4'b0001: begin code = 2'd0; valid = 1'b1; end
            default: begin code = 2'd0; valid = 1'b0; end
        endcase
    end
endmodule

// pri_if.v  if / else if で書いた 4 入力のプライオリティエンコーダ
module pri_if (
    input  wire [3:0] req,
    output reg  [1:0] code,
    output reg        valid
);
    always @(*) begin
        if (req[3]) begin
            code = 2'd3; valid = 1'b1;
        end else if (req[2]) begin
            code = 2'd2; valid = 1'b1;
        end else if (req[1]) begin
            code = 2'd1; valid = 1'b1;
        end else if (req[0]) begin
            code = 2'd0; valid = 1'b1;
        end else begin
            code = 2'd0; valid = 1'b0;
        end
    end
endmodule

// pri_gates.v  図 1 のゲートのとおりに書いた 4 入力のプライオリティエンコーダ
module pri_gates (
    input  wire [3:0] req,
    output wire [1:0] code,
    output wire       valid
);
    assign code[1] = req[3] | req[2];
    assign code[0] = req[3] | (~req[2] & req[1]);
    assign valid   = (req[1] | req[0]) | (req[3] | req[2]);
endmodule

// pri_cmp.v  3 通りの書き方に同じ入力を入れ、出力がそろっていれば same を 1 にする
module pri_cmp (
    input  wire [3:0] req,
    output wire [1:0] code,
    output wire       valid,
    output wire       same
);
    wire [1:0] code_i;
    wire       valid_i;
    wire [1:0] code_g;
    wire       valid_g;
    pri_casez u_casez (.req(req), .code(code),   .valid(valid));
    pri_if    u_if    (.req(req), .code(code_i), .valid(valid_i));
    pri_gates u_gates (.req(req), .code(code_g), .valid(valid_g));
    assign same = ({code, valid} == {code_i, valid_i}) && ({code, valid} == {code_g, valid_g});
endmodule
