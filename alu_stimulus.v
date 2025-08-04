module ALU_stimulus 	(
			output	reg [4:0]	opcode,
			output	reg [63:0]	A, B
			);

	initial begin


		//1/ADD
		opcode	= 5'b00000;
		A	= 64'd17171;
		B	= 64'd65432;
		#15;
		//2/SUB
		opcode	= 5'b00001;
		A	= 64'd45;
		B	= 64'd13;
		#15;
		//3/SLL
		opcode	= 5'b00010;
		A	= 64'b10100001101110010000111010010101;
		B	= 64'd18;
		#15;
		//4/BXOR
		opcode	= 5'b00011;
		A	= 64'd5651183;
		B	= 64'd9827178;
		#15;	
		//5/SRL
		opcode	= 5'b00100;
		A	= 64'b10100101101100010000111010010101;
		B	= 64'd10;
		#15;
		//6/SRA
		opcode	= 5'b00101;
		A	= 64'd787;
		B	= 64'd790;
		#15;
		//7/BOR
		opcode	= 5'b00110;
		A	= 64'd6737766;
		B	= 64'd2344326;
		#15;
		//8/BAND
		opcode	= 5'b00111;
		A	= 64'd1099269;
		B	= 64'd6755677;
		#15;
		//9/SLTU
		opcode	= 5'b01000;
		A	= 64'd563700;
		B	= 64'd6366790;
		#15;
		//10/BNE
		opcode	= 5'b01001;
		A	= 64'd566789;
		B	= 64'd566789;
		#15;
		//11/BEQ
		opcode	= 5'b01010;
		A	= 64'd667899;
		B	= 64'd667899;
		#15;
		//12/LUI	B - 20-bit - single operand
		opcode	= 5'b01011;
		//A	= 32'd0;
		B	= 64'hF00DA000;
		#15;	
		//13/BLT A - negative B - positive
		opcode	= 5'b01101;
		A	= 64'hDEADBEEF;
		B	= 64'd4500398;
		#15;
		//14/BLTU
		opcode	= 5'b10000;
		A	= 64'd8547999;
		B	= 64'd7849994;
		#15;	
		//14/BGE
		opcode	= 5'b01110;
		A	= 64'd67888467;
		B	= 64'd78599788;
		#15;	
		//16/BGEU
		opcode	= 5'b10001;
		A	= 64'd48989090;
		B	= 64'd89774989;
		#15;

		//17/MUL
		opcode 	= 5'b01100;
		A	= 64'd3;
		B 	= 64'd4;

		#40;

		//18/DIV
		opcode	= 5'b10010;
		A	= 64'd15;
		B 	= 64'd7;
		#25;

		//19/REM
		opcode	= 5'b10100;
		A	= 64'd15;
		B	= 64'd7;
		#25;
                
	end

endmodule
