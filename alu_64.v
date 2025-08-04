//--------------------------------------------------//
//	**Project: 5-Stage pipelined RISC-V softcore
//	
//	**Module name and description:
//
//	**Author: Adithya Ramesh, aramesh1@wpi.edu
//--------------------------------------------------//

module alu_64	(input		[4:0]	opcode,
		input		[63:0]	A, B,
		output			carry, zero,
		output	reg	[63:0]	Y
		);

reg adder_out;
//using 64x64 carry select adder instead of basic addition 
wire [63:0] adder_result;
CSelA64 adder_unit(
    .sum(adder_result), 
    .cout(adder_out), 
    .a(A), 
    .b(B)
);

//using dadda 64x64 instead of basic multiplication
wire [63:0] mult_result;
mult_output mult_unit (
    .A(A),
    .B(B),
    .opcode(mul),
    .Y(mult_result)
);

/*
//using 64x64 floating point adder instead of integer addition 
wire [63:0] fadd_result;
wire overflow;
wire underflow;

fpu_adder_sub float_adder_unit(
    .a(A), 
    .b(B),
    .result(fadd_result),
    .overflow(overflow),
    .underflow(underflow)

);
*/

localparam	add = 5'b00000,		sub = 5'b00001,		sll  = 5'b00010,
		bxor = 5'b00011,	srl = 5'b00100,		sra  = 5'b00101,
		bor  = 5'b00110,	band = 5'b00111,	sltu = 5'b01000,
		bne = 5'b01001,		beq = 5'b01010,		lui  = 5'b01011,
		blt = 5'b01101,		bltu = 5'b10000,	bge = 5'b01110,
		bgeu = 5'b10001,	mul = 5'b01100,		mulhu = 5'b01111,
		div = 5'b10010,		rem = 5'b10100;



always @ (*) begin
	case(opcode)
		//Bitwise operations
		//add:	{adder_out, Y} = A + B;
                add:	Y = adder_result;
		sub: 	Y = A - B;
		bxor: 	Y = A ^ B;
		bor:  	Y = A | B;
		band: 	Y = A & B;

		//Shift operations
		srl: 	Y = A >> B;
		sll: 	Y = A << B;
		sra: 	Y = {A[63], 63'd0} | (A >> B);

		//Set operations
		sltu: 	Y = (A < B)	? 1'b1 : 1'b0;

		//...... Branch Operations ......
		//**branch if equal - not equal**		
		beq: 	Y = (A == B)	? 64'd1 : 64'd0;
		bne: 	Y = (A != B)	? 64'd0 : 64'd1;

		//**branch if greater than or euqal signed - unsigned**
		bge:	Y = (A[63] < B[63])				? 64'd1 :		//if A is +ve (MSB - 0) and B is -ve (MSB - 1)
			    (A[63] == 0 && (A[62:0] >= B[62:0]))	? 64'd1 :		//if they are +ve
			    (A[63] == 1 && (A[62:0] <= B[62:0]))	? 64'd1 : 64'd0;	//if they are -ve
		bgeu:	Y = (A >= B)					? 64'd0 : 64'd1;

		//**branch if less than signed - unsigned**
		blt:	Y = (A[63] < B[63])				? 64'd1 :		//if A is +ve (MSB - 0) and B is -ve (MSB - 1)
			    (A[63] == 0 && (A[62:0] < B[62:0]))		? 64'd1 :		//if they are +ve
			    (A[63] == 1 && (A[62:0] > B[62:0]))		? 64'd1 : 64'd0;	//if they are -ve
		bltu:	Y = (A < B)					? 64'd0 : 64'd1;

		//**branch if = to 0 - != to 0**
		//bez:	Y = (A == 0) ? 32'd1 : 32'd0; 
		//bnez	Y = (A != 0) ? 32'd0 : 32'd1;

		//Load Upper Immediate
		lui:	Y = B;

		//Multiplication operation:
		//mul: 	Y = A*B;

                // Multiplication using Dadda
                mul:   Y = mult_result;  // Lower 32 bits


		//Division and remainder:
		div:	Y = A/B;
		rem:	Y = A%B;

                //floating point addition
                //f64_add:  Y= fadd_result;

		default: Y = 4'd0;
	endcase
end

assign carry	=	(opcode == add && adder_out == 1)	?	1'b1 :
			(opcode == bge && Y == 1	)	?	1'b1 :
			(opcode == blt && Y == 1	)	?	1'b1 :
			(opcode == beq && Y == 1	)	?	1'b1 : 1'b0;
assign zero	=	(Y == 64'd0			)	?	1'b1 : 1'b0;

endmodule
