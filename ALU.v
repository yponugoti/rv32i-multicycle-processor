module ALU (
  input branch_op,
  input [5:0]  ALU_Control,
  input [31:0] operand_A,
  input [31:0] operand_B,
  output [31:0] ALU_result,
  output branch
);

localparam ALU_ADD = 6'b000000;
localparam ALU_SLL = 6'b000001;
localparam ALU_SLT = 6'b000010;
localparam ALU_SLTU = 6'b000011;
localparam ALU_XOR = 6'b000100;
localparam ALU_SRL = 6'b000101;
localparam ALU_OR  = 6'b000110;
localparam ALU_AND = 6'b000111;
localparam ALU_SUB = 6'b001000;
localparam ALU_SRA = 6'b001101;
localparam ALU_BEQ = 6'b010000;
localparam ALU_BNE = 6'b010001;
localparam ALU_BLT = 6'b010100;
localparam ALU_BGE = 6'b010101;
localparam ALU_BLTU = 6'b010110;
localparam ALU_BGEU = 6'b010111;
localparam ALU_JAL = 6'b011111;
localparam ALU_JALR = 6'b111111;

wire equal;
wire less_signed;
wire less_unsigned;

assign equal = (operand_A == operand_B);
assign less_signed = ($signed(operand_A) < $signed(operand_B));
assign less_unsigned = (operand_A < operand_B);

wire [4:0] shamt;
assign shamt = operand_B[4:0];

reg [31:0] result;
reg branch_cond;

always @(*) begin
  branch_cond = 1'b0;
  case (ALU_Control)
    ALU_ADD: result = operand_A + operand_B;
    ALU_SUB: result = operand_A - operand_B;
    ALU_SLL: result = operand_A << shamt;
    ALU_SRL: result = operand_A >> shamt;
    ALU_SRA: result = $signed(operand_A) >>> shamt;
    ALU_SLT: result = {31'd0, less_signed};
    ALU_SLTU: result = {31'd0, less_unsigned};
    ALU_XOR: result = operand_A ^ operand_B;
    ALU_OR: result = operand_A | operand_B;
    ALU_AND: result = operand_A & operand_B;
    ALU_BEQ: begin branch_cond = equal; result = {31'd0, branch_cond}; end
    ALU_BNE: begin branch_cond = !equal; result = {31'd0, branch_cond}; end
    ALU_BLT: begin branch_cond = less_signed; result = {31'd0, branch_cond}; end
    ALU_BGE: begin branch_cond = !less_signed; result = {31'd0, branch_cond}; end
    ALU_BLTU: begin branch_cond = less_unsigned; result = {31'd0, branch_cond}; end
    ALU_BGEU: begin branch_cond = !less_unsigned; result = {31'd0, branch_cond}; end
    ALU_JAL: result = operand_A;
    ALU_JALR: result = operand_A;
    default: result = 32'd0;
  endcase
end

assign ALU_result = result;
assign branch = branch_op && branch_cond;

endmodule
