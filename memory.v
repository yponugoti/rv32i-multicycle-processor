module memory (
  input clock,
  input wEn,
  input [15:0] address,
  input [31:0] write_data,
  output [31:0] read_data
);

reg [31:0] mem [(2**14)-1:0]; // 2^16 bytes or 2^14 words of memory

wire [13:0] word_addr;
wire [1:0] unused_offset;

assign word_addr = address[15:2];
assign unused_offset = address[1:0];

always @ (posedge clock) begin
  if (wEn)
    mem[word_addr] <= write_data;
end

assign read_data = mem[word_addr];

endmodule
