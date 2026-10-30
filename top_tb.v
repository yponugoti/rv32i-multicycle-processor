module top_tb();

parameter NOP = 32'b000000000000_00000_000_00000_0010011; // addi zero, zero, 0

reg clock;
reg reset;
reg [31:0] instruction;

wire [31:0] result;

integer x;

top dut (
  .clock(clock),
  .reset(reset),
  .instruction(instruction),
  .wb_data(result)
);

always #5 clock = ~clock;

task print_state;
  begin
    $display("Time:\t%0d", $time);
    for( x=0; x<32; x=x+1) begin
      $display("Register %d: %h", x, dut.regFile_inst.reg_file[x]);
    end
    $display("--------------------------------------------------------------------------------");
    $display("\n\n");
  end
endtask

integer errors = 0;

task run_instr;
  input [31:0] instr;
  input [31:0] exp_wb_data;
  input [8*28:1] name;
  begin
    instruction = instr;
    #1;
    if (result === exp_wb_data)
      $display("PASS  %-28s wb_data = %h", name, result);
    else begin
      $display("FAIL  %-28s wb_data = %h, expected %h", name, result, exp_wb_data);
      errors = errors + 1;
    end
    @(posedge clock);
    #1;
  end
endtask

task check_reg;
  input [4:0]    n;
  input [31:0]   expected;
  input [8*36:1] name;
  begin
    if (dut.regFile_inst.reg_file[n] === expected)
      $display("PASS    %-36s x%0d = %h", name, n, expected);
    else begin
      $display("FAIL    %-36s x%0d = %h, expected %h", name, n,
               dut.regFile_inst.reg_file[n], expected);
      errors = errors + 1;
    end
  end
endtask

task check_mem;
  input [15:0]   addr;
  input [31:0]   expected;
  input [8*36:1] name;
  begin
    if (dut.mem_inst.mem[addr[15:2]] === expected)
      $display("PASS    %-36s mem[%0d] = %h", name, addr, expected);
    else begin
      $display("FAIL    %-36s mem[%0d] = %h, expected %h", name, addr,
               dut.mem_inst.mem[addr[15:2]], expected);
      errors = errors + 1;
    end
  end
endtask

initial begin
  clock = 1'b1;
  reset = 1'b1;
  instruction = 32'h00000000;
  #1
  #10
  reset = 1'b0;
  #20
  instruction = 32'b000000000001_00000_000_01011_0010011; // addi a1, zero, 1
  #10
  instruction = 32'b000000000010_00000_000_01100_0010011; // addi a2, zero, 2
  #10
  instruction = 32'b000000000101_00000_000_01101_0010011; // addi a3, zero, 5
  #10
  instruction = 32'b000000000110_00000_000_01110_0010011; // addi a4, zero, 6
  #10
  instruction = 32'b111111111111_00000_000_01111_0010011; // addi a5, zero, -1
  #10
  // Make sure you set instruction to NOP when your processor is idle.
  // Otherwise, your register file state will keep changing when the processor
  // tries to execute instruction each clock cycle.
  instruction = NOP;

  #10
  instruction = 32'b0000000_01100_01011_000_10000_0110011; // add a6, a1, a2

  #10
  // Here we are printing the state of the register file.
  // We should see the result of the add a6, a1, a2 instruction but not the
  // sub a7, a2, a4 instruction because there has not been a posedge clock yet
  $display("add a6, a1, a2");
  print_state();
  instruction = 32'b0100000_01110_01100_000_10001_0110011; // sub a7, a2, a4

  #10

  check_reg(5'd11, 32'h00000001, "addi a1, zero, 1");
  check_reg(5'd12, 32'h00000002, "addi a2, zero, 2");
  check_reg(5'd13, 32'h00000005, "addi a3, zero, 5");
  check_reg(5'd14, 32'h00000006, "addi a4, zero, 6");
  check_reg(5'd15, 32'hffffffff, "addi a5, zero, -1");
  check_reg(5'd16, 32'h00000003, "add a6, a1, a2");
  check_reg(5'd17, 32'hfffffffc, "sub a7, a2, a4");

  run_instr(32'b0000000_01111_01011_010_01010_0110011, 32'h00000000, "slt a0, a1, a5");
  check_reg(5'd10, 32'h00000000, "a0 = (1 < -1) = 0");
  run_instr(32'b0000000_01011_01111_010_01001_0110011, 32'h00000001, "slt s1, a5, a1");
  check_reg(5'd9, 32'h00000001, "s1 = (-1 < 1) = 1");
  run_instr(32'b0000000_01111_01011_100_10010_0110011, 32'hfffffffe, "xor s2, a1, a5");
  check_reg(5'd18, 32'hfffffffe, "s2 = 1 ^ -1");
  run_instr(32'b0000000_01011_01101_111_10011_0110011, 32'h00000001, "and s3, a3, a1");
  check_reg(5'd19, 32'h00000001, "s3 = 5 & 1");

  run_instr(32'b111111111011_01111_000_10100_0010011, 32'hfffffffa, "addi s4, a5, -5");
  check_reg(5'd20, 32'hfffffffa, "s4 = -1 + -5 = -6");
  run_instr(32'b000100000000_00000_000_10101_0010011, 32'h00000100, "addi s5, zero, 256");
  check_reg(5'd21, 32'h00000100, "s5 = 256 (0x100)");

  run_instr(32'b0000000_10000_10101_010_01000_0100011, 32'h00000108, "sw a6, 8(s5)");
  check_mem(16'd264, 32'h00000003, "mem[264] = a6");
  run_instr(32'b1111111_10001_10101_010_11100_0100011, 32'h000000fc, "sw a7, -4(s5)");
  check_mem(16'd252, 32'hfffffffc, "mem[252] = a7 (negative offset)");

  run_instr(32'b000000001000_10101_010_10110_0000011, 32'h00000003, "lw s6, 8(s5)");
  check_reg(5'd22, 32'h00000003, "s6 = mem[264]");
  run_instr(32'b111111111100_10101_010_10111_0000011, 32'hfffffffc, "lw s7, -4(s5)");
  check_reg(5'd23, 32'hfffffffc, "s7 = mem[252]");

  run_instr(32'b0000000_10111_10110_000_11001_0110011, 32'hffffffff, "add s9, s6, s7");
  check_reg(5'd25, 32'hffffffff, "s9 = 3 + -4 = -1");
  run_instr(32'b0000000_11001_10101_010_00000_0100011, 32'h00000100, "sw s9, 0(s5)");
  check_mem(16'd256, 32'hffffffff, "mem[256] = s9");
  run_instr(32'b000000000000_10101_010_11010_0000011, 32'hffffffff, "lw s10, 0(s5)");
  check_reg(5'd26, 32'hffffffff, "s10 = mem[256]");

  run_instr(32'b000000000101_00000_000_00000_0010011, 32'h00000005, "addi zero, zero, 5");
  check_reg(5'd0, 32'h00000000, "x0 still 0");

  run_instr(32'b0000000_01011_00000_010_00000_0100011, 32'h00000000, "sw a1, 0(zero)");
  check_mem(16'd0, 32'h00000001, "mem[0] = a1");

  instruction = NOP;
  #1;

  if (errors == 0) $display("ALL TOP-LEVEL TESTS PASSED");
  else             $display("%0d TEST(S) FAILED", errors);

  $finish;

  #10
  $stop();

end

endmodule
