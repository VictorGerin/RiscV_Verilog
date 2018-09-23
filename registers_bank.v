
`timescale 1 ps / 1 ps

module registers_bank(
	input [4:0] addr,
	input [31:0] data,
	input write,
	input clk,
	output reg [31:0] q
);

reg [31:0] registers [0:30];
wire [4:0] addr_fix = addr - 5'd1;

always @(*) begin
	if(addr == 0)
		q = 0;
	else
		q = registers[addr_fix];
end

always @(posedge clk) if(write & addr != 0) begin
	registers[addr_fix] <= data;
end

endmodule
