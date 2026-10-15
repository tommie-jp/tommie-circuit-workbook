// half_adder.v
module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule

// full_adder.v
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    wire s1, c1, c2;
    half_adder u_ha1 (.a(a),  .b(b),   .sum(s1),  .carry(c1));
    half_adder u_ha2 (.a(s1), .b(cin), .sum(sum), .carry(c2));
    assign cout = c1 | c2;
endmodule

// adder_n.v  幅 N を変えられる加算器。USE_PLUS で、全加算器を並べる版と + の版を選ぶ
module adder_n #(
    parameter N        = 4,
    parameter USE_PLUS = 0
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] sum,
    output wire         cout
);
    generate
        if (USE_PLUS != 0) begin : g_plus
            wire [N:0] total = {1'b0, a} + {1'b0, b} + {{N{1'b0}}, cin};
            assign {cout, sum} = total;
        end else begin : g_ripple
            wire [N:0] c;
            assign c[0] = cin;
            genvar i;
            for (i = 0; i < N; i = i + 1) begin : g_fa
                full_adder u_fa (.a(a[i]), .b(b[i]), .cin(c[i]), .sum(sum[i]), .cout(c[i+1]));
            end
            assign cout = c[N];
        end
    endgenerate
endmodule

// adder_param_cmp.v  幅 4 と幅 8 の加算器を、全加算器の版と + の版で作り、答えを比べる
module adder_param_cmp (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire       cin,
    output wire [7:0] sum8,      // 幅 8、全加算器の版
    output wire       cout8,
    output wire [3:0] sum4,      // 幅 4、全加算器の版 (a と b の下位 4 ビット)
    output wire       cout4,
    output wire       same4,     // 幅 4 の 2 つの版が一致
    output wire       same8      // 幅 8 の 2 つの版が一致
);
    wire [7:0] sum8_p;
    wire       cout8_p;
    wire [3:0] sum4_p;
    wire       cout4_p;

    adder_n #(.N(8), .USE_PLUS(0)) u_r8 (.a(a),      .b(b),      .cin(cin), .sum(sum8),   .cout(cout8));
    adder_n #(.N(8), .USE_PLUS(1)) u_p8 (.a(a),      .b(b),      .cin(cin), .sum(sum8_p), .cout(cout8_p));
    adder_n #(.N(4), .USE_PLUS(0)) u_r4 (.a(a[3:0]), .b(b[3:0]), .cin(cin), .sum(sum4),   .cout(cout4));
    adder_n #(.N(4), .USE_PLUS(1)) u_p4 (.a(a[3:0]), .b(b[3:0]), .cin(cin), .sum(sum4_p), .cout(cout4_p));

    assign same8 = ({cout8, sum8} == {cout8_p, sum8_p});
    assign same4 = ({cout4, sum4} == {cout4_p, sum4_p});
endmodule
