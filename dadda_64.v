module dadda_64(A,B,mult_result);
    input [63:0]A;
    input [63:0]B;  
    output wire [127:0] mult_result;



//outputs of 16*16 dadda.      
    wire [63:0]y11,y12,y21,y22;

//sum and carry of final 2 stages.      
    wire [63:0]s_1,c_1; 
    wire [95:0]c_2;

// Instantiate 32x32 multipliers
    dadda_32 d1 (.A(A[31:0]),  .B(B[31:0]),  .mult_result(y11));
    dadda_32 d2 (.A(A[31:0]),  .B(B[63:32]), .mult_result(y12));
    dadda_32 d3 (.A(A[63:32]), .B(B[31:0]),  .mult_result(y21));
    dadda_32 d4 (.A(A[63:32]), .B(B[63:32]), .mult_result(y22));

// Assign least significant bits directly
    assign mult_result[31:0] = y11[31:0];

//Stage 1 - reducing fom 3 to 2
    genvar i;
    generate
        for (i = 1; i <= 63; i = i + 1) begin : stage1_csa
            if (i == 1) begin
                csa_dadda c_first (.A(y11[32]), .B(y12[0]), .Cin(y21[0]), .mult_result(s_1[0]), .Cout(c_1[0]));
                assign mult_result[32] = s_1[0];
            end else if (i <= 31) begin
                csa_dadda c_inst (
                    .A(y11[i + 32]),
                    .B(y12[i]),
                    .Cin(y21[i]),
                    .mult_result(s_1[i]),
                    .Cout(c_1[i])
                );
            end else begin
                csa_dadda c_inst (
                    .A(y22[i - 32]),
                    .B(y12[i]),
                    .Cin(y21[i]),
                    .mult_result(s_1[i]),
                    .Cout(c_1[i])
                );
            end
        end
    endgenerate

    // Stage 2 – 2:1 reduction using csa_dadda and 1 HA
    HA h1 (.a(s_1[1]), .b(c_1[0]), .Sum(mult_result[33]), .Cout(c_2[0]));

    generate
        for (i = 2; i <= 63; i = i + 1) begin : stage2_csa
            csa_dadda c_inst (
                .A(s_1[i]),
                .B(c_1[i - 1]),
                .Cin(c_2[i - 2]),
                .mult_result(mult_result[i + 32]),
                .Cout(c_2[i - 1])
            );
        end
    endgenerate

    // Final CSA + HAs to finish reduction
    csa_dadda c_last (.A(y22[32]), .B(c_1[63]), .Cin(c_2[62]), .mult_result(mult_result[95]), .Cout(c_2[63]));

    generate
        for (i = 0; i < 31; i = i + 1) begin : final_ha
            HA h_inst (
                .a(y22[i + 33]),
                .b(c_2[i + 63]),
                .Sum(mult_result[i + 96]),
                .Cout(c_2[i + 64])
            );
        end
    endgenerate

endmodule


module mult_output(  input [63:0]A,
    		     input [63:0]B,
		     input [4:0]opcode,        // Opcode to choose between mul, mulh, mulhu
    		     output reg  [63:0] Y
		    );
reg	[127:0]	temp_rez;
localparam mul = 5'b01100, mulhu = 5'b01111;
dadda_64	multiplier (A, B, temp_rez);


always @ (*) begin

	case(opcode)
    		mul: begin
    		        Y = temp_rez[63:0];   //Use the lower 32 bits of the Dadda multiplier's 64-bit result
    		end
		 
    	//	mulh: begin
    	//		Y = temp_rez[63:32];  // High signed multiplication result
    	//	end
    		mulhu: begin
    			Y = temp_rez[127:64];  // High unsigned multiplication result
    		end
		default: begin
    			Y = 64'b0;  // High unsigned multiplication result
		end
	endcase
end
endmodule


//***********************************************************************
module dadda_32(A,B,mult_result);
    input [31:0]A;
    input [31:0]B;  
    output wire [63:0] mult_result;



//outputs of 16*16 dadda.      
    wire [31:0]y11,y12,y21,y22;

//sum and carry of final 2 stages.      
    wire [31:0]s_1,c_1; 
    wire [46:0]c_2;
    dadda_16 d1(.A(A[15:0]),.B(B[15:0]),.mult_result(y11));
    assign mult_result[15:0] = y11[15:0];

    dadda_16 d2(.A(A[15:0]),.B(B[31:16]),.mult_result(y12));
    dadda_16 d3(.A(A[31:16]),.B(B[15:0]),.mult_result(y21));
    dadda_16 d4(.A(A[31:16]),.B(B[31:16]),.mult_result(y22));
    
    
//Stage 1 - reducing fom 3 to 2
    
    // Stage 1 – 3:2 reduction using csa_dadda
    genvar i;
    generate
        for (i = 1; i <= 31; i = i + 1) begin : stage1_csa
            if (i == 1) begin
                csa_dadda c_first (.A(y11[16]), .B(y12[0]), .Cin(y21[0]), .mult_result(s_1[0]), .Cout(c_1[0]));
                assign mult_result[16] = s_1[0];
            end else if (i <= 15) begin
                csa_dadda c_inst (
                    .A(y11[i + 16]),
                    .B(y12[i]),
                    .Cin(y21[i]),
                    .mult_result(s_1[i]),
                    .Cout(c_1[i])
                );
            end else begin
                csa_dadda c_inst (
                    .A(y22[i - 16]),
                    .B(y12[i]),
                    .Cin(y21[i]),
                    .mult_result(s_1[i]),
                    .Cout(c_1[i])
                );
            end
        end
    endgenerate

    // Stage 2 – 2:1 reduction using csa_dadda and 1 HA
    HA h1 (.a(s_1[1]), .b(c_1[0]), .Sum(mult_result[17]), .Cout(c_2[0]));

    generate
        for (i = 2; i <= 31; i = i + 1) begin : stage2_csa
            csa_dadda c_inst (
                .A(s_1[i]),
                .B(c_1[i - 1]),
                .Cin(c_2[i - 2]),
                .mult_result(mult_result[i + 16]),
                .Cout(c_2[i - 1])
            );
        end
    endgenerate

    // Final CSA + HAs to finish reduction
    csa_dadda c_last (.A(y22[16]), .B(c_1[31]), .Cin(c_2[30]), .mult_result(mult_result[48]), .Cout(c_2[31]));

    generate
        for (i = 0; i < 15; i = i + 1) begin : final_ha
            HA h_inst (
                .a(y22[i + 17]),
                .b(c_2[i + 31]),
                .Sum(mult_result[i + 49]),
                .Cout(c_2[i + 32])
            );
        end
    endgenerate

endmodule


// A - 16 bits , B - 16 bits, mult_result(output) - 32 bits
//Here we used 8*8 dadda to implement 16*16.

module dadda_16(A,B,mult_result);
      
    input [15:0]A;
    input [15:0]B;
    output wire [31:0] mult_result;
//outputs of 8*8 dadda.    
    wire [15:0]y11,y12,y21,y22;

//sum and carry of final 2 stages.     
    wire [15:0]s_1,c_1;    
    wire [22:0] c_2;
    
    dadda_8 d1(.A(A[7:0]),.B(B[7:0]),.y(y11));
    dadda_8 d2(.A(A[7:0]),.B(B[15:8]),.y(y12));
    dadda_8 d3(.A(A[15:8]),.B(B[7:0]),.y(y21));
    dadda_8 d4(.A(A[15:8]),.B(B[15:8]),.y(y22));
    assign mult_result[7:0] = y11[7:0];
    
//Stage 1 - reducing fom 3 to 2
    
    csa_dadda c_11(.A(y11[8]),.B(y12[0]),.Cin(y21[0]),.mult_result(s_1[0]),.Cout(c_1[0]));
    assign mult_result[8] = s_1[0];
    csa_dadda c_12(.A(y11[9]),.B(y12[1]),.Cin(y21[1]),.mult_result(s_1[1]),.Cout(c_1[1]));
    csa_dadda c_13(.A(y11[10]),.B(y12[2]),.Cin(y21[2]),.mult_result(s_1[2]),.Cout(c_1[2]));
    csa_dadda c_14(.A(y11[11]),.B(y12[3]),.Cin(y21[3]),.mult_result(s_1[3]),.Cout(c_1[3]));
    csa_dadda c_15(.A(y11[12]),.B(y12[4]),.Cin(y21[4]),.mult_result(s_1[4]),.Cout(c_1[4]));
    csa_dadda c_16(.A(y11[13]),.B(y12[5]),.Cin(y21[5]),.mult_result(s_1[5]),.Cout(c_1[5]));
    csa_dadda c_17(.A(y11[14]),.B(y12[6]),.Cin(y21[6]),.mult_result(s_1[6]),.Cout(c_1[6]));
    csa_dadda c_18(.A(y11[15]),.B(y12[7]),.Cin(y21[7]),.mult_result(s_1[7]),.Cout(c_1[7]));
    csa_dadda c_19(.A(y22[0]),.B(y12[8]),.Cin(y21[8]),.mult_result(s_1[8]),.Cout(c_1[8]));
    csa_dadda c_110(.A(y22[1]),.B(y12[9]),.Cin(y21[9]),.mult_result(s_1[9]),.Cout(c_1[9]));
    csa_dadda c_111(.A(y22[2]),.B(y12[10]),.Cin(y21[10]),.mult_result(s_1[10]),.Cout(c_1[10]));
    csa_dadda c_112(.A(y22[3]),.B(y12[11]),.Cin(y21[11]),.mult_result(s_1[11]),.Cout(c_1[11]));
    csa_dadda c_113(.A(y22[4]),.B(y12[12]),.Cin(y21[12]),.mult_result(s_1[12]),.Cout(c_1[12]));
    csa_dadda c_114(.A(y22[5]),.B(y12[13]),.Cin(y21[13]),.mult_result(s_1[13]),.Cout(c_1[13]));
    csa_dadda c_115(.A(y22[6]),.B(y12[14]),.Cin(y21[14]),.mult_result(s_1[14]),.Cout(c_1[14]));
    csa_dadda c_116(.A(y22[7]),.B(y12[15]),.Cin(y21[15]),.mult_result(s_1[15]),.Cout(c_1[15]));
    
//Stage 2 - reducing fom 2 to 1
        // adding total sum and carry to get final output
    HA h1(.a(s_1[1]),.b(c_1[0]),.Sum(mult_result[9]),.Cout(c_2[0]));


    csa_dadda c_22(.A(s_1[2]),.B(c_1[1]),.Cin(c_2[0]),.mult_result(mult_result[10]),.Cout(c_2[1]));
    csa_dadda c_23(.A(s_1[3]),.B(c_1[2]),.Cin(c_2[1]),.mult_result(mult_result[11]),.Cout(c_2[2]));
    csa_dadda c_24(.A(s_1[4]),.B(c_1[3]),.Cin(c_2[2]),.mult_result(mult_result[12]),.Cout(c_2[3]));
    csa_dadda c_25(.A(s_1[5]),.B(c_1[4]),.Cin(c_2[3]),.mult_result(mult_result[13]),.Cout(c_2[4]));
    csa_dadda c_26(.A(s_1[6]),.B(c_1[5]),.Cin(c_2[4]),.mult_result(mult_result[14]),.Cout(c_2[5]));
    csa_dadda c_27(.A(s_1[7]),.B(c_1[6]),.Cin(c_2[5]),.mult_result(mult_result[15]),.Cout(c_2[6]));
    csa_dadda c_28(.A(s_1[8]),.B(c_1[7]),.Cin(c_2[6]),.mult_result(mult_result[16]),.Cout(c_2[7]));
    csa_dadda c_29(.A(s_1[9]),.B(c_1[8]),.Cin(c_2[7]),.mult_result(mult_result[17]),.Cout(c_2[8]));
    csa_dadda c_210(.A(s_1[10]),.B(c_1[9]),.Cin(c_2[8]),.mult_result(mult_result[18]),.Cout(c_2[9]));
    csa_dadda c_211(.A(s_1[11]),.B(c_1[10]),.Cin(c_2[9]),.mult_result(mult_result[19]),.Cout(c_2[10]));
    csa_dadda c_212(.A(s_1[12]),.B(c_1[11]),.Cin(c_2[10]),.mult_result(mult_result[20]),.Cout(c_2[11]));
    csa_dadda c_213(.A(s_1[13]),.B(c_1[12]),.Cin(c_2[11]),.mult_result(mult_result[21]),.Cout(c_2[12]));
    csa_dadda c_214(.A(s_1[14]),.B(c_1[13]),.Cin(c_2[12]),.mult_result(mult_result[22]),.Cout(c_2[13]));
    csa_dadda c_215(.A(s_1[15]),.B(c_1[14]),.Cin(c_2[13]),.mult_result(mult_result[23]),.Cout(c_2[14]));
    csa_dadda c_216(.A(y22[8]),.B(c_1[15]),.Cin(c_2[14]),.mult_result(mult_result[24]),.Cout(c_2[15]));

    HA h2(.a(y22[9]),.b(c_2[15]),.Sum(mult_result[25]),.Cout(c_2[16]));
    HA h3(.a(y22[10]),.b(c_2[16]),.Sum(mult_result[26]),.Cout(c_2[17]));
    HA h4(.a(y22[11]),.b(c_2[17]),.Sum(mult_result[27]),.Cout(c_2[18]));
    HA h5(.a(y22[12]),.b(c_2[18]),.Sum(mult_result[28]),.Cout(c_2[19]));
    HA h6(.a(y22[13]),.b(c_2[19]),.Sum(mult_result[29]),.Cout(c_2[20]));
    HA h7(.a(y22[14]),.b(c_2[20]),.Sum(mult_result[30]),.Cout(c_2[21]));
    HA h8(.a(y22[15]),.b(c_2[21]),.Sum(mult_result[31]),.Cout(c_2[22]));
    
    
    
endmodule

//**********************************************************************************

// dadda multiplier
// A - 8 bits , B - 8bits, y(output) - 16bits

module dadda_8(A,B,y);
    
    input [7:0] A;
    input [7:0] B;
    output wire [15:0] y;
    wire  gen_pp [0:7][7:0];
// stage-1 sum and carry
    wire [0:5]s1,c1;
// stage-2 sum and carry
    wire [0:13]s2,c2;   
// stage-3 sum and carry
    wire [0:9]s3,c3;
// stage-4 sum and carry
    wire [0:11]s4,c4;
// stage-5 sum and carry
    wire [0:13]s5,c5;




// generating partial products 
genvar i;
genvar j;

for(i = 0; i<8; i=i+1)begin

   for(j = 0; j<8;j = j+1)begin
      assign gen_pp[i][j] = A[j]&B[i];
end
end

 

//Reduction by stages.
// di_values = 2,3,4,6,8,13...


//Stage 1 - reducing fom 8 to 6  


    HA h1(.a(gen_pp[6][0]),.b(gen_pp[5][1]),.Sum(s1[0]),.Cout(c1[0]));
    HA h2(.a(gen_pp[4][3]),.b(gen_pp[3][4]),.Sum(s1[2]),.Cout(c1[2]));
    HA h3(.a(gen_pp[4][4]),.b(gen_pp[3][5]),.Sum(s1[4]),.Cout(c1[4]));

    csa_dadda c11(.A(gen_pp[7][0]),.B(gen_pp[6][1]),.Cin(gen_pp[5][2]),.mult_result(s1[1]),.Cout(c1[1]));
    csa_dadda c12(.A(gen_pp[7][1]),.B(gen_pp[6][2]),.Cin(gen_pp[5][3]),.mult_result(s1[3]),.Cout(c1[3]));     
    csa_dadda c13(.A(gen_pp[7][2]),.B(gen_pp[6][3]),.Cin(gen_pp[5][4]),.mult_result(s1[5]),.Cout(c1[5]));
    
//Stage 2 - reducing fom 6 to 4

    HA h4(.a(gen_pp[4][0]),.b(gen_pp[3][1]),.Sum(s2[0]),.Cout(c2[0]));
    HA h5(.a(gen_pp[2][3]),.b(gen_pp[1][4]),.Sum(s2[2]),.Cout(c2[2]));


    csa_dadda c21(.A(gen_pp[5][0]),.B(gen_pp[4][1]),.Cin(gen_pp[3][2]),.mult_result(s2[1]),.Cout(c2[1]));
    csa_dadda c22(.A(s1[0]),.B(gen_pp[4][2]),.Cin(gen_pp[3][3]),.mult_result(s2[3]),.Cout(c2[3]));
    csa_dadda c23(.A(gen_pp[2][4]),.B(gen_pp[1][5]),.Cin(gen_pp[0][6]),.mult_result(s2[4]),.Cout(c2[4]));
    csa_dadda c24(.A(s1[1]),.B(s1[2]),.Cin(c1[0]),.mult_result(s2[5]),.Cout(c2[5]));
    csa_dadda c25(.A(gen_pp[2][5]),.B(gen_pp[1][6]),.Cin(gen_pp[0][7]),.mult_result(s2[6]),.Cout(c2[6]));
    csa_dadda c26(.A(s1[3]),.B(s1[4]),.Cin(c1[1]),.mult_result(s2[7]),.Cout(c2[7]));
    csa_dadda c27(.A(c1[2]),.B(gen_pp[2][6]),.Cin(gen_pp[1][7]),.mult_result(s2[8]),.Cout(c2[8]));
    csa_dadda c28(.A(s1[5]),.B(c1[3]),.Cin(c1[4]),.mult_result(s2[9]),.Cout(c2[9]));
    csa_dadda c29(.A(gen_pp[4][5]),.B(gen_pp[3][6]),.Cin(gen_pp[2][7]),.mult_result(s2[10]),.Cout(c2[10]));
    csa_dadda c210(.A(gen_pp[7][3]),.B(c1[5]),.Cin(gen_pp[6][4]),.mult_result(s2[11]),.Cout(c2[11]));
    csa_dadda c211(.A(gen_pp[5][5]),.B(gen_pp[4][6]),.Cin(gen_pp[3][7]),.mult_result(s2[12]),.Cout(c2[12]));
    csa_dadda c212(.A(gen_pp[7][4]),.B(gen_pp[6][5]),.Cin(gen_pp[5][6]),.mult_result(s2[13]),.Cout(c2[13]));
    
//Stage 3 - reducing fom 4 to 3

    HA h6(.a(gen_pp[3][0]),.b(gen_pp[2][1]),.Sum(s3[0]),.Cout(c3[0]));

    csa_dadda c31(.A(s2[0]),.B(gen_pp[2][2]),.Cin(gen_pp[1][3]),.mult_result(s3[1]),.Cout(c3[1]));
    csa_dadda c32(.A(s2[1]),.B(s2[2]),.Cin(c2[0]),.mult_result(s3[2]),.Cout(c3[2]));
    csa_dadda c33(.A(c2[1]),.B(c2[2]),.Cin(s2[3]),.mult_result(s3[3]),.Cout(c3[3]));
    csa_dadda c34(.A(c2[3]),.B(c2[4]),.Cin(s2[5]),.mult_result(s3[4]),.Cout(c3[4]));
    csa_dadda c35(.A(c2[5]),.B(c2[6]),.Cin(s2[7]),.mult_result(s3[5]),.Cout(c3[5]));
    csa_dadda c36(.A(c2[7]),.B(c2[8]),.Cin(s2[9]),.mult_result(s3[6]),.Cout(c3[6]));
    csa_dadda c37(.A(c2[9]),.B(c2[10]),.Cin(s2[11]),.mult_result(s3[7]),.Cout(c3[7]));
    csa_dadda c38(.A(c2[11]),.B(c2[12]),.Cin(s2[13]),.mult_result(s3[8]),.Cout(c3[8]));
    csa_dadda c39(.A(gen_pp[7][5]),.B(gen_pp[6][6]),.Cin(gen_pp[5][7]),.mult_result(s3[9]),.Cout(c3[9]));

//Stage 4 - reducing fom 3 to 2

    HA h7(.a(gen_pp[2][0]),.b(gen_pp[1][1]),.Sum(s4[0]),.Cout(c4[0]));


    csa_dadda c41(.A(s3[0]),.B(gen_pp[1][2]),.Cin(gen_pp[0][3]),.mult_result(s4[1]),.Cout(c4[1]));
    csa_dadda c42(.A(c3[0]),.B(s3[1]),.Cin(gen_pp[0][4]),.mult_result(s4[2]),.Cout(c4[2]));
    csa_dadda c43(.A(c3[1]),.B(s3[2]),.Cin(gen_pp[0][5]),.mult_result(s4[3]),.Cout(c4[3]));
    csa_dadda c44(.A(c3[2]),.B(s3[3]),.Cin(s2[4]),.mult_result(s4[4]),.Cout(c4[4]));
    csa_dadda c45(.A(c3[3]),.B(s3[4]),.Cin(s2[6]),.mult_result(s4[5]),.Cout(c4[5]));
    csa_dadda c46(.A(c3[4]),.B(s3[5]),.Cin(s2[8]),.mult_result(s4[6]),.Cout(c4[6]));
    csa_dadda c47(.A(c3[5]),.B(s3[6]),.Cin(s2[10]),.mult_result(s4[7]),.Cout(c4[7]));
    csa_dadda c48(.A(c3[6]),.B(s3[7]),.Cin(s2[12]),.mult_result(s4[8]),.Cout(c4[8]));
    csa_dadda c49(.A(c3[7]),.B(s3[8]),.Cin(gen_pp[4][7]),.mult_result(s4[9]),.Cout(c4[9]));
    csa_dadda c410(.A(c3[8]),.B(s3[9]),.Cin(c2[13]),.mult_result(s4[10]),.Cout(c4[10]));
    csa_dadda c411(.A(c3[9]),.B(gen_pp[7][6]),.Cin(gen_pp[6][7]),.mult_result(s4[11]),.Cout(c4[11]));
    
//Stage 5 - reducing fom 2 to 1
    // adding total sum and carry to get final output

    HA h8(.a(gen_pp[1][0]),.b(gen_pp[0][1]),.Sum(y[1]),.Cout(c5[0]));



    csa_dadda c51(.A(s4[0]),.B(gen_pp[0][2]),.Cin(c5[0]),.mult_result(y[2]),.Cout(c5[1]));
    csa_dadda c52(.A(c4[0]),.B(s4[1]),.Cin(c5[1]),.mult_result(y[3]),.Cout(c5[2]));
    csa_dadda c54(.A(c4[1]),.B(s4[2]),.Cin(c5[2]),.mult_result(y[4]),.Cout(c5[3]));
    csa_dadda c55(.A(c4[2]),.B(s4[3]),.Cin(c5[3]),.mult_result(y[5]),.Cout(c5[4]));
    csa_dadda c56(.A(c4[3]),.B(s4[4]),.Cin(c5[4]),.mult_result(y[6]),.Cout(c5[5]));
    csa_dadda c57(.A(c4[4]),.B(s4[5]),.Cin(c5[5]),.mult_result(y[7]),.Cout(c5[6]));
    csa_dadda c58(.A(c4[5]),.B(s4[6]),.Cin(c5[6]),.mult_result(y[8]),.Cout(c5[7]));
    csa_dadda c59(.A(c4[6]),.B(s4[7]),.Cin(c5[7]),.mult_result(y[9]),.Cout(c5[8]));
    csa_dadda c510(.A(c4[7]),.B(s4[8]),.Cin(c5[8]),.mult_result(y[10]),.Cout(c5[9]));
    csa_dadda c511(.A(c4[8]),.B(s4[9]),.Cin(c5[9]),.mult_result(y[11]),.Cout(c5[10]));
    csa_dadda c512(.A(c4[9]),.B(s4[10]),.Cin(c5[10]),.mult_result(y[12]),.Cout(c5[11]));
    csa_dadda c513(.A(c4[10]),.B(s4[11]),.Cin(c5[11]),.mult_result(y[13]),.Cout(c5[12]));
    csa_dadda c514(.A(c4[11]),.B(gen_pp[7][7]),.Cin(c5[12]),.mult_result(y[14]),.Cout(c5[13]));

    assign y[0] =  gen_pp[0][0];
    assign y[15] = c5[13];
    
  
    
endmodule 


//*********************************************************************************

// Designing in Half Adder 
// Sum = a XOR b, Cout = a AND b

/*
module HA(a, b, Sum, Cout);

input a, b; // a and b are inputs with size 1-bit
output Sum, Cout; // Sum and Cout are outputs with size 1-bit

assign Sum = a ^ b; 
assign Cout = a & b; 

endmodule
*/
module HA(
    input a, 
    input b, 
    output Sum, 
    output Cout
);

// Internal wires for gate outputs (optional but good for clarity)
wire xor_out;
wire and_out;

// XOR gate for Sum
xor u_xor(Sum, a, b);

// AND gate for Cout
and u_and(Cout, a, b);

endmodule

//**********************************************************************************

//carry save adder -- for implementing dadda multiplier
//csa for use of half adder and full adder.
/*
module csa_dadda(A,B,Cin,mult_result,Cout);
input A,B,Cin;
output mult_result,Cout;
    
assign mult_result = A^B^Cin;
assign Cout = (A&B)|(A&Cin)|(B&Cin);
    
endmodule
*/
module csa_dadda(
    input A,
    input B,
    input Cin,
    output mult_result,
    output Cout
);

// Internal wires for intermediate signals
wire xor_ab;
wire and_ab, and_aCin, and_bCin;

// XOR gates for sum

xor u_xor1(xor_ab, A, B);
xor u_xor2(mult_result, xor_ab, Cin);

// AND gates for carry
and u_and1(and_ab, A, B);
and u_and2(and_aCin, A, Cin);
and u_and3(and_bCin, B, Cin);

// OR gate for carry out
or  u_or(Cout, and_ab, and_aCin, and_bCin);

endmodule





