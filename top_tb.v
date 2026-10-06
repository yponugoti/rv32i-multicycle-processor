module top_tb();

reg clock, reset, op_B_sel, wEn;
reg [5:0] ctrl;
reg [31:0] instruction;

wire [31:0] result;

integer x;

integer errors = 0;

task run_instr;
  input [31:0] instr;
  input [5:0] c;
  input sel;
  input we;
  input [31:0] exp_result;
  input [8*24:1] name;
  begin
    instruction = instr;
    ctrl = c;
    op_B_sel = sel;
    wEn = we;
    #1;
    if (result === exp_result)
      $display("PASS  %-24s ALU_result = %h", name, result);
    else begin
      $display("FAIL  %-24s ALU_result = %h (expected %h)", name, result, exp_result);
      errors = errors + 1;
    end
    #9;
  end
endtask

task check_reg;
  input [4:0] n;
  input [31:0] expected;
  input [8*24:1] name;
  begin
    if (dut.regFile_inst.reg_file[n] === expected)
      $display("PASS  %-24s x%0d = %h", name, n, expected);
    else begin
      $display("FAIL  %-24s x%0d = %h (expected %h)", name, n,
               dut.regFile_inst.reg_file[n], expected);
      errors = errors + 1;
    end
  end
endtask

top dut (
  .clock(clock),
  .reset(reset),
  .instruction(instruction),
  .ALU_Control(ctrl),
  .op_B_sel(op_B_sel),
  .wEn(wEn),
  .ALU_result(result)
);

always #5 clock = ~clock;

initial begin
  clock = 1'b0;
  reset = 1'b1;
  op_B_sel = 1'b0;
  ctrl = 6'b000000;
  instruction = 32'h00000000;
  wEn = 1'b0;
  #10
  reset = 1'b0;
  #20
  wEn = 1'b1;
  instruction = 32'b000000000001_00000_000_01011_0010011; // addi a1, zero, 1
  ctrl = 6'b000000;
  op_B_sel = 1'b1;
  #10
  instruction = 32'b000000000010_00000_000_01100_0010011; // addi a2, zero, 2
  ctrl = 6'b000000;
  op_B_sel = 1'b1;
  #10
  instruction = 32'b000000000101_00000_000_01101_0010011; // addi a3, zero, 5
  ctrl = 6'b000000;
  op_B_sel = 1'b1;
  #10
  instruction = 32'b000000000110_00000_000_01110_0010011; // addi a4, zero, 6
  ctrl = 6'b000000;
  op_B_sel = 1'b1;
  #10
  instruction = 32'b111111111111_00000_000_01111_0010011; // addi a5, zero, -1
  ctrl = 6'b000000;
  op_B_sel = 1'b1;
  $display("Time %d", $time);
  for( x=0; x<32; x=x+1) begin
    $display("Register %d: %h", x, dut.regFile_inst.reg_file[x]);
  end

  #10
  instruction = 32'b0000000_01100_01011_000_10000_0110011; // add a6, a1, a2
  ctrl = 6'b000000;
  op_B_sel = 1'b0;
  $display("Time %d", $time);
  for( x=0; x<32; x=x+1) begin
    $display("Register %d: %h", x, dut.regFile_inst.reg_file[x]);
  end

  #10
  instruction = 32'b0100000_01110_01100_000_10001_0110011; // sub a7, a2, a4
  ctrl = 6'b001000;
  op_B_sel = 1'b0;
  $display("Time %d", $time);
  for( x=0; x<32; x=x+1) begin
    $display("Register %d: %h", x, dut.regFile_inst.reg_file[x]);
  end

  #10
  instruction = 32'b0000000_01111_01011_010_01010_0110011; // slt a0, a1, a5
  ctrl = 6'b000010;
  op_B_sel = 1'b0;
  $display("Time %d", $time);
  for( x=0; x<32; x=x+1) begin
    $display("Register %d: %h", x, dut.regFile_inst.reg_file[x]);
  end

  #10
  instruction = 32'b0000000_01111_01011_100_01110_0110011; // xor a4, a1, a5
  ctrl = 6'b000100;
  op_B_sel = 1'b0;
  $display("Time %d", $time);
  for( x=0; x<32; x=x+1) begin
    $display("Register %d: %h", x, dut.regFile_inst.reg_file[x]);
  end

  #10
  instruction = 32'b0000000_01011_01101_111_01101_0110011; // and a3, a3, a1
  ctrl = 6'b000111;
  op_B_sel = 1'b0;
  $display("Time %d", $time);
  for( x=0; x<32; x=x+1) begin
    $display("Register %d: %h", x, dut.regFile_inst.reg_file[x]);
  end


  #10
  wEn = 1'b0;
  $display("Time %d", $time);
  for( x=0; x<32; x=x+1) begin
    $display("Register %d: %h", x, dut.regFile_inst.reg_file[x]);
  end

  check_reg(5'd0,  32'h00000000, "x0 is zero");
  check_reg(5'd11, 32'h00000001, "addi a1, zero, 1");
  check_reg(5'd12, 32'h00000002, "addi a2, zero, 2");
  check_reg(5'd15, 32'hffffffff, "addi a5, zero, -1");
  check_reg(5'd16, 32'h00000003, "add a6, a1, a2");
  check_reg(5'd17, 32'hfffffffc, "sub a7, a2, a4");
  check_reg(5'd10, 32'h00000000, "slt a0, a1, a5");
  check_reg(5'd14, 32'hfffffffe, "xor a4, a1, a5");
  check_reg(5'd13, 32'h00000001, "and a3, a3, a1");

  run_instr(32'b111111111011_01011_000_00101_0010011, 6'b000000, 1'b1, 1'b1, 32'hfffffffc, "addi t0, a1, -5");
  check_reg(5'd5,  32'hfffffffc, "t0 = 1 + (-5) = -4");
  run_instr(32'b011111111111_00000_000_00110_0010011, 6'b000000, 1'b1, 1'b1, 32'h000007ff, "addi t1, zero, 2047");
  check_reg(5'd6,  32'h000007ff, "t1 = 2047");
  run_instr(32'b100000000000_00000_000_00111_0010011, 6'b000000, 1'b1, 1'b1, 32'hfffff800, "addi t2, zero, -2048");
  check_reg(5'd7,  32'hfffff800, "t2 = -2048");

  run_instr(32'b0000000_00111_00110_000_01000_0110011, 6'b000000, 1'b0, 1'b1, 32'hffffffff, "add s0, t1, t2");
  check_reg(5'd8,  32'hffffffff, "s0 = 2047 + -2048 = -1");
  run_instr(32'b0000000_01111_00000_000_11000_0110011, 6'b000000, 1'b0, 1'b1, 32'hffffffff, "add s8, zero, a5");
  check_reg(5'd24, 32'hffffffff, "s8 = 0 + -1");

  run_instr(32'b0100000_01011_01011_000_01001_0110011, 6'b001000, 1'b0, 1'b1, 32'h00000000, "sub s1, a1, a1");
  check_reg(5'd9,  32'h00000000, "s1 = a1 - a1 = 0");

  run_instr(32'b0000000_01011_01111_010_10010_0110011, 6'b000010, 1'b0, 1'b1, 32'h00000001, "slt s2, a5, a1");
  check_reg(5'd18, 32'h00000001, "s2 = (-1 < 1) = 1");
  run_instr(32'b0000000_01011_01011_010_10011_0110011, 6'b000010, 1'b0, 1'b1, 32'h00000000, "slt s3, a1, a1");
  check_reg(5'd19, 32'h00000000, "s3 = (1 < 1) = 0");

  run_instr(32'b0000000_01101_01100_100_10100_0110011, 6'b000100, 1'b0, 1'b1, 32'h00000003, "xor s4, a2, a3");
  check_reg(5'd20, 32'h00000003, "s4 = 2 ^ 1 = 3");
  run_instr(32'b0000000_01111_01111_100_10000_0110011, 6'b000100, 1'b0, 1'b1, 32'h00000000, "xor a6, a5, a5");
  check_reg(5'd16, 32'h00000000, "a6 = x ^ x = 0");

  run_instr(32'b0000000_00110_01111_111_10101_0110011, 6'b000111, 1'b0, 1'b1, 32'h000007ff, "and s5, a5, t1");
  check_reg(5'd21, 32'h000007ff, "s5 = -1 & 0x7ff");
  run_instr(32'b0000000_01100_01110_111_01110_0110011, 6'b000111, 1'b0, 1'b1, 32'h00000002, "and a4, a4, a2");
  check_reg(5'd14, 32'h00000002, "a4 = 0xfffffffe & 2");

  run_instr(32'b000000000101_00000_000_00000_0010011, 6'b000000, 1'b1, 1'b1, 32'h00000005, "addi zero, zero, 5");
  check_reg(5'd0,  32'h00000000, "x0 still 0");

  run_instr(32'b000000001001_00000_000_10110_0010011, 6'b000000, 1'b1, 1'b0, 32'h00000009, "addi s6, zero, 9 (wEn=0)");
  check_reg(5'd22, 32'h00000000, "s6 unchanged");

  run_instr(32'b000000000001_10111_000_10111_0010011, 6'b000000, 1'b1, 1'b1, 32'h00000001, "addi s7, s7, 1 (#1)");
  run_instr(32'b000000000001_10111_000_10111_0010011, 6'b000000, 1'b1, 1'b1, 32'h00000002, "addi s7, s7, 1 (#2)");
  check_reg(5'd23, 32'h00000002, "s7 = 2");

  if (errors == 0) $display("\nALL TOP-LEVEL TESTS PASSED");
  else             $display("\n%0d TEST(S) FAILED", errors);

  #10
  $finish;
end

endmodule



