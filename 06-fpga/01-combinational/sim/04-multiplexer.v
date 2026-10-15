// mux2.v
module mux2 (
    input  wire       sel,
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [3:0] y
);
    assign y = sel ? b : a;   // sel が 1 なら b、0 なら a
endmodule
