module mux2(out, in0, in1, sel);

input sel;
input [31:0] in0, in1;
output [31:0] out;

assign out = sel ? in1 : in0;

endmodule