module ALU_tb();

reg [5:0] ctrl;
reg [31:0] opA, opB;

wire [31:0] result;

ALU dut (
  .ALU_Control(ctrl),
  .operand_A(opA),
  .operand_B(opB),
  .ALU_result(result)
);

localparam ADD = 6'b000000;
localparam SUB = 6'b001000;
localparam SLT = 6'b000010;
localparam XOR = 6'b000100;
localparam AND = 6'b000111;

integer errors = 0;

task check;
  input [5:0] c;
  input [31:0] a, b;
  input [31:0] expected;
  input [8*36:1] msg;
  begin
    ctrl = c; opA = a; opB = b;
    #10;
    if (result === expected)
      $display("PASS  %-36s A=%h B=%h -> %h", msg, a, b, result);
    else begin
      $display("FAIL  %-36s A=%h B=%h -> %h (expected %h)",
               msg, a, b, result, expected);
      errors = errors + 1;
    end
  end
endtask

initial begin
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

  // Add other test cases here
  //
  //
  //

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

  check(6'b111111, 32'd4, 32'd5, 32'd0, "unused ctrl -> 0");

  if (errors == 0) $display("\nALL ALU TESTS PASSED");
  else             $display("\n%0d TEST(S) FAILED", errors);
 
  $finish;

end

endmodule
