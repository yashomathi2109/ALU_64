/*
 * DADDA_TB - Dadda Multiplier Testbench
 * 
 * This testbench verifies the functionality of the Dadda multiplier by testing
 * various multiplication scenarios including normal multiplication and high-precision
 * operations. It provides comprehensive testing with automatic result verification.
 * 
 * Test Coverage:
 * - Basic multiplication (MUL)
 * - High-precision unsigned multiplication (MULHU)
 * - Edge cases with large numbers
 * - Small number multiplication
 * - Automatic pass/fail reporting
 */

`timescale 1ns/1ps

module mult_output_tb;

    // ========================================
    // TESTBENCH SIGNALS
    // ========================================
    
    // Input signals for the multiplier
    reg [63:0] A, B;         // 64-bit input operands
    reg [4:0] opcode;        // 5-bit operation code

    // Output signal from the multiplier
    wire [63:0] Y;           // 64-bit multiplication result

    // ========================================
    // UNIT UNDER TEST (UUT) INSTANTIATION
    // ========================================
    
    // Instantiate the multiplier output module for testing
    mult_output uut (
        .A(A),               // First operand
        .B(B),               // Second operand
        .opcode(opcode),     // Operation selection
        .Y(Y)                // Result output
    );

    // ========================================
    // TEST VARIABLES
    // ========================================
    
    // Reference values for result verification
    reg [127:0] expected_full;    // Full 128-bit expected result
    reg [63:0] expected_result;   // 64-bit expected result for comparison
    string op_name;               // Operation name for display

    // ========================================
    // TEST EXECUTION
    // ========================================
    
    initial begin
        // Display test header
        $display("--------------------------------------------------------");
        $display("Opcode |       A        |       B        |    Y Output    |   Expected    |  Result");
        $display("--------------------------------------------------------");

        // ========================================
        // TEST CASE 1: Basic Multiplication (MUL)
        // ========================================
        // Test simple multiplication with small numbers
        A = 64'd15;                    // First operand: 15
        B = 64'd10;                    // Second operand: 10
        opcode = 5'b01100;             // MUL operation code
        expected_full = A * B;         // Calculate expected 128-bit result
        expected_result = expected_full[63:0];  // Extract lower 64 bits
        op_name = "MUL";               // Operation name for display
        #10;                           // Wait for operation completion
        
        // Display result with pass/fail indication
        $display("%s  | %d | %d | %d | %d | %s", 
                 op_name, A, B, Y, expected_result, 
                 (Y == expected_result) ? "PASS" : "FAIL");

        // ========================================
        // TEST CASE 2: High-Precision Multiplication (MULHU)
        // ========================================
        // Test MULHU with maximum values to verify upper 64 bits
        A = 64'hFFFFFFFFFFFFFFFF;      // First operand: maximum 64-bit value
        B = 64'hFFFFFFFFFFFFFFFF;      // Second operand: maximum 64-bit value
        opcode = 5'b01111;             // MULHU operation code
        expected_full = A * B;         // Calculate expected 128-bit result
        expected_result = expected_full[127:64];  // Extract upper 64 bits
        op_name = "MULHU";             // Operation name for display
        #10;                           // Wait for operation completion
        
        // Display result with pass/fail indication (hex format for large values)
        $display("%s | %h | %h | %h | %h | %s", 
                 op_name, A, B, Y, expected_result, 
                 (Y == expected_result) ? "PASS" : "FAIL");

        // ========================================
        // TEST CASE 3: MULHU with Small Values
        // ========================================
        // Test MULHU with small numbers to verify upper bits are zero
        A = 64'd7;                     // First operand: 7
        B = 64'd6;                     // Second operand: 6
        opcode = 5'b01111;             // MULHU operation code
        expected_full = A * B;         // Calculate expected 128-bit result
        expected_result = expected_full[127:64];  // Extract upper 64 bits
        op_name = "MULHU";             // Operation name for display
        #10;                           // Wait for operation completion
        
        // Display result with pass/fail indication
        $display("%s | %d | %d | %d | %d | %s", 
                 op_name, A, B, Y, expected_result, 
                 (Y == expected_result) ? "PASS" : "FAIL");

        // ========================================
        // TEST CASE 4: MUL with Large Value
        // ========================================
        // Test MUL with large numbers to verify lower 64 bits
        A = 64'h100000000;             // First operand: 2^32
        B = 64'h00000002;              // Second operand: 2
        opcode = 5'b01100;             // MUL operation code
        expected_full = A * B;         // Calculate expected 128-bit result
        expected_result = expected_full[63:0];   // Extract lower 64 bits
        op_name = "MUL";               // Operation name for display
        #10;                           // Wait for operation completion
        
        // Display result with pass/fail indication (hex format for large values)
        $display("%s  | %h | %h | %h | %h | %s", 
                 op_name, A, B, Y, expected_result, 
                 (Y == expected_result) ? "PASS" : "FAIL");

        // ========================================
        // TEST COMPLETION
        // ========================================
        
        // End simulation after all tests complete
        $finish;
    end

endmodule
