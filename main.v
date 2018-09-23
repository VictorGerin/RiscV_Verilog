
`timescale 1 ps / 1 ps


module teste();

reg clk, rst;
main m(clk, rst);

initial begin
	clk = 0;
	rst = 1;
	#3 rst = 0;
end

always begin
	#1 clk = ~clk;
	if(m.pc == 'ha4 && m.state == 0)
		$stop();
end



endmodule

module main(
	input clk, rst
);


reg [31:0] pc;
reg [31:0] temp;
reg [31:0] temp2;
reg [4:0] temp_counter;
reg [4:0] temp_counter2;
wire signed [31:0] temp_signed = temp;
reg [31:0] command;

wire [11:0] b_imm = {command[31], command[7], command[30:25], command[11:8], 1'b0};
wire [6:0] func7 = command[31:25];
wire [4:0] rs2 = command[24:20];
wire [4:0] rs1 = command[19:15];
wire [2:0] func3 = command[14:12];
wire [4:0] rd = command[11:7];
wire [6:0] opcode = command[6:0];
wire [11:0] i_imm = {func7, rs2};
wire [11:0] s_imm = {func7, rd};


wire [7:0] memory_out;
reg memory_write;
reg [7:0] memory_in;

reg memory_addr_sel;
wire [31:0] memory_addr = memory_addr_sel ? pc : temp;

memory_maneger mem(
	memory_addr,
	memory_in,
	memory_write,
	~clk,
	memory_out
);

reg [1:0] regs_addr_sel;
reg [4:0] regs_addr;
always @(*) case(regs_addr_sel)
	0 : regs_addr = rd;
	1 : regs_addr = rs1;
	2 : regs_addr = rs2;
	3 : regs_addr = temp[4:0];
endcase
reg regs_write;
wire [31:0] regs_out;
wire signed [31:0] regs_out_signed = regs_out;


registers_bank regs(
	regs_addr,
	temp,
	regs_write,
	~clk,
	regs_out
);

wire [31:0] st2 = opcode == 'b0010011 ? { {20{i_imm[11]}} , i_imm} : regs_out;
wire [31:0] alu_out;
wire op_extend = (opcode == 'b0010011 && func3 != 5) ? 1'b0 : func7[5];

ALU alu (
	temp,
	st2,
	func3,
	op_extend,
	alu_out
);


reg [10:0] state;

always @(posedge clk or negedge rst)
if(~rst) begin
	state <= 0;
	memory_addr_sel <= 1;
	pc <= 32'h0;
end else case(state)
	0 : begin // Start feach
		command[7:0] <= memory_out;
		pc <= pc + 1;
		state <= state + 1;
	end
	1 : begin
		command[15:8] <= memory_out;
		pc <= pc + 1;
		state <= state + 1;
	end
	2 : begin
		command[23:16] <= memory_out;
		pc <= pc + 1;
		state <= state + 1;
	end
	3 : begin
		command[31:24] <= memory_out;
		pc <= pc + 1;
		state <= state + 1;
	end

	4 : begin // Start Execute
		case(opcode)
			'b0110111 : state <= 5;		//Start Execute LUI
			'b0010111 : state <= 7;		//Start Execute AUIPC
			'b1101111 : state <= 9;		//Start Execute JAR
			'b1100111 : state <= 11;	//Start Execute JALR
			'b1100011 : state <= 13;	//Start Execute Conditional Branches
			'b0000011 : state <= 16;	//Start Execute Load Operation
			'b0100011 : state <= 19;	//Start Execute Store Operation
			'b0010011, 'b0110011 : state <= 22;	//Start Execute ALU
		endcase
	end

	5 : begin // Start Execute LUI
		temp <= {func7, rs2, rs1, func3, 12'd0};
		regs_addr_sel <= 0;
		regs_write <= 1;
		state <= state + 1;
	end
	6 : begin
		regs_write <= 0;
		regs_addr_sel <= 0;
		state <= 0;
	end

	7 : begin // Start Execute AUIPC
		temp <= {func7, rs2, rs1, func3, 12'd0} + pc - 4;
		regs_addr_sel <= 0;
		regs_write <= 1;
		state <= 6;
	end

	9 : begin // Start Execute JAR
		temp <= pc;
		pc <= pc + { {12{command[31]}} , command[19:12], command[20], command[30:21], 1'b0} - 4;
		regs_addr_sel <= 0;
		regs_write <= 1;
		state <= 6;
	end

	11 : begin // Start Execute JALR
		regs_addr_sel <= 1;
		state <= state + 1;
	end
	12 : begin
		pc <= regs_out + { {20{i_imm[11]}} , i_imm};
		temp <= pc;
		regs_addr_sel <= 0;
		regs_write <= 1;
		state <= 6;
	end

	13 : begin // Start Execute Conditional Branches
		regs_addr_sel <= 2;
		state <= state + 1;
	end
	14 : begin
		temp <= regs_out;
		regs_addr_sel <= 1;
		state <= state + 1;
	end
	15 : begin
		case(func3)
			0 : if(temp == regs_out) 
				pc <= pc - 4 + {{20{b_imm[11]}}, b_imm};
			1 : if(temp != regs_out) 
				pc <= {{20{b_imm[11]}}, b_imm} + pc - 4;
			4 : if(regs_out_signed < temp_signed) 
				pc <= {{20{b_imm[11]}}, b_imm} + pc - 4;
			5 : if(regs_out_signed > temp_signed) 
				pc <= {{20{b_imm[11]}}, b_imm} + pc - 4;
			6 : if(regs_out < temp) 
				pc <= {{20{b_imm[11]}}, b_imm} + pc - 4;
			default : if(regs_out > temp) 
				pc <= {{20{b_imm[11]}}, b_imm} + pc - 4;
		endcase

		state <= 0;
	end

	16 : begin // Start Execute Load Operation
		case(func3)
			0, 4 : temp_counter <= 1; // Load one byte
			1, 5 : temp_counter <= 2; // Load two bytes
			default : temp_counter <= 4; // Load four bytes
		endcase
		temp_counter2 <= 0;
		regs_addr_sel <= 1;
		memory_addr_sel <= 0;
		state <= state + 1;
	end
	17 : begin
		temp <= { {20{i_imm[11]}} , i_imm} + regs_out + temp_counter2;
		temp_counter2 <= temp_counter2 + 1;
		temp_counter <= temp_counter - 1;

		case (temp_counter)
			0 : temp2[31:24] <= memory_out;
			1 : temp2[23:16] <= memory_out;
			2 : temp2[15:8] <= memory_out;
			default : temp2[7:0] <= memory_out;
		endcase

		if(temp_counter == 0) begin
			state <= state + 1;
			memory_addr_sel <= 1;
		end
	end
	18 : begin
		case(func3)
			0 : temp <= {{24{temp2[7]}}, temp2[7:0]};
			1 : temp <= {{16{temp2[7]}}, temp2[15:0]};
			default : temp <= temp2;
			4 : temp <= {24'd0, temp2[7:0]};
			5 : temp <= {16'd0, temp2[15:0]};
		endcase
		regs_addr_sel <= 0;
		regs_write <= 1;
		state <= 6;
	end

	19 : begin // Start Execute Store Operation
		case(func3)
			0 : temp_counter <= 1; // Load one byte
			1 : temp_counter <= 2; // Load two bytes
			default : temp_counter <= 4; // Load four bytes
		endcase
		temp_counter2 <= 0;
		regs_addr_sel <= 2;
		memory_addr_sel <= 0;
		state <= state + 1;
	end
	20 : begin
		temp2 <= regs_out;
		regs_addr_sel <= 1;
		state <= state + 1;
	end
	21 : begin
		memory_write <= 1;
		temp <= { {20{s_imm[11]}} , s_imm} + regs_out + temp_counter2;
		temp_counter2 <= temp_counter2 + 1;
		temp_counter <= temp_counter - 1;

		case (temp_counter2)
			0 : memory_in <= temp2[7:0];
			1 : memory_in <= temp2[15:8];
			2 : memory_in <= temp2[23:16];
			default : memory_in <= temp2[31:24];
		endcase

		if(temp_counter == 0) begin
			state <= 6;
			memory_write <= 0;
			memory_addr_sel <= 1;
		end
	end

	22 : begin
		regs_addr_sel <= 1;
		state <= state + 1;
	end
	23 : begin
		temp <= regs_out;
		regs_addr_sel <= 2;
		state <= state + 1;
	end
	24 : begin
		temp <= alu_out;
		regs_addr_sel <= 0;
		regs_write <= 1;
		state <= 6;
	end
endcase

endmodule
