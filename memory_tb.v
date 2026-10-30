module memory_tb();

reg clock;
reg wEn;
reg [15:0] address;
reg [31:0] write_data;

wire [31:0] read_data;

memory uut (
  .clock(clock),
  .wEn(wEn),
  .address(address),
  .write_data(write_data),
  .read_data(read_data)
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

task write_word;
  input [15:0] addr;
  input [31:0] data;
  begin
    @(negedge clock);
    address    = addr;
    write_data = data;
    wEn        = 1'b1;
    @(posedge clock);
    #1;
    wEn        = 1'b0;
  end
endtask

task read_word;
  input [15:0] addr;
  begin
    address = addr;
    #1;
  end
endtask

initial begin
  clock = 1'b1;
  address = 16'd0;
  write_data = 16'd0;
  wEn = 1'b0;

  #1
  #10
  wEn = 1'b1;
  #10
  $display("Address %d: %h", address, read_data);
  write_data = 1;
  address = 4;
  #10
  $display("Address %d: %h", address, read_data);
  write_data = 2;
  address = 8;
  #10
  $display("Address %d: %h", address, read_data);

  @(negedge clock);
  wEn = 1'b0;

  read_word(16'd0);
  check(read_data, 32'h00000000, "address 0");
  read_word(16'd4);
  check(read_data, 32'h00000001, "address 4");
  read_word(16'd8);
  check(read_data, 32'h00000002, "address 8");

  write_word(16'h8000, 32'h11111111);
  read_word(16'h8000); check(read_data, 32'h11111111, "address 0x8000");
  read_word(16'h0000); check(read_data, 32'h00000000, "address 0x0000 unchanged");

  write_word(16'h0100, 32'hAAAAAAAA);
  write_word(16'h0104, 32'h55555555);
  read_word(16'h0100); check(read_data, 32'hAAAAAAAA, "adjacent words: 0x0100");
  read_word(16'h0104); check(read_data, 32'h55555555, "adjacent words: 0x0104");

  @(negedge clock);
  address = 16'd4;
  write_data = 32'hCAFEBABE;
  wEn = 1'b0;
  @(posedge clock); #1;
  read_word(16'd4);
  check(read_data, 32'h00000001, "wEn=0: address 4 unchanged");

  write_word(16'd4, 32'hA5A5A5A5);
  read_word(16'd4);
  check(read_data, 32'hA5A5A5A5, "overwrite address 4");

  write_word(16'd16, 32'h00000000);
  @(negedge clock);
  address    = 16'd16;
  write_data = 32'h12345678;
  wEn        = 1'b1;
  #1;
  check(read_data, 32'h00000000, "RDW: before edge, old data");
  @(posedge clock);
  #1;
  wEn = 1'b0;
  check(read_data, 32'h12345678, "RDW: after edge, new data");

  if (errors == 0) $display("\nALL MEMORY TESTS PASSED");
  else $display("\n%0d TEST(S) FAILED", errors);

  $finish;

  #100
  $stop();

end

endmodule
