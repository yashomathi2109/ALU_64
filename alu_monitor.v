`timescale 1ns/1ps

module ALU_monitor (
    input  [4:0]  opcode,
    input  [63:0] A, B, Y
);

    reg [63:0] BLT, BGE;

    always @ (A, B, opcode) begin
        case (opcode)

        5'b00000:       $display("ADD :	Expected: %0d		Actual: %0d		Result: %s", (A+B), Y, 	((A+B)==Y ? "PASS" : "FAIL"));
	5'b00001:	$display("SUB :	Expected: %0d		Actual: %0d			Result: %s", (A-B), Y, 							((A-B)==Y ? "PASS" : "FAIL"));
	5'b00010:	$display("SLL :	Expected: %0d		Actual: %0d		Result: %s", (A<<B), Y, 				((A<<B)==Y ? "PASS" : "FAIL"));
	5'b00011:	$display("BXOR:	Expected: %0d		Actual: %0d		Result: %s", (A^B), Y, 					((A^B)==Y ? "PASS" : "FAIL"));
	5'b00100:	$display("SRL :	Expected: %0d		Actual: %0d		Result: %s", (A>>B), Y, 				((A>>B)==Y ? "PASS" : "FAIL"));
	5'b00101:	$display("SRA :	Expected: %0d			Actual: %0d			Result: %s", (({A[63],63'd0})|(A>>B)), Y, 			(( ({A[63],63'd0})|(A>>B) )==Y ? "PASS" : "FAIL"));
	5'b00110:	$display("BOR :	Expected: %0d		Actual: %0d		Result: %s", (A|B), Y, 							((A|B)==Y ? "PASS" : "FAIL"));
	5'b00111:	$display("BAND:	Expected: %0d		Actual: %0d			Result: %s", (A&B), Y, 							((A&B)==Y ? "PASS" : "FAIL"));
	5'b01000:	$display("SLTU:	Expected: %0d			Actual: %0d			Result: %s", (A<B ? 1 : 0), Y, 					(((A<B ? 1 : 0)==Y) ? "PASS" : "FAIL"));
	5'b01001:	$display("BNE :	Expected: %0d			Actual: %0d			Result: %s", (A!=B ? 0 : 1), Y, 					(((A!=B ? 0 : 1)==Y) ? "PASS" : "FAIL"));
	5'b01010:	$display("BEQ :	Expected: %0d			Actual: %0d			Result: %s", (A==B ? 1 : 0), Y, 					(((A==B ? 1 : 0)==Y) ? "PASS" : "FAIL"));
	5'b01011:	$display("LUI :	Expected: %0d		Actual: %0d		Result: %s", B, Y, 							((B==Y) ? "PASS" : "FAIL"));
	5'b10000:	$display("BLTU:	Expected: %0d			Actual: %0d			Result: %s", (A<B ? 0 : 1), Y, 					(((A<B ? 0 : 1)==Y) ? "PASS" : "FAIL"));
	5'b10001:	$display("BGEU:	Expected: %0d			Actual: %0d			Result: %s", (A>=B ? 0 : 1), Y, 					(((A>=B ? 0 : 1)==Y) ? "PASS" : "FAIL"));

            5'b01101:	begin
				BLT = 	(A[63] < B[63])						? 64'd1 :		
		    			(A[63] == 0 && (A[62:0] < B[62:0]))		? 64'd1 :		
		    			(A[63] == 1 && (A[62:0] > B[62:0]))		? 64'd1 : 64'd0;	
				$display("BLT :	Expected: %0d			Actual: %0d			Result: %s", BLT, Y, 					((BLT==Y) ? "PASS" : "FAIL"));
			end

            5'b01110:	begin
				BGE =	(A[63] < B[63])						? 64'd1 :	
						(A[63] == 0 && (A[62:0] >= B[62:0]))	? 64'd1 :		
						(A[63] == 1 && (A[62:0] <= B[62:0]))	? 64'd1 : 64'd0;
				$display("BGE :	Expected: %0d			Actual: %0d			Result: %s", BGE, Y, 					((BGE==Y) ? "PASS" : "FAIL"));
			end

            5'b01100: $display("MUL : 	Expected: %0d		Actual: %0d			Result: %s",  (A * B), Y, ((A * B) == Y ? "PASS" : "FAIL"));
            5'b10010: $display("DIV : 	Expected: %0d			Actual: %0d			Result: %s",  (A / B), Y, ((A / B) == Y ? "PASS" : "FAIL"));
            5'b10100: $display("REM : 	Expected: %0d			Actual: %0d			Result: %s",  (A % B), Y, ((A % B) == Y ? "PASS" : "FAIL"));
            default:  $display("//.......NO OPERATION.......//");
        endcase
    end

endmodule
