module system();

reg _reset, clk; 

always #1 clk = ~clk;

processor c(_reset, clk);

initial
begin
    $dumpfile("debug.vcd");
    $dumpvars;
    $readmemh("mem.hex", c.m.mem);

    _reset = 0;
    clk = 1;
    #1
    _reset = 1;

    #1000
    $writememh("dump.hex", c.m.mem);
    $finish;
end

endmodule