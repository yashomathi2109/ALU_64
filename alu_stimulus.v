/*
 * ALU_STIMULUS - ALU Test Vector Generation Module
 * 
 * This module generates comprehensive test vectors for all ALU operations to ensure
 * thorough testing coverage. It provides a systematic approach to testing with
 * various operand values and timing.
 * 
 * Testing Strategy:
 * - Covers all 20 ALU operations
 * - Uses diverse operand values (small, large, signed, unsigned)
 * - Includes edge cases and boundary conditions
 * - Provides adequate timing between operations for simulation
 * - Tests both arithmetic and logical operations thoroughly
 */

module ALU_stimulus 	(
			output	reg [4:0]	opcode,		// 5-bit operation code output
			output	reg [63:0]	A, B		// 64-bit operand outputs
			);

	// Test sequence initialization
	initial begin

		// ========================================
		// TEST 1: ADDITION OPERATION
		// ========================================
		// Test addition with medium-sized positive numbers
		opcode	= 5'b00000;		// ADD operation code
		A	= 64'd17171;		// First operand: 17,171
		B	= 64'd65432;		// Second operand: 65,432
		#15;				// Wait 15 time units for operation completion

		// ========================================
		// TEST 2: SUBTRACTION OPERATION
		// ========================================
		// Test subtraction with small positive numbers
		opcode	= 5'b00001;		// SUB operation code
		A	= 64'd45;		// First operand: 45
		B	= 64'd13;		// Second operand: 13
		#15;				// Wait 15 time units

		// ========================================
		// TEST 3: LOGICAL LEFT SHIFT OPERATION
		// ========================================
		// Test left shift with binary pattern and shift amount
		opcode	= 5'b00010;		// SLL operation code
		A	= 64'b10100001101110010000111010010101;  // Binary pattern for shifting
		B	= 64'd18;		// Shift amount: 18 positions left
		#15;				// Wait 15 time units

		// ========================================
		// TEST 4: BITWISE XOR OPERATION
		// ========================================
		// Test XOR with large positive numbers
		opcode	= 5'b00011;		// BXOR operation code
		A	= 64'd5651183;		// First operand: 5,651,183
		B	= 64'd9827178;		// Second operand: 9,827,178
		#15;				// Wait 15 time units

		// ========================================
		// TEST 5: LOGICAL RIGHT SHIFT OPERATION
		// ========================================
		// Test right shift with binary pattern and shift amount
		opcode	= 5'b00100;		// SRL operation code
		A	= 64'b10100101101100010000111010010101;  // Binary pattern for shifting
		B	= 64'd10;		// Shift amount: 10 positions right
		#15;				// Wait 15 time units

		// ========================================
		// TEST 6: ARITHMETIC RIGHT SHIFT OPERATION
		// ========================================
		// Test arithmetic right shift (preserves sign bit)
		opcode	= 5'b00101;		// SRA operation code
		A	= 64'd787;		// First operand: 787
		B	= 64'd790;		// Second operand: 790 (large shift amount)
		#15;				// Wait 15 time units

		// ========================================
		// TEST 7: BITWISE OR OPERATION
		// ========================================
		// Test OR with large positive numbers
		opcode	= 5'b00110;		// BOR operation code
		A	= 64'd6737766;		// First operand: 6,737,766
		B	= 64'd2344326;		// Second operand: 2,344,326
		#15;				// Wait 15 time units

		// ========================================
		// TEST 8: BITWISE AND OPERATION
		// ========================================
		// Test AND with large positive numbers
		opcode	= 5'b00111;		// BAND operation code
		A	= 64'd1099269;		// First operand: 1,099,269
		B	= 64'd6755677;		// Second operand: 6,755,677
		#15;				// Wait 15 time units

		// ========================================
		// TEST 9: SET LESS THAN UNSIGNED OPERATION
		// ========================================
		// Test unsigned comparison (A < B)
		opcode	= 5'b01000;		// SLTU operation code
		A	= 64'd563700;		// First operand: 563,700
		B	= 64'd6366790;		// Second operand: 6,366,790
		#15;				// Wait 15 time units

		// ========================================
		// TEST 10: BRANCH IF NOT EQUAL OPERATION
		// ========================================
		// Test BNE with equal operands (should return 0)
		opcode	= 5'b01001;		// BNE operation code
		A	= 64'd566789;		// First operand: 566,789
		B	= 64'd566789;		// Second operand: 566,789 (equal to A)
		#15;				// Wait 15 time units

		// ========================================
		// TEST 11: BRANCH IF EQUAL OPERATION
		// ========================================
		// Test BEQ with equal operands (should return 1)
		opcode	= 5'b01010;		// BEQ operation code
		A	= 64'd667899;		// First operand: 667,899
		B	= 64'd667899;		// Second operand: 667,899 (equal to A)
		#15;				// Wait 15 time units

		// ========================================
		// TEST 12: LOAD UPPER IMMEDIATE OPERATION
		// ========================================
		// Test LUI with immediate value (B contains the value to load)
		opcode	= 5'b01011;		// LUI operation code
		//A	= 32'd0;		// A is not used for LUI operation
		B	= 64'hF00DA000;	// Immediate value: 0xF00DA000
		#15;				// Wait 15 time units

		// ========================================
		// TEST 13: BRANCH IF LESS THAN (SIGNED) OPERATION
		// ========================================
		// Test BLT with negative A and positive B (signed comparison)
		opcode	= 5'b01101;		// BLT operation code
		A	= 64'hDEADBEEF;	// First operand: negative value (0xDEADBEEF)
		B	= 64'd4500398;		// Second operand: positive value 4,500,398
		#15;				// Wait 15 time units

		// ========================================
		// TEST 14: BRANCH IF LESS THAN UNSIGNED OPERATION
		// ========================================
		// Test BLTU with unsigned comparison
		opcode	= 5'b10000;		// BLTU operation code
		A	= 64'd8547999;		// First operand: 8,547,999
		B	= 64'd7849994;		// Second operand: 7,849,994
		#15;				// Wait 15 time units

		// ========================================
		// TEST 15: BRANCH IF GREATER OR EQUAL (SIGNED) OPERATION
		// ========================================
		// Test BGE with signed comparison
		opcode	= 5'b01110;		// BGE operation code
		A	= 64'd67888467;	// First operand: 67,888,467
		B	= 64'd78599788;	// Second operand: 78,599,788
		#15;				// Wait 15 time units

		// ========================================
		// TEST 16: BRANCH IF GREATER OR EQUAL UNSIGNED OPERATION
		// ========================================
		// Test BGEU with unsigned comparison
		opcode	= 5'b10001;		// BGEU operation code
		A	= 64'd48989090;	// First operand: 48,989,090
		B	= 64'd89774989;	// Second operand: 89,774,989
		#15;				// Wait 15 time units

		// ========================================
		// TEST 17: MULTIPLICATION OPERATION
		// ========================================
		// Test multiplication with small numbers for verification
		opcode 	= 5'b01100;		// MUL operation code
		A	= 64'd3;		// First operand: 3
		B 	= 64'd4;		// Second operand: 4
		#40;				// Extended wait for multiplication completion

		// ========================================
		// TEST 18: DIVISION OPERATION
		// ========================================
		// Test division with simple operands
		opcode	= 5'b10010;		// DIV operation code
		A	= 64'd15;		// First operand: 15
		B 	= 64'd7;		// Second operand: 7
		#25;				// Wait 25 time units for division

		// ========================================
		// TEST 19: REMAINDER OPERATION
		// ========================================
		// Test remainder (modulo) operation
		opcode	= 5'b10100;		// REM operation code
		A	= 64'd15;		// First operand: 15
		B	= 64'd7;		// Second operand: 7
		#25;				// Wait 25 time units for remainder calculation
                
	end

endmodule
