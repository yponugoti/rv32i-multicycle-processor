module decode #(
  parameter ADDRESS_BITS = 16
) (
  // Inputs from Fetch
  input [ADDRESS_BITS-1:0] PC,
  input [31:0] instruction,

  // Inputs from Execute/ALU
  input [ADDRESS_BITS-1:0] JALR_target,
  input branch,

  // Outputs to Fetch
  output next_PC_select,
  output [ADDRESS_BITS-1:0] target_PC,

  // Outputs to Reg File
  output [4:0] read_sel1,
  output [4:0] read_sel2,
  output [4:0] write_sel,
  output wEn,

  // Outputs to Execute/ALU
  output branch_op, // Tells ALU if this is a branch instruction
  output [31:0] imm32,
  output [1:0] op_A_sel,
  output op_B_sel,
  output [5:0] ALU_Control,

  // Outputs to Memory
  output mem_wEn,

  // Outputs to Writeback
  output wb_sel
);

localparam [6:0]R_TYPE  = 7'b0110011,
                I_TYPE  = 7'b0010011,
                STORE   = 7'b0100011,
                LOAD    = 7'b0000011,
                BRANCH  = 7'b1100011,
                JALR    = 7'b1100111,
                JAL     = 7'b1101111,
                AUIPC   = 7'b0010111,
                LUI     = 7'b0110111;


// These are internal wires that I used. You can use them but you do not have to.
// Wires you do not use can be deleted.
wire[6:0]  s_imm_msb;
wire[4:0]  s_imm_lsb;
wire[19:0] u_imm;
wire[11:0] i_imm_orig;
wire[19:0] uj_imm;
wire[11:0] s_imm_orig;
wire[12:0] sb_imm_orig;

wire[31:0] sb_imm_32;
wire[31:0] u_imm_32;
wire[31:0] i_imm_32;
wire[31:0] s_imm_32;
wire[31:0] uj_imm_32;

wire [6:0] opcode;
wire [6:0] funct7;
wire [2:0] funct3;
wire [1:0] extend_sel;
wire [ADDRESS_BITS-1:0] branch_target;
wire [ADDRESS_BITS-1:0] JAL_target;

// Read registers
assign read_sel2  = instruction[24:20];
assign read_sel1  = instruction[19:15];

/* Instruction decoding */
assign opcode = instruction[6:0];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];

/* Write register */
assign write_sel = instruction[11:7];

localparam [5:0] ALU_ADD = 6'b000000;
localparam [5:0] ALU_SLL = 6'b000001;
localparam [5:0] ALU_SLT = 6'b000010;
localparam [5:0] ALU_SLTU = 6'b000011;
localparam [5:0] ALU_XOR = 6'b000100;
localparam [5:0] ALU_SRL = 6'b000101;
localparam [5:0] ALU_OR = 6'b000110;
localparam [5:0] ALU_AND = 6'b000111;
localparam [5:0] ALU_SUB = 6'b001000;
localparam [5:0] ALU_SRA = 6'b001101;
localparam [5:0] ALU_BEQ = 6'b010000;
localparam [5:0] ALU_BNE = 6'b010001;
localparam [5:0] ALU_BLT = 6'b010100;
localparam [5:0] ALU_BGE = 6'b010101;
localparam [5:0] ALU_BLTU = 6'b010110;
localparam [5:0] ALU_BGEU = 6'b010111;
localparam [5:0] ALU_JAL = 6'b011111;
localparam [5:0] ALU_JALR = 6'b111111;

assign i_imm_orig = instruction[31:20];
assign s_imm_msb = instruction[31:25];
assign s_imm_lsb = instruction[11:7];
assign s_imm_orig = {s_imm_msb, s_imm_lsb};
assign sb_imm_orig = {instruction[31], instruction[7], instruction[30:25],
                      instruction[11:8], 1'b0};
assign u_imm = instruction[31:12];
assign uj_imm = {instruction[31], instruction[19:12], instruction[20],
                 instruction[30:21]};
assign i_imm_32 = {{20{i_imm_orig[11]}}, i_imm_orig};
assign s_imm_32 = {{20{s_imm_orig[11]}}, s_imm_orig};
assign sb_imm_32 = {{19{sb_imm_orig[12]}}, sb_imm_orig};
assign u_imm_32 = {u_imm, 12'd0};
assign uj_imm_32 = {{11{uj_imm[19]}}, uj_imm, 1'b0};

reg [31:0] imm_sel;

always @(*) begin
  case (opcode)
    I_TYPE: imm_sel = i_imm_32;
    LOAD: imm_sel = i_imm_32;
    JALR: imm_sel = i_imm_32;
    STORE: imm_sel = s_imm_32;
    BRANCH: imm_sel = sb_imm_32;
    LUI: imm_sel = u_imm_32;
    AUIPC: imm_sel = u_imm_32;
    JAL: imm_sel = uj_imm_32;
    default: imm_sel = 32'd0;
  endcase
end

assign imm32 = imm_sel;
assign wEn = (opcode == R_TYPE) || (opcode == I_TYPE) || (opcode == LOAD) ||
             (opcode == JAL)    || (opcode == JALR)   ||
             (opcode == LUI)    || (opcode == AUIPC);
assign mem_wEn = (opcode == STORE);
assign wb_sel = (opcode == LOAD);
assign branch_op = (opcode == BRANCH);
assign op_B_sel = (opcode == I_TYPE) || (opcode == LOAD) || (opcode == STORE) ||
                  (opcode == LUI)    || (opcode == AUIPC);

reg [1:0] a_sel;

always @(*) begin
  case (opcode)
    AUIPC: a_sel = 2'd1;
    JAL: a_sel = 2'd2;
    JALR: a_sel = 2'd2;
    LUI: a_sel = 2'd3;
    default: a_sel = 2'd0;
  endcase
end

assign op_A_sel = a_sel;
assign branch_target = PC + sb_imm_32[ADDRESS_BITS-1:0];
assign JAL_target = PC + uj_imm_32[ADDRESS_BITS-1:0];

reg [ADDRESS_BITS-1:0] target;

always @(*) begin
  case (opcode)
    BRANCH: target = branch_target;
    JAL: target = JAL_target;
    JALR: target = JALR_target;
    default: target = {ADDRESS_BITS{1'b0}};
  endcase
end

assign target_PC = target;
assign next_PC_select = (opcode == JAL) || (opcode == JALR) ||
                        ((opcode == BRANCH) && branch);

reg [5:0] alu_ctrl;

always @(*) begin
  case (opcode)
    R_TYPE: begin
      case (funct3)
        3'b000: alu_ctrl = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
        3'b001: alu_ctrl = ALU_SLL;
        3'b010: alu_ctrl = ALU_SLT;
        3'b011: alu_ctrl = ALU_SLTU;
        3'b100: alu_ctrl = ALU_XOR;
        3'b101: alu_ctrl = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
        3'b110: alu_ctrl = ALU_OR;
        default: alu_ctrl = ALU_AND;
      endcase
    end
    I_TYPE: begin
      case (funct3)
        3'b000: alu_ctrl = ALU_ADD;
        3'b001: alu_ctrl = ALU_SLL;
        3'b010: alu_ctrl = ALU_SLT;
        3'b011: alu_ctrl = ALU_SLTU;
        3'b100: alu_ctrl = ALU_XOR;
        3'b101: alu_ctrl = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
        3'b110: alu_ctrl = ALU_OR;
        default: alu_ctrl = ALU_AND;
      endcase
    end
    BRANCH: begin
      case (funct3)
        3'b000: alu_ctrl = ALU_BEQ;
        3'b001: alu_ctrl = ALU_BNE;
        3'b100: alu_ctrl = ALU_BLT;
        3'b101: alu_ctrl = ALU_BGE;
        3'b110: alu_ctrl = ALU_BLTU;
        3'b111: alu_ctrl = ALU_BGEU;
        default: alu_ctrl = ALU_ADD;
      endcase
    end
    JAL: alu_ctrl = ALU_JAL;
    JALR: alu_ctrl = ALU_JALR;
    default: alu_ctrl = ALU_ADD;
  endcase
end

assign ALU_Control = alu_ctrl;

wire [1:0] unused_extend_sel;
assign extend_sel = 2'b00;
assign unused_extend_sel = extend_sel;

endmodule
