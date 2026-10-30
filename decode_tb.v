module decode_tb();

parameter NOP = 32'b000000000000_00000_000_00000_0010011; // addi zero, zero, 0

reg [31:0] instruction;

wire wb_sel;
wire [4:0] read_sel1;
wire [4:0] read_sel2;
wire [4:0] write_sel;
wire wEn;
wire [31:0] imm32;
wire ob_B_sel;
wire [5:0] ALU_Control;
wire mem_wEn;

decode uut (
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

task print_state;
  begin
    $display("Time:\t%0d", $time);
    $display("instruction:\t%b", instruction);
    $display("wb_sel:\t%b", wb_sel);
    $display("read_sel1:\t%d", read_sel1);
    $display("read_sel2:\t%d", read_sel2);
    $display("write_sel:\t%d", write_sel);
    $display("wEn:\t%b", wEn);
    $display("imm32:\t%b", imm32);
    $display("op_B_sel:\t%b", op_B_sel);
    $display("ALU_Control:\t%b", ALU_Control);
    $display("mem_wEn:\t%b", mem_wEn);
    $display("--------------------------------------------------------------------------------");
    $display("\n\n");
  end
endtask

integer errors = 0;

task check_decode;
  input [31:0] instr;
  input [4:0] exp_read_sel1;
  input [4:0] exp_read_sel2;
  input [4:0] exp_write_sel;
  input exp_wb_sel;
  input exp_wEn;
  input [31:0] exp_imm32;
  input exp_op_B_sel;
  input [5:0] exp_ALU_Control;
  input exp_mem_wEn;
  input [8*30:1] name;
  integer bad;
  begin
    instruction = instr;
    #1;
    bad = 0;
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
    if (wb_sel !== exp_wb_sel) begin
      $display("FAIL  %-30s wb_sel = %b, expected %b", name, wb_sel, exp_wb_sel);
      bad = bad + 1;
    end
    if (wEn !== exp_wEn) begin
      $display("FAIL  %-30s wEn = %b, expected %b", name, wEn, exp_wEn);
      bad = bad + 1;
    end
    if (imm32 !== exp_imm32) begin
      $display("FAIL  %-30s imm32 = %h, expected %h", name, imm32, exp_imm32);
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
    if (bad == 0)
      $display("PASS  %-30s imm32 = %h  ALU_Control = %b", name, imm32, ALU_Control);
    else
      errors = errors + 1;
  end
endtask

initial begin
  $display("Starting Decode Test");
  $display("--------------------------------------------------------------------------------");
  instruction = NOP;
  #10
  // Display output of NOP instruction
  $display("addi zero, zero, 0");
  print_state();
  // Test a new instruction
  instruction = 32'b111111111111_00000_000_01011_0010011; // addi a1, zero, -1

  #10
  $display("addi a1, zero, -1");
  print_state();
  instruction = NOP;

  check_decode(32'b0000000_00111_00110_000_00101_0110011,
               5'd6, 5'd7, 5'd5, 1'b0, 1'b1, 32'h00000000, 1'b0, 6'b000000, 1'b0,
               "add t0, t1, t2");
  check_decode(32'b0100000_01100_01011_000_01000_0110011,
               5'd11, 5'd12, 5'd8, 1'b0, 1'b1, 32'h00000000, 1'b0, 6'b001000, 1'b0,
               "sub s0, a1, a2");
  check_decode(32'b0000000_01111_01011_010_01010_0110011,
               5'd11, 5'd15, 5'd10, 1'b0, 1'b1, 32'h00000000, 1'b0, 6'b000010, 1'b0,
               "slt a0, a1, a5");
  check_decode(32'b0000000_01111_01011_100_01110_0110011,
               5'd11, 5'd15, 5'd14, 1'b0, 1'b1, 32'h00000000, 1'b0, 6'b000100, 1'b0,
               "xor a4, a1, a5");
  check_decode(32'b0000000_01011_01101_111_01101_0110011,
               5'd13, 5'd11, 5'd13, 1'b0, 1'b1, 32'h00000000, 1'b0, 6'b000111, 1'b0,
               "and a3, a3, a1");

  check_decode(32'b000000000001_00000_000_01011_0010011,
               5'd0, 5'd1, 5'd11, 1'b0, 1'b1, 32'h00000001, 1'b1, 6'b000000, 1'b0,
               "addi a1, zero, 1");
  check_decode(32'b111111111111_00000_000_01011_0010011,
               5'd0, 5'd31, 5'd11, 1'b0, 1'b1, 32'hffffffff, 1'b1, 6'b000000, 1'b0,
               "addi a1, zero, -1");

  check_decode(32'b000000001000_00010_010_01010_0000011,
               5'd2, 5'd8, 5'd10, 1'b1, 1'b1, 32'h00000008, 1'b1, 6'b000000, 1'b0,
               "lw a0, 8(sp)");
  check_decode(32'b111111111100_01000_010_00101_0000011,
               5'd8, 5'd28, 5'd5, 1'b1, 1'b1, 32'hfffffffc, 1'b1, 6'b000000, 1'b0,
               "lw t0, -4(s0)");
               
  check_decode(32'b0000000_01011_00010_010_01100_0100011,
               5'd2, 5'd11, 5'd12, 1'b0, 1'b0, 32'h0000000c, 1'b1, 6'b000000, 1'b1,
               "sw a1, 12(sp)");
  check_decode(32'b1111111_01111_01000_010_11000_0100011,
               5'd8, 5'd15, 5'd24, 1'b0, 1'b0, 32'hfffffff8, 1'b1, 6'b000000, 1'b1,
               "sw a5, -8(s0)");

  check_decode(32'h00000000,
               5'd0, 5'd0, 5'd0, 1'b0, 1'b0, 32'h00000000, 1'b0, 6'b000000, 1'b0,
               "all zeros (0x00000000)");

  if (errors == 0) $display("\nALL DECODE TESTS PASSED");
  else $display("\n%0d INSTRUCTION(S) FAILED", errors);

  $finish;

  #10
  $stop();
end

endmodule
