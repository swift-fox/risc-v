module regfile(clk, wr, out1, out2, in, rs1, rs2, rd);

input clk, wr;
input [4:0] rd, rs1, rs2;
input [31:0] in;
output [31:0] out1, out2;

reg [31:0] regs [1:31];

assign out1 = sel1 ? regs[rs1] : 32'b0;
assign out2 = sel2 ? regs[rs2] : 32'b0;

always @ (negedge clk)
begin
    if(wr && rd) regs[rd] = in;
end

endmodule