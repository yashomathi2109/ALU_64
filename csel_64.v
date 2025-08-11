/*
 * CSEL_64 - 64-Bit Carry Select Adder
 * 
 * This module implements a high-performance 64-bit carry select adder that computes
 * results for both carry-in scenarios (0 and 1) in parallel, then selects the correct
 * result based on the actual carry-in. This approach significantly reduces the critical
 * path compared to traditional ripple carry adders.
 * 
 * Architecture:
 * - Uses 4-bit Ripple Carry Adders (RCA4) as building blocks
 * - Computes results for carry-in = 0 and carry-in = 1 simultaneously
 * - Uses multiplexers to select the correct result based on previous stage carry
 * - Organized in 16 stages of 4-bit adders with carry selection
 * 
 * Key Benefits:
 * - Faster than ripple carry adders
 * - Parallel computation of carry scenarios
 * - Predictable timing characteristics
 * - Scalable architecture for different bit widths
 */

// ========================================
// FULL ADDER MODULE
// ========================================
// Basic 1-bit full adder with carry-in and carry-out
// Implements: Sum = A ⊕ B ⊕ Cin, Cout = (A&B) | (A&Cin) | (B&Cin)
module FA(output sum, cout, input a, b, cin);
  wire w0, w1, w2;  // Internal wires for intermediate signals
  
  // XOR gates for sum calculation
  xor (w0, a, b);      // w0 = a ⊕ b
  xor (sum, w0, cin);  // sum = w0 ⊕ cin = a ⊕ b ⊕ cin
  
  // AND gates for carry calculation
  and (w1, w0, cin);   // w1 = (a ⊕ b) & cin
  and (w2, a, b);      // w2 = a & b
  
  // OR gate for final carry out
  or (cout, w1, w2);   // cout = (a ⊕ b & cin) | (a & b)
endmodule

// ========================================
// 4-BIT RIPPLE CARRY ADDER MODULE
// ========================================
// 4-bit adder built from full adders with ripple carry propagation
// Each full adder waits for the carry from the previous stage
module RCA4(output [3:0] sum, output cout, input [3:0] a, b, input cin);
  
  wire [3:1] c;  // Internal carry signals between stages
  
  // First stage: full adder with external carry-in
  FA fa0(sum[0], c[1], a[0], b[0], cin);
  
  // Middle stages: full adders with carry from previous stage
  FA fa[2:1](sum[2:1], c[3:2], a[2:1], b[2:1], c[2:1]);
  
  // Last stage: full adder with final carry-out
  FA fa31(sum[3], cout, a[3], b[3], c[3]);
  
endmodule

// ========================================
// 2-TO-1 MULTIPLEXER MODULES
// ========================================
// 1-bit 2-to-1 multiplexer for carry selection
module MUX2to1_w1(output y, input i0, i1, s);
  wire e0, e1;  // Internal enable signals
  not (sn, s);  // Inverted select signal
  
  // AND gates for input selection
  and (e0, i0, sn);  // Enable i0 when s=0
  and (e1, i1, s);   // Enable i1 when s=1
  
  // OR gate for final output
  or (y, e0, e1);    // Select between enabled inputs
endmodule

// 4-bit 2-to-1 multiplexer for sum selection
module MUX2to1_w4(output [3:0] y, input [3:0] i0, i1, input s);
  wire [3:0] e0, e1;  // Internal enable signals for each bit
  not (sn, s);         // Inverted select signal
  
  // AND gates for each bit of input selection
  and (e0[0], i0[0], sn);  // Enable i0[0] when s=0
  and (e0[1], i0[1], sn);  // Enable i0[1] when s=0
  and (e0[2], i0[2], sn);  // Enable i0[2] when s=0
  and (e0[3], i0[3], sn);  // Enable i0[3] when s=0
      
  and (e1[0], i1[0], s);   // Enable i1[0] when s=1
  and (e1[1], i1[1], s);   // Enable i1[1] when s=1
  and (e1[2], i1[2], s);   // Enable i1[2] when s=1
  and (e1[3], i1[3], s);   // Enable i1[3] when s=1
  
  // OR gates for each bit of final output
  or (y[0], e0[0], e1[0]);  // Select between i0[0] and i1[0]
  or (y[1], e0[1], e1[1]);  // Select between i0[1] and i1[1]
  or (y[2], e0[2], e1[2]);  // Select between i0[2] and i1[2]
  or (y[3], e0[3], e1[3]);  // Select between i0[3] and i1[3]
endmodule

// ========================================
// 64-BIT CARRY SELECT ADDER MODULE
// ========================================
// Main carry select adder that combines 16 stages of 4-bit adders
// Each stage computes results for both carry-in scenarios in parallel
module CSelA64(output [63:0] sum, output cout, input [63:0] a, b);

  // Internal signals for parallel computation
  wire [63:0] sum0, sum1;    // Sum results for carry-in = 0 and 1
  wire [15:1] c;             // Carry signals between stages
  wire [15:0] cout0, cout1;  // Carry outputs for both scenarios

  // ========================================
  // STAGE 0: First 4-bit adder pair
  // ========================================
  // Compute results for bits 3:0 with both carry-in scenarios
  RCA4 rca0_0(sum0[3:0], cout0[0], a[3:0], b[3:0], 0);    // carry-in = 0
  RCA4 rca0_1(sum1[3:0], cout1[0], a[3:0], b[3:0], 1);    // carry-in = 1
  
  // Select correct sum and carry for stage 0
  // Since this is the first stage, we always use carry-in = 0
  MUX2to1_w4 mux0_sum(sum[3:0], sum0[3:0], sum1[3:0], 0);  // Always select sum0
  MUX2to1_w1 mux0_cout(c[1], cout0[0], cout1[0], 0);       // Always select cout0

  // ========================================
  // STAGES 1-14: Middle 4-bit adder pairs
  // ========================================
  // Generate 14 stages of 4-bit adders with parallel computation
  // Each stage computes both scenarios and selects based on previous carry
  RCA4 rca_other_0[14:1](sum0[59:4], cout0[14:1], a[59:4], b[59:4], 1'b0);   // carry-in = 0
  RCA4 rca_other_1[14:1](sum1[59:4], cout1[14:1], a[59:4], b[59:4], 1'b1);   // carry-in = 1
  
  // Select correct sums and carries based on previous stage carry
  MUX2to1_w4 mux_other_sum[14:1](sum[59:4], sum0[59:4], sum1[59:4], c[14:1]);  // Select based on c[14:1]
  MUX2to1_w1 mux_other_cout[14:1](c[15:2], cout0[14:1], cout1[14:1], c[14:1]); // Select based on c[14:1]

  // ========================================
  // STAGE 15: Last 4-bit adder pair
  // ========================================
  // Compute results for bits 63:60 with both carry-in scenarios
  RCA4 rca_last_0(sum0[63:60], cout0[15], a[63:60], b[63:60], 0);  // carry-in = 0
  RCA4 rca_last_1(sum1[63:60], cout1[15], a[63:60], b[63:60], 1);  // carry-in = 1
  
  // Select correct sum and carry for final stage
  MUX2to1_w4 mux_last_sum(sum[63:60], sum0[63:60], sum1[63:60], c[15]);  // Select based on c[15]
  MUX2to1_w1 mux_last_cout(cout, cout0[15], cout1[15], c[15]);           // Select based on c[15]

endmodule
