module branch(out, in0, in1, func);

input [31:0] in0, in1;
input [2:0] func;
output out;

reg out;

`define eq  3'b000
`define ne  3'b001
`define lt  3'b100
`define ge  3'b101
`define ltu 3'b110
`define geu 3'b111

always @ (*)
begin
    case(func)
    `eq:  out = (in0 == in1);
    `ne:  out = (in0 != in1);
    `lt:  out = ($signed(in0) < $signed(in1));
    `ge:  out = ($signed(in0) >= $signed(in1));
    `ltu: out = (in0 < in1);
    `geu: out = (in0 >= in1);
    default: out = 1'b0;
    endcase
end

endmodule