// 同じ掛け算を、手順と数を分けずに 1 つの always に書いた物 (比べるため)
module mul_flat #(
    parameter W = 8
) (
    input              clk,
    input              rst,
    input              start,
    input  [W-1:0]     a,
    input  [W-1:0]     b,
    output [2*W-1:0]   p,
    output             done
);
    localparam [2:0] S_IDLE = 3'd0, S_LOAD = 3'd1, S_TEST = 3'd2, S_ADD = 3'd3, S_DONE = 3'd4;

    reg [2:0]     st;
    reg [W-1:0]   a_r;
    reg [W-1:0]   cnt;
    reg [2*W-1:0] acc;

    always @(posedge clk)
        if (rst) begin
            st  <= S_IDLE;
            a_r <= {W{1'b0}};
            cnt <= {W{1'b0}};
            acc <= {2*W{1'b0}};
        end else begin
            case (st)
                S_IDLE: if (start) st <= S_LOAD;
                S_LOAD: begin
                    a_r <= a;
                    cnt <= b;
                    acc <= {2*W{1'b0}};
                    st  <= S_TEST;
                end
                S_TEST: if (cnt == {W{1'b0}}) st <= S_DONE;
                        else                  st <= S_ADD;
                S_ADD: begin
                    acc <= acc + {{W{1'b0}}, a_r};
                    cnt <= cnt - 1'b1;
                    st  <= S_TEST;
                end
                S_DONE: st <= S_IDLE;
                default: st <= S_IDLE;
            endcase
        end

    assign p    = acc;
    assign done = (st == S_DONE);
endmodule
