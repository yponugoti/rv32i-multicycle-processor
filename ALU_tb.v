module ALU_tb();
reg branch_op;
reg [5:0] ctrl;
reg [31:0] opA, opB;

wire [31:0] result;
wire branch;

ALU dut (
  .branch_op(branch_op),
  .ALU_Control(ctrl),
  .operand_A(opA),
  .operand_B(opB),
  .ALU_result(result),
  .branch(branch)
);

localparam ADD = 6'b000000;
localparam SLL = 6'b000001;
localparam SLT = 6'b000010;
localparam SLTU = 6'b000011;
localparam XOR = 6'b000100;
localparam SRL = 6'b000101;
localparam OR  = 6'b000110;
localparam AND = 6'b000111;
localparam SUB = 6'b001000;
localparam SRA = 6'b001101;
localparam BEQ = 6'b010000;
localparam BNE = 6'b010001;
localparam BLT = 6'b010100;
localparam BGE = 6'b010101;
localparam BLTU = 6'b010110;
localparam BGEU = 6'b010111;
localparam JAL = 6'b011111;
localparam JALR = 6'b111111;

integer errors = 0;

task check;
  input [5:0] c;
  input [31:0] a, b;
  input [31:0] expected;
  input [8*36:1] msg;
  begin
    branch_op = 1'b0; ctrl = c; opA = a; opB = b;
    #10;
    if (result === expected && branch === 1'b0)
      $display("PASS  %-36s A=%h B=%h -> %h", msg, a, b, result);
    else begin
      $display("FAIL  %-36s A=%h B=%h -> %h branch=%b (expected %h, branch=0)",
               msg, a, b, result, branch, expected);
      errors = errors + 1;
    end
  end
endtask

task check_branch;
  input [5:0] c;
  input [31:0] a, b;
  input exp_taken;
  input [8*36:1] msg;
  begin
    branch_op = 1'b1; ctrl = c; opA = a; opB = b;
    #10;
    if (result === {31'd0, exp_taken} && branch === exp_taken)
      $display("PASS  %-36s A=%h B=%h -> %h branch=%b", msg, a, b, result, branch);
    else begin
      $display("FAIL  %-36s A=%h B=%h -> %h branch=%b (expected %h, branch=%b)",
               msg, a, b, result, branch, {31'd0, exp_taken}, exp_taken);
      errors = errors + 1;
    end
  end
endtask

initial begin
  branch_op = 1'b0;
  ctrl = 6'b000000;
  opA = 4;
  opB = 5;

  #10
  $display("ALU Result 4 + 5: %d",result);
  #10
  ctrl = 6'b000010;
  #10
  $display("ALU Result 4 < 5: %d",result);
  #10
  opB = 32'hffffffff;
  #10
  $display("ALU Result 4 < -1: %d",result);

  branch_op = 1'b1;
  opB = 32'hffffffff;
  opA = 32'hffffffff;
  ctrl = 6'b010_000; // BEQ
  #10
  $display("ALU Result (BEQ): %d",result);
  $display("Branch (should be 1): %b", branch);

  check(ADD, 32'd0, 32'd0, 32'd0, "add 0 + 0");
  check(ADD, 32'd10, 32'hFFFFFFFF, 32'd9, "add 10 + (-1)");
  check(ADD, 32'hFFFFFFFE, 32'hFFFFFFFD, 32'hFFFFFFFB, "add -2 + -3 = -5");

  check(SUB, 32'd9, 32'd5, 32'd4, "sub 9 - 5");
  check(SUB, 32'd2, 32'd6, 32'hFFFFFFFC, "sub 2 - 6 = -4");
  check(SUB, 32'hFFFFFFFB, 32'hFFFFFFFE, 32'hFFFFFFFD, "sub -5 - (-2) = -3");

  check(SLT, 32'd5, 32'd4, 32'd0, "slt 5 < 4");
  check(SLT, 32'd4, 32'hFFFFFFFF, 32'd0, "slt 4 < -1");
  check(SLT, 32'hFFFFFFFF, 32'd4, 32'd1, "slt -1 < 4");
  check(SLT, 32'hFFFFFFFE, 32'hFFFFFFFF, 32'd1, "slt -2 < -1");
  check(SLT, 32'd0, 32'd0, 32'd0, "slt 0 < 0");

  check(XOR, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'hFFFFFFFF, "xor complementary");
  check(XOR, 32'hDEADBEEF, 32'hDEADBEEF, 32'd0, "xor x ^ x = 0");
  check(XOR, 32'h12345678, 32'd0, 32'h12345678, "xor x ^ 0 = x");

  check(AND, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'd0, "and complementary = 0");
  check(AND, 32'hDEADBEEF, 32'hFFFFFFFF, 32'hDEADBEEF, "and x & -1 = x");
  check(AND, 32'hDEADBEEF, 32'd0, 32'd0, "and x & 0 = 0");

  check(SLTU, 32'h00000004, 32'hFFFFFFFF, 32'h00000001, "sltu 4 < 0xFFFFFFFF");
  check(SLTU, 32'hFFFFFFFF, 32'h00000004, 32'h00000000, "sltu 0xFFFFFFFF < 4");
  check(SLTU, 32'h00000005, 32'h00000005, 32'h00000000, "sltu equal");
  check(SLTU, 32'h00000000, 32'h00000001, 32'h00000001, "sltu 0 < 1");

  check(OR, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'hFFFFFFFF, "or complementary");
  check(OR, 32'h12345678, 32'h00000000, 32'h12345678, "or x | 0 = x");
  check(OR, 32'hFF00FF00, 32'h0FF00FF0, 32'hFFF0FFF0, "or mixed bits");

  check(SLL, 32'h00000001, 32'h00000000, 32'h00000001, "sll by 0");
  check(SLL, 32'h00000001, 32'h0000001F, 32'h80000000, "sll 1 by 31");
  check(SLL, 32'hFFFFFFFF, 32'h00000004, 32'hFFFFFFF0, "sll -1 by 4");

  check(SRL, 32'hF0000000, 32'h00000004, 32'h0F000000, "srl 0xF0000000 by 4");
  check(SRL, 32'h12345678, 32'h00000000, 32'h12345678, "srl by 0");

  check(SRA, 32'hF0000000, 32'h00000004, 32'hFF000000, "sra negative by 4");
  check(SRA, 32'h70000000, 32'h00000004, 32'h07000000, "sra positive by 4");
  check(SRA, 32'hF0000000, 32'h00000404, 32'hFF000000, "srai imm 0x404 shifts by 4");

  check(JAL, 32'h00000118, 32'h12345678, 32'h00000118, "jal passes A");
  check(JALR, 32'h00000098, 32'hFFFFFFFF, 32'h00000098, "jalr passes A");

  check_branch(BEQ, 32'h00000005, 32'h00000005, 1'b1, "beq equal (taken)");
  check_branch(BEQ, 32'h00000005, 32'h00000006, 1'b0, "beq not equal");
  check_branch(BNE, 32'h00000005, 32'h00000006, 1'b1, "bne not equal (taken)");
  check_branch(BNE, 32'h00000005, 32'h00000005, 1'b0, "bne equal");
  check_branch(BLT, 32'hFFFFFFFF, 32'h00000001, 1'b1, "blt -1 < 1 (taken)");
  check_branch(BLT, 32'h00000001, 32'hFFFFFFFF, 1'b0, "blt 1 < -1");
  check_branch(BLT, 32'h00000007, 32'h00000007, 1'b0, "blt equal");
  check_branch(BGE, 32'h00000007, 32'h00000007, 1'b1, "bge equal (taken)");
  check_branch(BGE, 32'h00000001, 32'hFFFFFFFF, 1'b1, "bge 1 >= -1 (taken)");
  check_branch(BGE, 32'hFFFFFFFF, 32'h00000001, 1'b0, "bge -1 >= 1");
  check_branch(BLTU, 32'h00000001, 32'hFFFFFFFF, 1'b1, "bltu 1 < 0xFFFFFFFF (taken)");
  check_branch(BLTU, 32'hFFFFFFFF, 32'h00000001, 1'b0, "bltu 0xFFFFFFFF < 1");
  check_branch(BLTU, 32'h00000007, 32'h00000007, 1'b0, "bltu equal");
  check_branch(BGEU, 32'hFFFFFFFF, 32'h00000001, 1'b1, "bgeu 0xFFFFFFFF >= 1 (taken)");
  check_branch(BGEU, 32'h00000007, 32'h00000007, 1'b1, "bgeu equal (taken)");
  check_branch(BGEU, 32'h00000001, 32'hFFFFFFFF, 1'b0, "bgeu 1 >= 0xFFFFFFFF");

  check(BEQ, 32'h00000005, 32'h00000005, 32'h00000001, "beq equal with branch_op = 0");

  check(6'b111110, 32'd4, 32'd5, 32'd0, "unused ctrl -> 0");

  if (errors == 0) $display("\nALL ALU TESTS PASSED");
  else             $display("\n%0d TEST(S) FAILED", errors);

  #10
  $stop();

end

endmodule
