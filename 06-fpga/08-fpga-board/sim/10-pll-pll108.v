module pll108(
        input  clock_in,
        output clock_out,
        output locked
    );

    rPLL #(
        .FCLKIN("27.0"),
        .IDIV_SEL(0), // -> PFD = 27.0 MHz (range: 3-400 MHz)
        .FBDIV_SEL(3), // -> CLKOUT = 108.0 MHz (range: 3.125-600 MHz)
        .ODIV_SEL(4) // -> VCO = 432.0 MHz (range: 400-1200 MHz)
    ) pll (.CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), .RESET(1'b0), .RESET_P(1'b0), .CLKFB(1'b0), .FBDSEL(6'b0), .IDSEL(6'b0), .ODSEL(6'b0), .PSDA(4'b0), .DUTYDA(4'b0), .FDLY(4'b0),
        .CLKIN(clock_in), // 27.0 MHz
        .CLKOUT(clock_out), // 108.0 MHz
        .LOCK(locked)
    );

endmodule
