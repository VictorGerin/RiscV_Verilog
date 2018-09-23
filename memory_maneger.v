
`timescale 1 ps / 1 ps

module memory_maneger(
	input [31:0] addr,
	input [7:0] data,
	input write,
	input clk,
	output reg [7:0] q
);

reg wren;
wire [7:0] ram_q;

always @(*)
if(addr > 'h10000) begin
	wren = 1'b0;
	q = 0;
end else begin
	wren = write;
	q = ram_q;
end

ram r(
	addr[15:0],
	clk,
	data,
	wren,
	ram_q);

endmodule
