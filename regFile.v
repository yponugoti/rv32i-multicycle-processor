module regFile (
  input clock,
  input reset,
  input wEn, // Write Enable
  input [31:0] write_data,
  input [4:0] read_sel1,
  input [4:0] read_sel2,
  input [4:0] write_sel,
  output [31:0] read_data1,
  output [31:0] read_data2
);

reg   [31:0] reg_file[0:31];

/******************************************************************************
*                      Start Your Code Here
******************************************************************************/

integer i;

always @ (posedge clock) begin
  if (reset) begin
    for (i = 0; i < 32; i = i + 1)
      reg_file[i] <= 32'h00000000;
  end
  else if (wEn && (write_sel != 5'd0)) begin
    reg_file[write_sel] <= write_data;
  end
end

assign read_data1 = (read_sel1 == 5'd0) ? 32'h00000000 : reg_file[read_sel1];
assign read_data2 = (read_sel2 == 5'd0) ? 32'h00000000 : reg_file[read_sel2];

endmodule

