module icache(addr, data);

parameter size = 1024;

input [31:2] addr;
output [31:0] data;

reg [31:0] mem [0:size - 1];

assign data = mem[addr];

initial
begin
	$readmemb("inst.bin", mem);
end

endmodule