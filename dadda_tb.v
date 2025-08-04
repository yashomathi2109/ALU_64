`timescale 1ns/1ps

module mult_output_tb;

    // Inputs
    reg [63:0] A, B;
    reg [4:0] opcode;

    // Output
    wire [63:0] Y;

    // Instantiate the Unit Under Test (UUT)
    mult_output uut (
        .A(A),
        .B(B),
        .opcode(opcode),
        .Y(Y)
    );

    // Reference values
    reg [127:0] expected_full;
    reg [63:0] expected_result;
    string op_name;

    initial begin
        $display("--------------------------------------------------------");
        $display("Opcode |       A        |       B        |    Y Output    |   Expected    |  Result");
        $display("--------------------------------------------------------");

        // Test case 1: mul
        A = 64'd15;
        B = 64'd10;
        opcode = 5'b01100; // mul
        expected_full = A * B;
        expected_result = expected_full[63:0];
        op_name = "MUL";
        #10;
        $display("%s  | %d | %d | %d | %d | %s", op_name, A, B, Y, expected_result, (Y == expected_result) ? "PASS" : "FAIL");

        // Test case 2: mulhu
        A = 64'hFFFFFFFFFFFFFFFF;
        B = 64'hFFFFFFFFFFFFFFFF;
        opcode = 5'b01111; // mulhu
        expected_full = A * B;
        expected_result = expected_full[127:64];
        op_name = "MULHU";
        #10;
        $display("%s | %h | %h | %h | %h | %s", op_name, A, B, Y, expected_result, (Y == expected_result) ? "PASS" : "FAIL");

        // Test case 3: mulhu with small values
        A = 64'd7;
        B = 64'd6;
        opcode = 5'b01111; // mulhu
        expected_full = A * B;
        expected_result = expected_full[127:64];
        op_name = "MULHU";
        #10;
        $display("%s | %d | %d | %d | %d | %s", op_name, A, B, Y, expected_result, (Y == expected_result) ? "PASS" : "FAIL");

        // Test case 4: mul with large value
        A = 64'h100000000;
        B = 64'h00000002;
        opcode = 5'b01100; // mul
        expected_full = A * B;
        expected_result = expected_full[63:0];
        op_name = "MUL";
        #10;
        $display("%s  | %h | %h | %h | %h | %s", op_name, A, B, Y, expected_result, (Y == expected_result) ? "PASS" : "FAIL");

        $finish;
    end

endmodule
