module alu(out, in0, in1, func);

input [31:0] in0, in1;
input [3:0] func;
output [31:0] out;

reg [31:0] out;

`define add  4'b0000
`define sub  4'b1000
`define sll  4'b0001
`define slt  4'b0010
`define sltu 4'b0011
`define _xor 4'b0100
`define srl  4'b0101
`define sra  4'b1101
`define _or  4'b0110
`define _and 4'b0111

always @ (func, in0, in1)
begin
    case(func)
    `add:  out = in0 + in1;
    `sub:  out = in0 - in1;
    `sll:  out = in0 << in1;
    `slt:  out = $signed(in0) < $signed(in1);
    `sltu: out = in0 < in1;
    `_xor: out = in0 ^ in1;
    `srl:  out = in0 >> in1;
    `sra:  out = in0 >>> in1;
    `_or:  out = in0 | in1;
    `_and: out = in0 & in1;
    default: out = 32'b0;
    endcase
end

endmodule