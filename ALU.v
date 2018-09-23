
`timescale 1 ps / 1 ps

module ALU (
	input signed [31:0] scr1,
	input [31:0] scr2,
	input [2:0] op,
	input op_extend,
	output reg [31:0] out
);

wire [31:0] diff = scr1 - scr2;

always @(*) case(op)
	3'b000 : out = op_extend ? diff : scr1 + scr2;
	3'b001 : out = scr1 << scr2[4:0];
	3'b010 : out = scr1 < scr2;
	3'b011 : out = diff[0];
	3'b100 : out = scr1 ^ scr2;
	3'b101 : out = op_extend ? scr1 >>> scr2[4:0] :  scr1 >> scr2[4:0] ;
	3'b110 : out = scr1 | scr2;
	3'b111 : out = scr1 & scr2;

endcase


endmodule
