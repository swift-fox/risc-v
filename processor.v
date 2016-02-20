module processor(_reset, clk);

input _reset, clk;

wire br_taken, reg_wr, mem_wr, alu_op_sel;
wire [31:2] iaddr, mem_addr;
wire [31:0] inst, ctl_data_in, ctl_data_out, rs1, rs2, rd, alu_out, alu_in1, lsu_reg_out;
wire [4:0] rd_sel, rs1_sel, rs2_sel;
wire [1:0] reg_in_sel;
wire [3:0] alu_func, lsu_func;
wire [2:0] br_func;
wire [63:0] mem_out, mem_in;

controller c(_reset, clk, iaddr, inst, br_taken, rd_sel, rs1_sel, rs2_sel, reg_wr, mem_wr,
    alu_op_sel, reg_in_sel, alu_func, lsu_func, br_func, ctl_data_in, ctl_data_out);

alu a(alu_out, rs1, alu_in1, alu_func);
regfile r(clk, reg_wr, rs1, rs2, rd, rs1_sel, rs2_sel, rd_sel);
lsu l(lsu_func, rs1, ctl_data_out, lsu_reg_out, rs2, mem_out, mem_in);
branch b(br_taken, rs1, rs2, br_func);

mux2 alu_op(alu_in1, rs2, ctl_data_out, alu_op_sel);
mux4 reg_in(rd, alu_out, ctl_data_out, lsu_reg_out, 32'b0, reg_in_sel);

memory m(clk, mem_wr, iaddr, inst, mem_addr, mem_out, mem_in);

endmodule