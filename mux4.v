module mux4(out, in0, in1, in2, in3, sel);

input [1:0] sel;
input [31:0] in0, in1, in2, in3;
output [31:0] out;

assign out = sel[1] ? (sel[0] ? in3 : in2) : (sel[0] ? in1 : in0);

endmodule