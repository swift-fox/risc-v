module dcache(clk, wr, addr, in, out);

parameter size =  512 * 512;

input clk, wr;
input [31:2] addr;
input [63:0] in;
output [63:0] out;

reg [31:0] mem [0:size - 1];

assign out = {mem[addr + 1], mem[addr]};

always @ (negedge clk)
begin
	if(wr)
        mem[addr] = in;
end

initial
begin
	$readmemh("data.hex", mem);
end

endmodule