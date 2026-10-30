module top (
  input clock,
  input reset,

  input [31:0] instruction,
  output [31:0] wb_data
);

wire [4:0] read_sel1;
wire [4:0] read_sel2;
wire [4:0] write_sel;
wire wEn;
wire wb_sel;
wire [31:0] imm32;
wire op_B_sel;
wire [5:0] ALU_Control;
wire mem_wEn;
wire [31:0] read_data1;
wire [31:0] read_data2;
wire [31:0] operand_B;
wire [31:0] ALU_result;
wire [15:0] mem_address;
wire [31:0] mem_read_data;
assign operand_B = op_B_sel ? imm32 : read_data2;
assign mem_address = ALU_result[15:0];
assign wb_data = wb_sel ? mem_read_data : ALU_result;

decode decode_inst (
  .instruction(instruction),
  .wb_sel(wb_sel),
  .read_sel1(read_sel1),
  .read_sel2(read_sel2),
  .write_sel(write_sel),
  .wEn(wEn),
  .imm32(imm32),
  .op_B_sel(op_B_sel),
  .ALU_Control(ALU_Control),
  .mem_wEn(mem_wEn)
);


regFile regFile_inst (
  .clock(clock),
  .reset(reset),
  .wEn(wEn), // Write Enable
  .write_data(wb_data),
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

memory mem_inst (
  .clock(clock),
  .wEn(mem_wEn),
  .address(mem_address),
  .write_data(read_data2),
  .read_data(mem_read_data)
);

endmodule
