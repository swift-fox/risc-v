module controller(
    _reset, clk,
    iaddr, inst, br_taken,
    rd, rs1, rs2,
    reg_wr, mem_wr,
    alu_op_sel, reg_in_sel,
    alu_func, lsu_func, br_func,
    data_in, data_out
);

input _reset, clk, br_taken;
input [31:0] inst, data_in;
output [31:2] iaddr;
output [31:0] data_out;
output [4:0] rd, rs1, rs2;
output reg_wr, mem_wr, alu_op_sel;
output [1:0] reg_in_sel;
output [3:0] alu_func, lsu_func;
output [2:0] br_func;

/**
    Break down the instruction into parts.
*/
wire [6:0] opcode;
wire [4:0] rs1, rs2, rd;
wire [2:0] funct3;
wire [6:0] funct7;
wire [31:0] imm_i, imm_s, imm_sb, imm_u, imm_uj, shamt;

assign opcode = inst[6:0];
assign rs1    = inst[19:15];
assign rs2    = inst[24:20];
assign rd     = inst[11:7];
assign funct3 = inst[14:12];
assign funct7 = inst[31:25];

// Extract the immediate number from different instruction types
assign imm_i  = {{21{inst[31]}}, inst[30:20]};
assign imm_s  = {{21{inst[31]}}, inst[30:25], inst[11:7]};
assign imm_sb = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
assign imm_u  = {inst[31:12], 12'b0};
assign imm_uj = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
assign shamt  = {27'b0, inst[24:20]};

/**
    Setup controlling signals according to the instruction
*/
`define op_imm   7'b0010011
`define op_reg   7'b0110011
`define op_ld    7'b0000011
`define op_st    7'b0100011
`define op_br    7'b1100011
`define op_lui   7'b0110111
`define op_auipc 7'b0010111
`define op_jal   7'b1101111
`define op_jalr  7'b1100111

`define func_sl  3'b001
`define func_sr  3'b101

`define alu_op_reg 1'b0
`define alu_op_ctl 1'b1

`define reg_in_alu 2'b00
`define reg_in_ctl 2'b01
`define reg_in_lsu 2'b10

`define ni_next 2'b00
`define ni_br   2'b01
`define ni_jal  2'b10
`define ni_jalr 2'b11

// Controlling signals
reg reg_wr, mem_wr;
reg alu_op_sel;
reg [1:0] reg_in_sel, next_inst;
reg [3:0] alu_func, lsu_func;
reg [2:0] br_func;
reg [31:0] data_out;

always @ (*)
begin
    /* Reset important signals */
    next_inst = `ni_next;
    reg_wr = 1;
    mem_wr = 0;
    
    /* Set up controlling signals */
    case(opcode)
    `op_imm: begin
        reg_in_sel = `reg_in_alu;
        alu_op_sel = `alu_op_ctl;

        if(funct3 == `func_sr)  // srli, srai
            alu_func = {funct7[5], funct3};
        else    // addi, slti, sltiu, xori, ori, andi, slli
            alu_func = {1'b0, funct3};

        if(funct3 == `func_sr || funct3 == `func_sl)    // slli, srli, srai
            data_out = shamt;
        else    // addi, slti, sltiu, xori, ori, andi
            data_out = imm_i;
    end
    `op_reg: begin  // add, sub, sll, slt, sltu, xor, srl, sra, or, and
        reg_in_sel = `reg_in_alu;
        alu_op_sel = `alu_op_reg;
        alu_func = {funct7[5], funct3};
    end
    `op_ld: begin
        reg_in_sel = `reg_in_lsu;
        lsu_func = {1'b0, funct3};
        data_out = imm_i;
    end
    `op_st: begin
        reg_wr = 0;
        mem_wr = 1;
        lsu_func = {1'b1, funct3};
        data_out = imm_s;
    end
    `op_br: begin
        reg_wr = 0;
        br_func = funct3;
        next_inst = `ni_br;
    end
    `op_lui: begin
        reg_in_sel = `reg_in_ctl;
        data_out = imm_u;
    end
    `op_auipc: begin
        reg_in_sel = `reg_in_ctl;
        data_out = pc + imm_u;
    end
    `op_jal: begin
        reg_in_sel = `reg_in_ctl;
        data_out = pc + 4;
        next_inst = `ni_jal;
    end
    `op_jalr: begin
        reg_in_sel = `reg_in_ctl;
        data_out = pc + 4;
        next_inst = `ni_jalr;
    end
	default:
		reg_wr = 0;
	endcase
end

/**
    Program counter. Adjusts according to the instruction.
*/
reg [31:0] pc;

assign iaddr = pc[31:2];

always @ (clk)
begin
    if(clk)
    begin
        if(~_reset)
            pc = 32'b0;
        else
            case(next_inst)
            default:  pc = pc + 4;
            `ni_br:   pc = br_taken ? pc + imm_sb : pc + 4;
            `ni_jal:  pc = pc + imm_uj;
            `ni_jalr: pc = data_in + imm_i & 32'hfffffffe;
            endcase
    end
end

endmodule