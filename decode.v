module decode (
  input [31:0] instruction,
  output [4:0] read_sel1,
  output [4:0] read_sel2,
  output [4:0] write_sel,
  output wb_sel,
  output wEn,
  output [31:0] imm32,
  output op_B_sel,
  output [5:0] ALU_Control,
  output mem_wEn

);

localparam [6:0] R_TYPE = 7'b0110011;
localparam [6:0] I_TYPE = 7'b0010011; // Note: this is not the opcode for all
                                      // I-Type instructions, only the
                                      // arithmatic ones. Other I-Type
                                      // instructions  (like load word) exist.
localparam [6:0] STORE  = 7'b0100011;
localparam [6:0] LOAD   = 7'b0000011;

wire [6:0] opcode;
wire [6:0] funct7;
wire [2:0] funct3;

wire [11:0] imm12;
wire [11:0] i_imm; // Immidiate for I-Type instructions
wire [11:0] s_imm; // Immidiate for S-Type instructions

assign opcode = instruction[6:0];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];

// Sign extension
assign imm32 = { {20{imm12[11]}}, imm12};

assign read_sel1 = instruction[19:15];
assign read_sel2 = instruction[24:20];
assign write_sel = instruction[11:7];

localparam [5:0] ALU_ADD = 6'b000000;
localparam [5:0] ALU_SUB = 6'b001000;
localparam [5:0] ALU_SLT = 6'b000010;
localparam [5:0] ALU_XOR = 6'b000100;
localparam [5:0] ALU_AND = 6'b000111;

reg [5:0] alu_ctrl;
reg [11:0] imm_sel;

assign i_imm = instruction[31:20];
assign s_imm = {instruction[31:25], instruction[11:7]};

always @(*) begin
  case (opcode)
    I_TYPE:  imm_sel = i_imm; 
    LOAD:    imm_sel = i_imm;
    STORE:   imm_sel = s_imm;
    default: imm_sel = 12'd0;
  endcase
end

assign imm12 = imm_sel;
assign wEn = (opcode == R_TYPE) || (opcode == I_TYPE) || (opcode == LOAD);
assign mem_wEn = (opcode == STORE);
assign wb_sel = (opcode == LOAD);
assign op_B_sel = (opcode == I_TYPE) || (opcode == LOAD) || (opcode == STORE);

always @(*) begin
  if (opcode == R_TYPE) begin
    case (funct3)
      3'b000:  alu_ctrl = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
      3'b010:  alu_ctrl = ALU_SLT;
      3'b100:  alu_ctrl = ALU_XOR;
      3'b111:  alu_ctrl = ALU_AND;
      default: alu_ctrl = ALU_ADD;
    endcase
  end
  else begin
    alu_ctrl = ALU_ADD;
  end
end

assign ALU_Control = alu_ctrl;

endmodule
