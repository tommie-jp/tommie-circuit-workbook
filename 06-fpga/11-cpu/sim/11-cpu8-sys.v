// cpu8_sys.v  cpu8 に 256 語のメモリをつないだ物 (11-11)。中身は $readmemh で読む (+rom=<名前> で替えられる)
module cpu8_sys #(parameter ROMFILE = "11-sum.hex") (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] in_port,
    output wire [7:0] out_port,
    output wire       out_stb,
    output wire       halted,
    output wire [7:0] pc_out,
    output wire [1:0] state_out
);
    reg  [7:0] mem [0:255];
    wire [7:0] addr, wdata;
    wire       we;
    reg  [8*256-1:0] fname;
    initial begin
        if ($value$plusargs("rom=%s", fname)) $readmemh(fname, mem);
        else                                  $readmemh(ROMFILE, mem);
    end
    always @(posedge clk) if (we) mem[addr] <= wdata;
    cpu8 cpu (.clk(clk), .rst(rst), .addr(addr), .rdata(mem[addr]), .wdata(wdata), .we(we),
              .in_port(in_port), .out_port(out_port), .out_stb(out_stb), .halted(halted),
              .pc_out(pc_out), .state_out(state_out));
endmodule
