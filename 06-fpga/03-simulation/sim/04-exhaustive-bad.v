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
// adder4_ripple.v  (full_adder と half_adder は 1-6 のもの)
module adder4_ripple (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout
);
    wire c1, c2, c3;
    full_adder u_fa0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(c1));
    full_adder u_fa1 (.a(a[1]), .b(b[1]), .cin(c1),  .sum(sum[1]), .cout(c2));
    full_adder u_fa2 (.a(a[2]), .b(b[2]), .cin(c1),  .sum(sum[2]), .cout(c3));
    full_adder u_fa3 (.a(a[3]), .b(b[3]), .cin(c3),  .sum(sum[3]), .cout(cout));
endmodule
// adder4_plus.v
module adder4_plus (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout
);
    wire [4:0] total = {1'b0, a} + {1'b0, b} + {4'b0, cin};   // 5 ビットに揃えて足す
    assign {cout, sum} = total;
endmodule
// adder4_cmp.v  2 つの加算器に同じ入力を入れ、出力が同じかを same に出す
module adder4_cmp (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout,
    output wire       same
);
    wire [3:0] sum_p;
    wire       cout_p;
    adder4_ripple u_ripple (.a(a), .b(b), .cin(cin), .sum(sum),   .cout(cout));
    adder4_plus   u_plus   (.a(a), .b(b), .cin(cin), .sum(sum_p), .cout(cout_p));
    assign same = ({cout, sum} == {cout_p, sum_p});
endmodule
