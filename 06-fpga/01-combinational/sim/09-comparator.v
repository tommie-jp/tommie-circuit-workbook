// cmp1.v  1 ビットの比較器
module cmp1 (
    input  wire a,
    input  wire b,
    output wire eq,    // a == b
    output wire gt,    // a > b
    output wire lt     // a < b
);
    assign eq = ~(a ^ b);
    assign gt = a & ~b;
    assign lt = ~a & b;
endmodule

// cmp4_bits.v  1 ビットの比較器を 4 つ並べ、上の桁から順に決める 4 ビットの比較器
module cmp4_bits (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire       eq,
    output wire       gt,
    output wire       lt
);
    wire [3:0] e;
    wire [3:0] g;
    wire [3:0] l;
    cmp1 u3 (.a(a[3]), .b(b[3]), .eq(e[3]), .gt(g[3]), .lt(l[3]));
    cmp1 u2 (.a(a[2]), .b(b[2]), .eq(e[2]), .gt(g[2]), .lt(l[2]));
    cmp1 u1 (.a(a[1]), .b(b[1]), .eq(e[1]), .gt(g[1]), .lt(l[1]));
    cmp1 u0 (.a(a[0]), .b(b[0]), .eq(e[0]), .gt(g[0]), .lt(l[0]));

    assign eq = e[3] & e[2] & e[1] & e[0];
    // 上の桁が等しいあいだだけ、下の桁の大小が効く
    assign gt = g[3] | (e[3] & g[2]) | (e[3] & e[2] & g[1]) | (e[3] & e[2] & e[1] & g[0]);
    assign lt = l[3] | (e[3] & l[2]) | (e[3] & e[2] & l[1]) | (e[3] & e[2] & e[1] & l[0]);
endmodule

// cmp4_op.v  比較演算子で書いた 4 ビットの比較器
module cmp4_op (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire       eq,
    output wire       gt,
    output wire       lt
);
    assign eq = (a == b);
    assign gt = (a >  b);
    assign lt = (a <  b);
endmodule

// cmp4_cmp.v  2 つの比較器に同じ入力を入れ、3 本とも同じなら same を 1 にする
module cmp4_cmp (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire       eq,
    output wire       gt,
    output wire       lt,
    output wire       same
);
    wire eq_p;
    wire gt_p;
    wire lt_p;
    cmp4_bits u_bits (.a(a), .b(b), .eq(eq),   .gt(gt),   .lt(lt));
    cmp4_op   u_op   (.a(a), .b(b), .eq(eq_p), .gt(gt_p), .lt(lt_p));
    assign same = ({eq, gt, lt} == {eq_p, gt_p, lt_p});
endmodule
