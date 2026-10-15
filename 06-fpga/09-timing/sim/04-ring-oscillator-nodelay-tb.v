module tb_ring_nodelay;
    reg en = 0;
    wire div_out;
    top_ring #(.N(5), .K(10)) u (.en(en), .div_out(div_out));
    initial begin
        #10 en = 1;
        #1000 $display("done");
        $finish;
    end
endmodule
