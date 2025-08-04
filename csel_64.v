

// Full Adder
module FA(output sum, cout, input a, b, cin);
  wire w0, w1, w2;
  
  xor (w0, a, b);
  xor (sum, w0, cin);
  
  and (w1, w0, cin);
  and (w2, a, b);
  or (cout, w1, w2);
endmodule


// Ripple Carry Adder with cin - 4 bits
module RCA4(output [3:0] sum, output cout, input [3:0] a, b, input cin);
  
  wire [3:1] c;
  
  FA fa0(sum[0], c[1], a[0], b[0], cin);
  FA fa[2:1](sum[2:1], c[3:2], a[2:1], b[2:1], c[2:1]);
  FA fa31(sum[3], cout, a[3], b[3], c[3]);
  
endmodule

module MUX2to1_w1(output y, input i0, i1, s);

  wire e0, e1;
  not (sn, s);
  
  and (e0, i0, sn);
  and (e1, i1, s);
  
  or (y, e0, e1);
  
endmodule

module MUX2to1_w4(output [3:0] y, input [3:0] i0, i1, input s);

  wire [3:0] e0, e1;
  not (sn, s);
  
  and (e0[0], i0[0], sn);
  and (e0[1], i0[1], sn);
  and (e0[2], i0[2], sn);
  and (e0[3], i0[3], sn);
      
  and (e1[0], i1[0], s);
  and (e1[1], i1[1], s);
  and (e1[2], i1[2], s);
  and (e1[3], i1[3], s);
  
  or (y[0], e0[0], e1[0]);
  or (y[1], e0[1], e1[1]);
  or (y[2], e0[2], e1[2]);
  or (y[3], e0[3], e1[3]);
  
endmodule

// Carry Select Adder - 64 bits
module CSelA64(output [63:0] sum, output cout, input [63:0] a, b);

  wire [63:0] sum0, sum1;
  wire [15:1] c;
  wire [15:0] cout0, cout1;

  RCA4 rca0_0(sum0[3:0], cout0[0], a[3:0], b[3:0], 0);
  RCA4 rca0_1(sum1[3:0], cout1[0], a[3:0], b[3:0], 1);
  MUX2to1_w4 mux0_sum(sum[3:0], sum0[3:0], sum1[3:0], 0);
  MUX2to1_w1 mux0_cout(c[1], cout0[0], cout1[0], 0);

  RCA4 rca_other_0[14:1](sum0[59:4], cout0[14:1], a[59:4], b[59:4], 1'b0);
  RCA4 rca_other_1[14:1](sum1[59:4], cout1[14:1], a[59:4], b[59:4], 1'b1);
  MUX2to1_w4 mux_other_sum[14:1](sum[59:4], sum0[59:4], sum1[59:4], c[14:1]);
  MUX2to1_w1 mux_other_cout[14:1](c[15:2], cout0[14:1], cout1[14:1], c[14:1]);

  RCA4 rca_last_0(sum0[63:60], cout0[15], a[63:60], b[63:60], 0);
  RCA4 rca_last_1(sum1[63:60], cout1[15], a[63:60], b[63:60], 1);
  MUX2to1_w4 mux_last_sum(sum[63:60], sum0[63:60], sum1[63:60], c[15]);
  MUX2to1_w1 mux_last_cout(cout, cout0[15], cout1[15], c[15]);

endmodule
