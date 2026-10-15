// 4-4 の traffic_fsm と、2 つに分けた traffic_fsm2 を同じ入力で回し、毎クロック比べる。
// あわせて、状態遷移図の 5 本の矢印がそれぞれ何回通ったかを数える
module tb_fsm2;
    reg clk;
    initial clk = 1'b0;
    reg rst = 1'b1;
    reg btn = 1'b0;

    wire r1, y1, g1, w1, r2, y2, g2, w2;
    wire [1:0] s1, s2;
    wire [9:0] t1;   // 比べない (timer の中身は書き方で違ってよい)
    wire       q1;

    traffic_fsm  #(.GREEN_TIME(5), .YELLOW_TIME(2), .RED_TIME(3), .WALK_TIME(4)) old_fsm (
        .clk(clk), .rst(rst), .btn(btn),
        .red(r1), .yellow(y1), .green(g1), .walk(w1),
        .o_state(s1), .o_timer(t1), .o_btn_req(q1));
    traffic_fsm2 #(.GREEN_TIME(5), .YELLOW_TIME(2), .RED_TIME(3), .WALK_TIME(4)) new_fsm (
        .clk(clk), .rst(rst), .btn(btn),
        .red(r2), .yellow(y2), .green(g2), .walk(w2), .state(s2));

    always #1 clk = ~clk;

    integer cyc = 0, errors = 0;
    integer gy = 0, yr = 0, yw = 0, rg = 0, wg = 0, other = 0;
    reg [1:0] prev;

    initial begin
        repeat (2) @(posedge clk);
        rst = 1'b0;
        prev = s2;
        repeat (100000) begin
            @(negedge clk);
            btn = ($random % 16) == 0;          // 16 クロックに 1 回ほど押す
            @(posedge clk); #0.1;
            cyc = cyc + 1;
            if ({s1, r1, y1, g1, w1} !== {s2, r2, y2, g2, w2}) begin
                errors = errors + 1;
                if (errors < 5) $display("NG cycle %0d: old %b new %b", cyc,
                                         {s1, r1, y1, g1, w1}, {s2, r2, y2, g2, w2});
            end
            if (s2 != prev)
                case ({prev, s2})
                    4'b00_01: gy = gy + 1;
                    4'b01_10: yr = yr + 1;
                    4'b01_11: yw = yw + 1;
                    4'b10_00: rg = rg + 1;
                    4'b11_00: wg = wg + 1;
                    default:  other = other + 1;
                endcase
            prev = s2;
        end
        $display("cycles %0d, mismatches %0d", cyc, errors);
        $display("arrows: GREEN->YELLOW %0d, YELLOW->RED %0d, YELLOW->WALK %0d, RED->GREEN %0d, WALK->GREEN %0d, other %0d",
                 gy, yr, yw, rg, wg, other);
        if (errors == 0 && other == 0 && gy > 0 && yr > 0 && yw > 0 && rg > 0 && wg > 0)
            $display("PASS");
        else
            $display("FAIL");
        $finish;
    end
endmodule

