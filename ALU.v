module ALU (
  input [5:0]  ALU_Control,
  input [31:0] operand_A,
  input [31:0] operand_B,
  output [31:0] ALU_result
);

localparam ALU_ADD = 6'b000000;
localparam ALU_SUB = 6'b001000;
localparam ALU_SLT = 6'b000010;
localparam ALU_XOR = 6'b000100;
localparam ALU_AND = 6'b000111;

reg [31:0] result;

always @(*) begin
  case (ALU_Control)
    ALU_ADD: result = operand_A + operand_B;
    ALU_SUB: result = operand_A - operand_B;
    ALU_SLT: result = ($signed(operand_A) < $signed(operand_B)) ? 32'd1 : 32'd0;
    ALU_XOR: result = operand_A ^ operand_B;
    ALU_AND: result = operand_A & operand_B;
    default: result = 32'd0;
  endcase
end

assign ALU_result = result;

endmodule

