module lsu(func, base, offset, reg_out, reg_in, addr, mem_out, mem_in);

input [3:0] func;
input [31:0] base, reg_in;
input [63:0] mem_in;
input [11:0] offset;
output [31:2] addr;
output [31:0] reg_out;
output [63:0] mem_out;

reg [31:0] reg_out;
reg [63:0] mem_out;

`define lb  4'b0000
`define lh  4'b0001
`define lw  4'b0010
`define lbu 4'b0100
`define lhu 4'b0101
`define sb  4'b1000
`define sh  4'b1001
`define sw  4'b1010

wire [31:2] addr;
wire [1:0] byte_index;
wire [5:0] shift;
wire [63:0] sh_r, sh_w, mask_b, mask_h, mask_w;

assign {addr, byte_index} = base + {{21{offset[11]}}, offset[10:0]};

assign shift = byte_index << 3;
assign sh_r = mem_in >> shift;
assign sh_w = {32'b0, reg_in} << shift;

assign mask_b = 64'hff << shift;
assign mask_h = 64'hffff << shift;
assign mask_w = 64'hffffffff << shift;

always @ (*)
begin
    case(func)
    `lb:  reg_out = {{24{sh_r[7]}}, sh_r[7:0]};
    `lh:  reg_out = {{16{sh_r[15]}}, sh_r[15:0]};
    `lw:  reg_out = sh_r[31:0];
    `lbu: reg_out = {24'b0, sh_r[7:0]};
    `lhu: reg_out = {16'b0, sh_r[15:0]};
    `sb:  mem_out = (sh_w & mask_b) | (mem_in & ~mask_b);
    `sh:  mem_out = (sh_w & mask_h) | (mem_in & ~mask_h);
    `sw:  mem_out = (sh_w & mask_w) | (mem_in & ~mask_w);
    endcase
end

endmodule