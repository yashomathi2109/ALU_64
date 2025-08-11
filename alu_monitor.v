/*
 * ALU_MONITOR - ALU Result Verification Module
 * 
 * This module monitors the ALU operations and verifies that the results match
 * expected values. It provides comprehensive testing coverage for all ALU operations
 * with automatic pass/fail reporting.
 * 
 * Features:
 * - Real-time result verification
 * - Automatic expected vs. actual comparison
 * - Detailed operation logging
 * - Support for all 20 ALU operations
 * - Signed and unsigned comparison handling
 */

`timescale 1ns/1ps

module ALU_monitor (
    input  [4:0]  opcode,    // 5-bit operation code from ALU
    input  [63:0] A, B,      // 64-bit input operands
    input  [63:0] Y          // 64-bit ALU result to verify
);

    // Internal signals for complex comparison operations
    // These store the expected results for signed comparisons
    reg [63:0] BLT, BGE;

    // Monitor and verify ALU results whenever inputs change
    always @ (A, B, opcode) begin
        case (opcode)

        // ========================================
        // ARITHMETIC OPERATIONS VERIFICATION
        // ========================================
        
        // Addition operation verification
        5'b00000: $display("ADD :	Expected: %0d		Actual: %0d		Result: %s", 
                          (A+B), Y, ((A+B)==Y ? "PASS" : "FAIL"));
        
        // Subtraction operation verification
	5'b00001:	$display("SUB :	Expected: %0d		Actual: %0d		Result: %s", 
                          (A-B), Y, ((A-B)==Y ? "PASS" : "FAIL"));
        
        // ========================================
        // SHIFT OPERATIONS VERIFICATION
        // ========================================
        
        // Logical left shift verification
	5'b00010:	$display("SLL :	Expected: %0d		Actual: %0d		Result: %s", 
                          (A<<B), Y, ((A<<B)==Y ? "PASS" : "FAIL"));
        
        // Logical right shift verification
	5'b00100:	$display("SRL :	Expected: %0d		Actual: %0d		Result: %s", 
                          (A>>B), Y, ((A>>B)==Y ? "PASS" : "FAIL"));
        
        // Arithmetic right shift verification
        // Preserves sign bit during right shift
	5'b00101:	$display("SRA :	Expected: %0d		Actual: %0d		Result: %s", 
                          (({A[63],63'd0})|(A>>B)), Y, 
                          ((({A[63],63'd0})|(A>>B))==Y ? "PASS" : "FAIL"));
        
        // ========================================
        // LOGICAL OPERATIONS VERIFICATION
        // ========================================
        
        // Bitwise XOR verification
	5'b00011:	$display("BXOR:	Expected: %0d		Actual: %0d		Result: %s", 
                          (A^B), Y, ((A^B)==Y ? "PASS" : "FAIL"));
        
        // Bitwise OR verification
	5'b00110:	$display("BOR :	Expected: %0d		Actual: %0d		Result: %s", 
                          (A|B), Y, ((A|B)==Y ? "PASS" : "FAIL"));
        
        // Bitwise AND verification
	5'b00111:	$display("BAND:	Expected: %0d		Actual: %0d		Result: %s", 
                          (A&B), Y, ((A&B)==Y ? "PASS" : "FAIL"));
        
        // ========================================
        // COMPARISON OPERATIONS VERIFICATION
        // ========================================
        
        // Set less than unsigned verification
	5'b01000:	$display("SLTU:	Expected: %0d		Actual: %0d		Result: %s", 
                          (A<B ? 1 : 0), Y, (((A<B ? 1 : 0)==Y) ? "PASS" : "FAIL"));
        
        // ========================================
        // BRANCH OPERATIONS VERIFICATION
        // ========================================
        
        // Branch if not equal verification
	5'b01001:	$display("BNE :	Expected: %0d		Actual: %0d		Result: %s", 
                          (A!=B ? 0 : 1), Y, (((A!=B ? 0 : 1)==Y) ? "PASS" : "FAIL"));
        
        // Branch if equal verification
	5'b01010:	$display("BEQ :	Expected: %0d		Actual: %0d		Result: %s", 
                          (A==B ? 1 : 0), Y, (((A==B ? 1 : 0)==Y) ? "PASS" : "FAIL"));
        
        // ========================================
        // SPECIAL OPERATIONS VERIFICATION
        // ========================================
        
        // Load upper immediate verification
        // B contains the immediate value to be loaded
	5'b01011:	$display("LUI :	Expected: %0d		Actual: %0d		Result: %s", 
                          B, Y, ((B==Y) ? "PASS" : "FAIL"));
        
        // ========================================
        // UNSIGNED BRANCH OPERATIONS VERIFICATION
        // ========================================
        
        // Branch if less than unsigned verification
	5'b10000:	$display("BLTU:	Expected: %0d		Actual: %0d		Result: %s", 
                          (A<B ? 0 : 1), Y, (((A<B ? 0 : 1)==Y) ? "PASS" : "FAIL"));
        
        // Branch if greater or equal unsigned verification
	5'b10001:	$display("BGEU:	Expected: %0d		Actual: %0d		Result: %s", 
                          (A>=B ? 0 : 1), Y, (((A>=B ? 0 : 1)==Y) ? "PASS" : "FAIL"));
        
        // ========================================
        // SIGNED BRANCH OPERATIONS VERIFICATION
        // ========================================
        // These operations require special handling for signed comparison
        
        // Branch if less than (signed) verification
        // Handles signed comparison with proper overflow consideration
            5'b01101:	begin
				// Calculate expected result for signed comparison
				// Considers sign bits and magnitude for proper signed comparison
				BLT = 	(A[63] < B[63])						? 64'd1 :		// A is +ve and B is -ve
		    			(A[63] == 0 && (A[62:0] < B[62:0]))		? 64'd1 :		// Both are positive
		    			(A[63] == 1 && (A[62:0] > B[62:0]))		? 64'd1 : 64'd0;	// Both are negative
				
				$display("BLT :	Expected: %0d		Actual: %0d		Result: %s", 
                                        BLT, Y, ((BLT==Y) ? "PASS" : "FAIL"));
			end

        // Branch if greater or equal (signed) verification
        // Handles signed comparison with proper overflow consideration
            5'b01110:	begin
				// Calculate expected result for signed comparison
				// Considers sign bits and magnitude for proper signed comparison
				BGE =	(A[63] < B[63])						? 64'd1 :		// A is +ve and B is -ve
						(A[63] == 0 && (A[62:0] >= B[62:0]))	? 64'd1 :		// Both are positive
						(A[63] == 1 && (A[62:0] <= B[62:0]))	? 64'd1 : 64'd0;	// Both are negative
				
				$display("BGE :	Expected: %0d		Actual: %0d		Result: %s", 
                                        BGE, Y, ((BGE==Y) ? "PASS" : "FAIL"));
			end

        // ========================================
        // ARITHMETIC OPERATIONS VERIFICATION (CONTINUED)
        // ========================================
        
        // Multiplication verification
        // Compares ALU result with expected multiplication result
            5'b01100: $display("MUL : 	Expected: %0d		Actual: %0d		Result: %s",  
                              (A * B), Y, ((A * B) == Y ? "PASS" : "FAIL"));
        
        // Division verification
        // Compares ALU result with expected division result
            5'b10010: $display("DIV : 	Expected: %0d		Actual: %0d		Result: %s",  
                              (A / B), Y, ((A / B) == Y ? "PASS" : "FAIL"));
        
        // Remainder verification
        // Compares ALU result with expected remainder result
            5'b10100: $display("REM : 	Expected: %0d		Actual: %0d		Result: %s",  
                              (A % B), Y, ((A % B) == Y ? "PASS" : "FAIL"));
        
        // ========================================
        // DEFAULT CASE
        // ========================================
        
        // Handle undefined or unsupported operations
        default:  $display("//.......NO OPERATION.......//");
        endcase
    end

endmodule
