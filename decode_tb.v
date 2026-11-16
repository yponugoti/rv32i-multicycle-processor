module decode_tb();

parameter NOP = 32'b000000000000_00000_000_00000_0010011; // addi zero, zero, 0
parameter ADDRESS_BITS = 16;

// Inputs from Fetch
reg [ADDRESS_BITS-1:0] PC;
reg [31:0] instruction;

// Inputs from Execute/ALU
reg [ADDRESS_BITS-1:0] JALR_target;
reg branch;

// Outputs to Fetch
wire next_PC_select;
wire [ADDRESS_BITS-1:0] target_PC;

// Outputs to Reg File
wire [4:0] read_sel1;
wire [4:0] read_sel2;
wire [4:0] write_sel;
wire wEn;

// Outputs to Execute/ALU
wire branch_op; // Tells ALU if this is a branch instruction
wire [31:0] imm32;
wire [1:0] op_A_sel;
wire op_B_sel;
wire [5:0] ALU_Control;

// Outputs to Memory
wire mem_wEn;

// Outputs to Writeback
wire wb_sel;

decode #(
  .ADDRESS_BITS(ADDRESS_BITS)
) uut (

  // Inputs from Fetch
  .PC(PC),
  .instruction(instruction),

  // Inputs from Execute/ALU
  .JALR_target(JALR_target),
  .branch(branch),

  // Outputs to Fetch
  .next_PC_select(next_PC_select),
  .target_PC(target_PC),

  // Outputs to Reg File
  .read_sel1(read_sel1),
  .read_sel2(read_sel2),
  .write_sel(write_sel),
  .wEn(wEn),

  // Outputs to Execute/ALU
  .branch_op(branch_op), // Tells ALU if this is a branch instruction
  .imm32(imm32),
  .op_A_sel(op_A_sel),
  .op_B_sel(op_B_sel),
  .ALU_Control(ALU_Control),

  // Outputs to Memory
  .mem_wEn(mem_wEn),

  // Outputs to Writeback
  .wb_sel(wb_sel)

);

task print_state;
  begin
    $display("Time:         %0d", $time);
    $display("instruction:  %b", instruction);
    $display("PC:           %h", PC);
    $display("JALR_target:  %h", JALR_target);
    $display("branch        %b", branch);
    $display("next_PC_sel   %b", next_PC_select);
    $display("target_PC     %h", target_PC);
    $display("read_sel1:    %d", read_sel1);
    $display("read_sel2:    %d", read_sel2);
    $display("write_sel:    %d", write_sel);
    $display("wEn:          %b", wEn);
    $display("branch_op:    %b", branch_op);
    $display("imm32:        %b", imm32);
    $display("op_A_sel:     %b", op_A_sel);
    $display("op_B_sel:     %b", op_B_sel);
    $display("ALU_Control:  %b", ALU_Control);
    $display("mem_wEn:      %b", mem_wEn);
    $display("wb_sel:       %b", wb_sel);
    $display("--------------------------------------------------------------------------------");
    $display("\n\n");
  end
endtask

integer errors = 0;

task check_decode;
  input [31:0] instr;
  input [15:0] pc;
  input [15:0] jalr_tgt;
  input br;
  input exp_next_PC_select;
  input [15:0] exp_target_PC;
  input [4:0] exp_read_sel1;
  input [4:0] exp_read_sel2;
  input [4:0] exp_write_sel;
  input exp_wEn;
  input exp_branch_op;
  input [31:0] exp_imm32;
  input [1:0] exp_op_A_sel;
  input exp_op_B_sel;
  input [5:0] exp_ALU_Control;
  input exp_mem_wEn;
  input exp_wb_sel;
  input [8*30:1] name;
  integer bad;
  begin
    instruction = instr;
    PC = pc;
    JALR_target = jalr_tgt;
    branch = br;
    #1;
    bad = 0;
    if (next_PC_select !== exp_next_PC_select) begin
      $display("FAIL  %-30s next_PC_select = %b, expected %b", name, next_PC_select, exp_next_PC_select);
      bad = bad + 1;
    end
    if (target_PC !== exp_target_PC) begin
      $display("FAIL  %-30s target_PC = %h, expected %h", name, target_PC, exp_target_PC);
      bad = bad + 1;
    end
    if (read_sel1 !== exp_read_sel1) begin
      $display("FAIL  %-30s read_sel1 = %0d, expected %0d", name, read_sel1, exp_read_sel1);
      bad = bad + 1;
    end
    if (read_sel2 !== exp_read_sel2) begin
      $display("FAIL  %-30s read_sel2 = %0d, expected %0d", name, read_sel2, exp_read_sel2);
      bad = bad + 1;
    end
    if (write_sel !== exp_write_sel) begin
      $display("FAIL  %-30s write_sel = %0d, expected %0d", name, write_sel, exp_write_sel);
      bad = bad + 1;
    end
    if (wEn !== exp_wEn) begin
      $display("FAIL  %-30s wEn = %b, expected %b", name, wEn, exp_wEn);
      bad = bad + 1;
    end
    if (branch_op !== exp_branch_op) begin
      $display("FAIL  %-30s branch_op = %b, expected %b", name, branch_op, exp_branch_op);
      bad = bad + 1;
    end
    if (imm32 !== exp_imm32) begin
      $display("FAIL  %-30s imm32 = %h, expected %h", name, imm32, exp_imm32);
      bad = bad + 1;
    end
    if (op_A_sel !== exp_op_A_sel) begin
      $display("FAIL  %-30s op_A_sel = %0d, expected %0d", name, op_A_sel, exp_op_A_sel);
      bad = bad + 1;
    end
    if (op_B_sel !== exp_op_B_sel) begin
      $display("FAIL  %-30s op_B_sel = %b, expected %b", name, op_B_sel, exp_op_B_sel);
      bad = bad + 1;
    end
    if (ALU_Control !== exp_ALU_Control) begin
      $display("FAIL  %-30s ALU_Control = %b, expected %b", name, ALU_Control, exp_ALU_Control);
      bad = bad + 1;
    end
    if (mem_wEn !== exp_mem_wEn) begin
      $display("FAIL  %-30s mem_wEn = %b, expected %b", name, mem_wEn, exp_mem_wEn);
      bad = bad + 1;
    end
    if (wb_sel !== exp_wb_sel) begin
      $display("FAIL  %-30s wb_sel = %b, expected %b", name, wb_sel, exp_wb_sel);
      bad = bad + 1;
    end
    if (bad == 0)
      $display("PASS  %-30s imm32 = %h  target_PC = %h  ALU_Control = %b", name, imm32, target_PC, ALU_Control);
    else
      errors = errors + 1;
  end
endtask

initial begin
  $display("Starting Decode Test");
  $display("--------------------------------------------------------------------------------");
  instruction = NOP;
  PC          = 0;
  JALR_target = 0;
  branch      = 0;

  #10
  // Display output of NOP instruction
  $display("addi zero, zero, 0");
  print_state();
  // Test a new instruction
  instruction = 32'b111111111111_00000_000_01011_0010011; // addi a1, zero, -1

  #10
  // Here we are printing the state of the register file.
  // We should see the result of the add a6, a1, a2 instruction but not the
  // sub a7, a2, a4 instruction because there has not been a posedge clock yet
  $display("addi a1, zero, -1");
  print_state();
  instruction = 32'b0000000_01100_01011_000_10000_0110011; // add a6, a1, a2

  #10
  $display("add a6, a1, a2");
  print_state();
  instruction = 32'b0100000_01110_01100_000_10001_0110011; // sub a7, a2, a4

  #10
  $display("sub a7, a2, a4");
  print_state();
  instruction = 32'b0000000_01111_01011_010_01010_0110011; // slt a0, a1, a5

  #10
  $display("slt a0, a1, a5");
  print_state();
  instruction = 32'b0000000_01111_01011_100_01110_0110011; // xor a4, a1, a5

  #10
  $display("xor a4, a1, a5");
  print_state();
  instruction = 32'b0000000_01011_01101_111_01101_0110011; // and a3, a3, a1

  #10
  $display("and a3, a3, a1");
  print_state();
  instruction = 32'b011000000000_00000_000_01011_0010011; // addi a1, zero, 1536

  #10
  $display("addi a1, zero, 1536");
  print_state();
  instruction = 32'b0000000_01100_01011_010_00000_0100011; // sw a2, 0(a1);

  #10
  $display("sw a2, 0(a1)");
  print_state();
  instruction = 32'b000000000000_01011_010_10010_0000011; // lw s2, 0(a1);

  #10
  $display("lw s2, 0(a1)");
  print_state();
  instruction = NOP;

  PC = 16'h0114;
  instruction = 32'h0140006f; //jal	zero,128 (Should jump to 0x128)

  #10
  $display("jal	zero,128");
  print_state();

  JALR_target = 16'h0154;
  PC = 16'h0094;
  instruction = 32'h0c4080e7; // jalr ra,196(ra) (should jump to ra+196, i.e. ra+0xc4)

  #10
  $display("jalr ra,196(ra)");
  print_state();
  
  check_decode(32'h007302b3, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd6, 5'd7, 5'd5, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b0, 6'b000000, 1'b0, 1'b0,
               "add t0, t1, t2");
  check_decode(32'h40c58433, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd12, 5'd8, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b0, 6'b001000, 1'b0, 1'b0,
               "sub s0, a1, a2");
  check_decode(32'h00c59533, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd12, 5'd10, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b0, 6'b000001, 1'b0, 1'b0,
               "sll a0, a1, a2");
  check_decode(32'h00f5a533, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd15, 5'd10, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b0, 6'b000010, 1'b0, 1'b0,
               "slt a0, a1, a5");
  check_decode(32'h00f5b533, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd15, 5'd10, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b0, 6'b000011, 1'b0, 1'b0,
               "sltu a0, a1, a5");
  check_decode(32'h00f5c733, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd15, 5'd14, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b0, 6'b000100, 1'b0, 1'b0,
               "xor a4, a1, a5");
  check_decode(32'h01df5fb3, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd30, 5'd29, 5'd31, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b0, 6'b000101, 1'b0, 1'b0,
               "srl t6, t5, t4");
  check_decode(32'h41df5fb3, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd30, 5'd29, 5'd31, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b0, 6'b001101, 1'b0, 1'b0,
               "sra t6, t5, t4");
  check_decode(32'h00b6e6b3, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd13, 5'd11, 5'd13, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b0, 6'b000110, 1'b0, 1'b0,
               "or a3, a3, a1");
  check_decode(32'h00b6f6b3, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd13, 5'd11, 5'd13, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b0, 6'b000111, 1'b0, 1'b0,
               "and a3, a3, a1");

  check_decode(32'hfff00593, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd0, 5'd31, 5'd11, 1'b1, 1'b0,
               32'hffffffff, 2'd0, 1'b1, 6'b000000, 1'b0, 1'b0,
               "addi a1, zero, -1");
  check_decode(32'h7ff60313, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd12, 5'd31, 5'd6, 1'b1, 1'b0,
               32'h000007ff, 2'd0, 1'b1, 6'b000000, 1'b0, 1'b0,
               "addi t1, a2, 2047");
  check_decode(32'h80060393, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd12, 5'd0, 5'd7, 1'b1, 1'b0,
               32'hfffff800, 2'd0, 1'b1, 6'b000000, 1'b0, 1'b0,
               "addi t2, a2, -2048");
  check_decode(32'hffb5a513, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd27, 5'd10, 1'b1, 1'b0,
               32'hfffffffb, 2'd0, 1'b1, 6'b000010, 1'b0, 1'b0,
               "slti a0, a1, -5");
  check_decode(32'hfff5b513, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd31, 5'd10, 1'b1, 1'b0,
               32'hffffffff, 2'd0, 1'b1, 6'b000011, 1'b0, 1'b0,
               "sltiu a0, a1, -1");
  check_decode(32'hfff5c513, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd31, 5'd10, 1'b1, 1'b0,
               32'hffffffff, 2'd0, 1'b1, 6'b000100, 1'b0, 1'b0,
               "xori a0, a1, -1");
  check_decode(32'h5555e513, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd21, 5'd10, 1'b1, 1'b0,
               32'h00000555, 2'd0, 1'b1, 6'b000110, 1'b0, 1'b0,
               "ori a0, a1, 1365");
  check_decode(32'h0ff5f513, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd31, 5'd10, 1'b1, 1'b0,
               32'h000000ff, 2'd0, 1'b1, 6'b000111, 1'b0, 1'b0,
               "andi a0, a1, 255");
  check_decode(32'h01f59513, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd31, 5'd10, 1'b1, 1'b0,
               32'h0000001f, 2'd0, 1'b1, 6'b000001, 1'b0, 1'b0,
               "slli a0, a1, 31");
  check_decode(32'h0045d513, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd4, 5'd10, 1'b1, 1'b0,
               32'h00000004, 2'd0, 1'b1, 6'b000101, 1'b0, 1'b0,
               "srli a0, a1, 4");
  check_decode(32'h4045d513, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd4, 5'd10, 1'b1, 1'b0,
               32'h00000404, 2'd0, 1'b1, 6'b001101, 1'b0, 1'b0,
               "srai a0, a1, 4");

  check_decode(32'h0005a903, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd11, 5'd0, 5'd18, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b1, 6'b000000, 1'b0, 1'b1,
               "lw s2, 0(a1)");
  check_decode(32'hffc42283, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd8, 5'd28, 5'd5, 1'b1, 1'b0,
               32'hfffffffc, 2'd0, 1'b1, 6'b000000, 1'b0, 1'b1,
               "lw t0, -4(s0)");
  check_decode(32'h54b12aa3, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd2, 5'd11, 5'd21, 1'b0, 1'b0,
               32'h00000555, 2'd0, 1'b1, 6'b000000, 1'b1, 1'b0,
               "sw a1, 1365(sp)");
  check_decode(32'hfef42c23, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd8, 5'd15, 5'd24, 1'b0, 1'b0,
               32'hfffffff8, 2'd0, 1'b1, 6'b000000, 1'b1, 1'b0,
               "sw a5, -8(s0)");

  check_decode(32'h12345537, 16'h0000, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd8, 5'd3, 5'd10, 1'b1, 1'b0,
               32'h12345000, 2'd3, 1'b1, 6'b000000, 1'b0, 1'b0,
               "lui a0, 0x12345");
  check_decode(32'h00001597, 16'h0100, 16'h0000, 1'b0,
               1'b0, 16'h0000, 5'd0, 5'd0, 5'd11, 1'b1, 1'b0,
               32'h00001000, 2'd1, 1'b1, 6'b000000, 1'b0, 1'b0,
               "auipc a1, 0x1");

  check_decode(32'h00b50463, 16'h0100, 16'h0000, 1'b1,
               1'b1, 16'h0108, 5'd10, 5'd11, 5'd8, 1'b0, 1'b1,
               32'h00000008, 2'd0, 1'b0, 6'b010000, 1'b0, 1'b0,
               "beq a0, a1, 8 (taken)");
  check_decode(32'h00b50463, 16'h0100, 16'h0000, 1'b0,
               1'b0, 16'h0108, 5'd10, 5'd11, 5'd8, 1'b0, 1'b1,
               32'h00000008, 2'd0, 1'b0, 6'b010000, 1'b0, 1'b0,
               "beq a0, a1, 8 (not taken)");
  check_decode(32'hfeb51ce3, 16'h0100, 16'h0000, 1'b1,
               1'b1, 16'h00f8, 5'd10, 5'd11, 5'd25, 1'b0, 1'b1,
               32'hfffffff8, 2'd0, 1'b0, 6'b010001, 1'b0, 1'b0,
               "bne a0, a1, -8 (taken)");
  check_decode(32'h2ab545e3, 16'h0100, 16'h0000, 1'b1,
               1'b1, 16'h0baa, 5'd10, 5'd11, 5'd11, 1'b0, 1'b1,
               32'h00000aaa, 2'd0, 1'b0, 6'b010100, 1'b0, 1'b0,
               "blt a0, a1, 2730 (taken)");
  check_decode(32'h80b55063, 16'h2000, 16'h0000, 1'b0,
               1'b0, 16'h1000, 5'd10, 5'd11, 5'd0, 1'b0, 1'b1,
               32'hfffff000, 2'd0, 1'b0, 6'b010101, 1'b0, 1'b0,
               "bge a0, a1, -4096");
  check_decode(32'h7eb56fe3, 16'h0100, 16'h0000, 1'b1,
               1'b1, 16'h10fe, 5'd10, 5'd11, 5'd31, 1'b0, 1'b1,
               32'h00000ffe, 2'd0, 1'b0, 6'b010110, 1'b0, 1'b0,
               "bltu a0, a1, 4094 (taken)");
  check_decode(32'h00b570e3, 16'h0100, 16'h0000, 1'b1,
               1'b1, 16'h0900, 5'd10, 5'd11, 5'd1, 1'b0, 1'b1,
               32'h00000800, 2'd0, 1'b0, 6'b010111, 1'b0, 1'b0,
               "bgeu a0, a1, 2048 (taken)");

  check_decode(32'hff1ff0ef, 16'h0200, 16'h0000, 1'b0,
               1'b1, 16'h01f0, 5'd31, 5'd17, 5'd1, 1'b1, 1'b0,
               32'hfffffff0, 2'd2, 1'b0, 6'b011111, 1'b0, 1'b0,
               "jal ra, -16");
  check_decode(32'h556050ef, 16'h0100, 16'h0000, 1'b0,
               1'b1, 16'h5656, 5'd0, 5'd22, 5'd1, 1'b1, 1'b0,
               32'h00005556, 2'd2, 1'b0, 6'b011111, 1'b0, 1'b0,
               "jal ra, 0x5556");

  check_decode(32'h0c4080e7, 16'h0094, 16'h0154, 1'b0,
               1'b1, 16'h0154, 5'd1, 5'd4, 5'd1, 1'b1, 1'b0,
               32'h000000c4, 2'd2, 1'b0, 6'b111111, 1'b0, 1'b0,
               "jalr ra, 196(ra) (template)");
  check_decode(32'hffc28067, 16'h0300, 16'h0040, 1'b0,
               1'b1, 16'h0040, 5'd5, 5'd28, 5'd0, 1'b1, 1'b0,
               32'hfffffffc, 2'd2, 1'b0, 6'b111111, 1'b0, 1'b0,
               "jalr zero, -4(t0)");
  
  check_decode(32'h007302b3, 16'h0100, 16'h0000, 1'b1,
               1'b0, 16'h0000, 5'd6, 5'd7, 5'd5, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b0, 6'b000000, 1'b0, 1'b0,
               "add with branch = 1");
  check_decode(32'h0005a903, 16'h0100, 16'h0000, 1'b1,
               1'b0, 16'h0000, 5'd11, 5'd0, 5'd18, 1'b1, 1'b0,
               32'h00000000, 2'd0, 1'b1, 6'b000000, 1'b0, 1'b1,
               "lw with branch = 1");

  check_decode(32'h00000000, 16'h0100, 16'h0000, 1'b1,
               1'b0, 16'h0000, 5'd0, 5'd0, 5'd0, 1'b0, 1'b0,
               32'h00000000, 2'd0, 1'b0, 6'b000000, 1'b0, 1'b0,
               "all zeros (0x00000000)");

  if (errors == 0) $display("\nALL DECODE TESTS PASSED");
  else             $display("\n%0d INSTRUCTION(S) FAILED", errors);

  #10
  $stop();
end

endmodule
