module memory(clk, wr, iaddr, inst, daddr, data_in, data_out);

parameter size =  2048 + 512 * 512;

input clk, wr;
input [31:2] iaddr, daddr;
input [63:0] data_in;
output [31:0] inst;
output [63:0] data_out;

reg [31:0] mem [0:size - 1];

assign inst = mem[iaddr];
assign data_out = {mem[daddr + 1], mem[daddr]};

always @ (negedge clk)
begin
	if(wr)
        mem[daddr] = data_in;
end

endmodule