module regFile_tb();

reg clock, reset;

reg         wEn;
reg  [31:0] write_data;
reg  [4:0]  read_sel1, read_sel2, write_sel;
wire [31:0] read_data1, read_data2;

regFile uut (
  .clock(clock),
  .reset(reset),
  .wEn(wEn), // Write Enable
  .write_data(write_data),
  .read_sel1(read_sel1),
  .read_sel2(read_sel2),
  .write_sel(write_sel),
  .read_data1(read_data1),
  .read_data2(read_data2)
);


always #5 clock = ~clock;

integer errors = 0;

task check;
  input [31:0] got;
  input [31:0] expected;
  input [8*50:1] msg;
  begin
    if (got === expected)
      $display("PASS  %0s : %h", msg, got);
    else begin
      $display("FAIL  %0s : got %h, expected %h", msg, got, expected);
      errors = errors + 1;
    end
  end
endtask

task write_reg;
  input [4:0] sel;
  input [31:0] data;
  begin
    @(negedge clock);
    wEn = 1'b1;
    write_sel = sel;
    write_data = data;
    @(negedge clock);
    wEn = 1'b0;
  end
endtask

task read_regs;
  input [4:0] sel1;
  input [4:0] sel2;
  begin
    read_sel1 = sel1;
    read_sel2 = sel2;
    #1;
  end
endtask

initial begin
  clock = 1'b1;
  reset = 1'b1;

  #20;
  reset = 1'b0;

  wEn = 1'b0;
  write_data = 32'h0;
  write_sel = 5'd0;
  read_sel1 = 5'd0;
  read_sel2 = 5'd0;

  read_regs(5'd0, 5'd1);
  check(read_data1, 32'h00000000, "reset: x0 == 0");
  check(read_data2, 32'h00000000, "reset: x1 == 0");
  read_regs(5'd31, 5'd15);
  check(read_data1, 32'h00000000, "reset: x31 == 0");
  check(read_data2, 32'h00000000, "reset: x15 == 0");

  write_reg(5'd1, 32'hDEADBEEF);
  write_reg(5'd2, 32'h12345678);
  read_regs(5'd1, 5'd2);
  check(read_data1, 32'hDEADBEEF, "write/read x1 (port 1)");
  check(read_data2, 32'h12345678, "write/read x2 (port 2)");

  write_reg(5'd0, 32'hFFFFFFFF);
  read_regs(5'd0, 5'd0);
  check(read_data1, 32'h00000000, "write to x0 ignored (port 1)");
  check(read_data2, 32'h00000000, "write to x0 ignored (port 2)");
  check(uut.reg_file[0], 32'h00000000, "reg_file[0] still 0");

  @(negedge clock);
  wEn = 1'b0;
  write_sel = 5'd1;
  write_data = 32'hBAADF00D;
  @(negedge clock);
  read_regs(5'd1, 5'd0);
  check(read_data1, 32'hDEADBEEF, "wEn=0: x1 unchanged");

  @(negedge clock);
  wEn = 1'b1;
  write_sel = 5'd3;
  write_data = 32'hAAAA5555;
  read_regs(5'd3, 5'd3);
  check(read_data1, 32'h00000000, "Read during write: before edge, old x3 (p1)");
  check(read_data2, 32'h00000000, "Read during write: before edge, old x3 (p2)");
  write_reg(5'd3, 32'h5555AAAA);
  read_regs(5'd3, 5'd3);
  check(read_data1, 32'h5555AAAA, "Read during write: after edge, new x3 (p1)");

  if (errors == 0) $display("\nALL REGISTER FILE TESTS PASSED");
  else             $display("\n%0d TEST(S) FAILED", errors);
 
  $finish;
end

endmodule
