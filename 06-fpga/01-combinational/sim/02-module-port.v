// my_xor.v
module my_xor (
    input  wire a,
    input  wire b,
    output wire y
);
    wire a_or_b  = a | b;
    wire a_and_b = a & b;
    assign y = a_or_b & ~a_and_b;
endmodule

// parity3.v
module parity3 (
    input  wire a,
    input  wire b,
    input  wire c,
    output wire y
);
    wire ab;
    my_xor u_ab (.a(a),  .b(b), .y(ab));
    my_xor u_y  (.a(ab), .b(c), .y(y));
endmodule
