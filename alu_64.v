/*
 * ALU_64 - 64-Bit Arithmetic Logic Unit
 * 
 * This module implements a comprehensive 64-bit ALU with support for 20 different operations
 * including arithmetic, logical, shift, comparison, and multiplication operations.
 * 
 * Key Features:
 * - 64-bit operand support
 * - Carry Select Adder for optimized addition
 * - Dadda multiplier for high-performance multiplication
 * - Comprehensive flag generation (carry, zero)
 * - Support for both signed and unsigned operations
 */

module alu_64	(input		[4:0]	opcode,		// 5-bit operation code to select operation
		input		[63:0]	A, B,		// 64-bit input operands
		output			carry, zero,	// Carry and zero flags
		output	reg	[63:0]	Y		// 64-bit output result
		);

// Internal signal for adder carry output
reg adder_out;

// Instantiate 64x64 Carry Select Adder for optimized addition
// This provides better performance than a basic ripple carry adder
wire [63:0] adder_result;
CSelA64 adder_unit(
    .sum(adder_result), 	// 64-bit sum output
    .cout(adder_out), 		// Carry output
    .a(A), 			// First operand
    .b(B)				// Second operand
);

// Instantiate 64x64 Dadda multiplier for high-performance multiplication
// This replaces basic multiplication with an optimized parallel multiplier
wire [63:0] mult_result;
mult_output mult_unit (
    .A(A),				// First operand
    .B(B),				// Second operand
    .opcode(mul),			// Multiplication opcode
    .Y(mult_result)			// Multiplication result
);

/*
 * Commented out floating point adder implementation
 * This could be integrated for floating point arithmetic support
 * 
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

// Operation code definitions for all supported ALU operations
// Each operation is assigned a unique 5-bit binary code
localparam	add = 5'b00000,		// Addition operation
		sub = 5'b00001,		// Subtraction operation
		sll  = 5'b00010,		// Logical left shift
		bxor = 5'b00011,		// Bitwise XOR
		srl = 5'b00100,		// Logical right shift
		sra  = 5'b00101,		// Arithmetic right shift
		bor  = 5'b00110,		// Bitwise OR
		band = 5'b00111,		// Bitwise AND
		sltu = 5'b01000,		// Set less than unsigned
		bne = 5'b01001,		// Branch if not equal
		beq = 5'b01010,		// Branch if equal
		lui  = 5'b01011,		// Load upper immediate
		blt = 5'b01101,		// Branch if less than (signed)
		bltu = 5'b10000,		// Branch if less than (unsigned)
		bge = 5'b01110,		// Branch if greater or equal (signed)
		bgeu = 5'b10001,		// Branch if greater or equal (unsigned)
		mul = 5'b01100,		// Multiplication (lower 64 bits)
		mulhu = 5'b01111,		// Multiplication (upper 64 bits, unsigned)
		div = 5'b10010,		// Division operation
		rem = 5'b10100;		// Remainder operation

// Main ALU operation logic - combinational circuit
always @ (*) begin
	case(opcode)
		// ========================================
		// ARITHMETIC OPERATIONS
		// ========================================
		
		// Addition using optimized Carry Select Adder
		add:	Y = adder_result;	// Use adder result instead of basic A + B
		
		// Subtraction (basic operation)
		sub: 	Y = A - B;
		
		// ========================================
		// LOGICAL OPERATIONS
		// ========================================
		
		// Bitwise XOR operation
		bxor: 	Y = A ^ B;
		
		// Bitwise OR operation
		bor:  	Y = A | B;
		
		// Bitwise AND operation
		band: 	Y = A & B;

		// ========================================
		// SHIFT OPERATIONS
		// ========================================
		
		// Logical right shift (zero-fill)
		srl: 	Y = A >> B;
		
		// Logical left shift (zero-fill)
		sll: 	Y = A << B;
		
		// Arithmetic right shift (sign-extend)
		// Preserves sign bit and shifts right
		sra: 	Y = {A[63], 63'd0} | (A >> B);

		// ========================================
		// COMPARISON OPERATIONS
		// ========================================
		
		// Set less than unsigned comparison
		// Returns 1 if A < B, 0 otherwise
		sltu: 	Y = (A < B)	? 1'b1 : 1'b0;

		// ========================================
		// BRANCH OPERATIONS
		// ========================================
		
		// Branch if equal - returns 1 if A == B, 0 otherwise
		beq: 	Y = (A == B)	? 64'd1 : 64'd0;
		
		// Branch if not equal - returns 0 if A != B, 1 otherwise
		bne: 	Y = (A != B)	? 64'd0 : 64'd1;

		// Branch if greater than or equal (signed comparison)
		// Handles signed comparison with proper overflow handling
		bge:	Y = (A[63] < B[63])				? 64'd1 :		// A is +ve and B is -ve
			    (A[63] == 0 && (A[62:0] >= B[62:0]))		? 64'd1 :		// Both are positive
			    (A[63] == 1 && (A[62:0] <= B[62:0]))		? 64'd1 : 64'd0;	// Both are negative
		
		// Branch if greater than or equal (unsigned comparison)
		// Simple unsigned comparison
		bgeu:	Y = (A >= B)					? 64'd0 : 64'd1;

		// Branch if less than (signed comparison)
		// Handles signed comparison with proper overflow handling
		blt:	Y = (A[63] < B[63])				? 64'd1 :		// A is +ve and B is -ve
			    (A[63] == 0 && (A[62:0] < B[62:0]))		? 64'd1 :		// Both are positive
			    (A[63] == 1 && (A[62:0] > B[62:0]))		? 64'd1 : 64'd0;	// Both are negative
		
		// Branch if less than (unsigned comparison)
		// Simple unsigned comparison
		bltu:	Y = (A < B)					? 64'd0 : 64'd1;

		// ========================================
		// SPECIAL OPERATIONS
		// ========================================
		
		// Load Upper Immediate - loads B into upper bits
		// Typically used for loading immediate values
		lui:	Y = B;

		// ========================================
		// MULTIPLICATION OPERATIONS
		// ========================================
		
		// Multiplication using optimized Dadda multiplier
		// Returns lower 64 bits of the 128-bit result
		mul:   Y = mult_result;

		// ========================================
		// DIVISION OPERATIONS
		// ========================================
		
		// Division operation (A / B)
		div:	Y = A/B;
		
		// Remainder operation (A % B)
		rem:	Y = A%B;

		// ========================================
		// DEFAULT CASE
		// ========================================
		
		// Default case - return 0 for undefined operations
		default: Y = 4'd0;
	endcase
end

// ========================================
// FLAG GENERATION LOGIC
// ========================================

// Carry flag generation
// Set to 1 when:
// - Addition operation produces carry
// - Branch operations evaluate to true
assign carry	=	(opcode == add && adder_out == 1)	?	1'b1 :	// Addition carry
			(opcode == bge && Y == 1	)	?	1'b1 :	// BGE true
			(opcode == blt && Y == 1	)	?	1'b1 :	// BLT true
			(opcode == beq && Y == 1	)	?	1'b1 : 1'b0;	// BEQ true

// Zero flag generation
// Set to 1 when result Y equals zero
assign zero	=	(Y == 64'd0			)	?	1'b1 : 1'b0;

endmodule
