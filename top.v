module top (
  input clock,
  input reset,

  input [31:0] instruction,
  input [5:0] ALU_Control,
  input op_B_sel,
  input wEn,

  output [31:0] ALU_result
);


wire [4:0] read_sel1;
wire [4:0] read_sel2;
wire [4:0] write_sel;

wire [31:0] imm;

assign read_sel1 = instruction[19:15];
assign read_sel2 = instruction[24:20];
assign write_sel = instruction[11:7];

// Sign extension
assign imm = { {20{instruction[31]}}, instruction[31:20]};

wire unused_instr_bits = &{1'b0, instruction[14:12], instruction[6:0]};
wire [31:0] read_data1;
wire [31:0] read_data2;
wire [31:0] operand_B;
assign operand_B = op_B_sel ? imm : read_data2;

regFile regFile_inst (
  .clock(clock),
  .reset(reset),
  .wEn(wEn), // Write Enable
  .write_data(ALU_result),
  .read_sel1(read_sel1),
  .read_sel2(read_sel2),
  .write_sel(write_sel),
  .read_data1(read_data1),
  .read_data2(read_data2)
);


ALU alu_inst(
  .ALU_Control(ALU_Control),
  .operand_A(read_data1),
  .operand_B(operand_B),
  .ALU_result(ALU_result)
);


endmodule

