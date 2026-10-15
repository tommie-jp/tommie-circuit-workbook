module traffic_fsm #(
    parameter GREEN_TIME  = 500,
    parameter YELLOW_TIME = 100,
    parameter RED_TIME    = 300,
    parameter WALK_TIME   = 400
) (
    input        clk,
    input        rst,
    input        btn,
    output reg   red,
    output reg   yellow,
    output reg   green,
    output reg   walk,
    // 観測用出力（harness から読む）
    output [1:0] o_state,
    output [9:0] o_timer,
    output       o_btn_req
);
    localparam S_GREEN  = 2'd0;
    localparam S_YELLOW = 2'd1;
    localparam S_RED    = 2'd2;
    localparam S_WALK   = 2'd3;

    reg [1:0] state;
    reg [9:0] timer;
    reg       btn_req;

    assign o_state   = state;
    assign o_timer   = timer;
    assign o_btn_req = btn_req;

    always @(posedge clk) begin
        if (rst) begin
            state   <= S_GREEN;
            timer   <= GREEN_TIME[9:0] - 10'd1;
            btn_req <= 1'b0;
            red     <= 1'b0;
            yellow  <= 1'b0;
            green   <= 1'b1;
            walk    <= 1'b0;
        end else begin
            if (btn) btn_req <= 1'b1;

            if (timer == 10'd0) begin
                case (state)
                    S_GREEN: begin
                        state  <= S_YELLOW;
                        timer  <= YELLOW_TIME[9:0] - 10'd1;
                        red    <= 1'b0; yellow <= 1'b1;
                        green  <= 1'b0; walk   <= 1'b0;
                    end
                    S_YELLOW: begin
                        if (btn_req) begin
                            state  <= S_WALK;
                            timer  <= WALK_TIME[9:0] - 10'd1;
                            red    <= 1'b1; yellow <= 1'b0;
                            green  <= 1'b0; walk   <= 1'b1;
                        end else begin
                            state  <= S_RED;
                            timer  <= RED_TIME[9:0] - 10'd1;
                            red    <= 1'b1; yellow <= 1'b0;
                            green  <= 1'b0; walk   <= 1'b0;
                        end
                    end
                    S_RED: begin
                        state  <= S_GREEN;
                        timer  <= GREEN_TIME[9:0] - 10'd1;
                        red    <= 1'b0; yellow <= 1'b0;
                        green  <= 1'b1; walk   <= 1'b0;
                    end
                    S_WALK: begin
                        btn_req <= 1'b0;
                        state   <= S_GREEN;
                        timer   <= GREEN_TIME[9:0] - 10'd1;
                        red     <= 1'b0; yellow <= 1'b0;
                        green   <= 1'b1; walk   <= 1'b0;
                    end
                    default: begin
                        state <= S_GREEN;
                        timer <= GREEN_TIME[9:0] - 10'd1;
                    end
                endcase
            end else begin
                timer <= timer - 10'd1;
            end
        end
    end
endmodule

