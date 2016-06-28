// ***********************************************************************
// TITLE       : Adaptive Thresholding
// AUTHOR      : Jiseon Kim 
// AFFILIATION : Dept. of CS, Sookmyung Women's University 
// DESCRIPTION : Designing Adaptive Thresholding with Gaussian ALgorithm                   
// ***********************************************************************

`timescale 1 ns/1 ns

`define A_WIDTH 17
`define D_WIDTH 8
`define V_WIDTH 8

`define KSIZE 5
`define SIZE 2
`define ROW 320
`define COL 240
`define SUM 256

module Tresholding(Go, P_Addr, P_Data, B_Addr, I_RW, I_En, O_RW, O_En, Done, T_Out, Clk, Rst);

	input Go;
	input [(`D_WIDTH-1):0] P_Data;
	output reg [(`A_WIDTH-1):0] P_Addr, B_Addr;
	output reg [(`V_WIDTH-1):0] T_Out;
	output reg I_RW, I_En, O_RW, O_En, Done;
	input Clk, Rst;

	parameter S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, 
		S4 = 4'b0100, S5 = 4'b0101, S6a = 4'b0110, S6 = 4'b0111, 
		S7 = 4'b1000, S8 = 4'b1001, S9 = 4'b1010, S10a = 4'b1011, 
		S10 = 4'b1100, S11 = 4'b1101, S12 = 4'b1110;

	reg [3:0] State;
	reg [16:0] Val;
	reg [4:0] G_Addr;
	reg [5:0] MaskGaussian [0:24]; 
	integer X, Y, I, J;

	initial begin
		MaskGaussian[0] <= 1;MaskGaussian[1] <= 4;MaskGaussian[2] <= 7;MaskGaussian[3] <= 4;MaskGaussian[4] <= 1;
		MaskGaussian[5] <= 4;MaskGaussian[6] <= 16;MaskGaussian[7] <= 26;MaskGaussian[8] <= 16;MaskGaussian[9] <= 4;
		MaskGaussian[10] <= 7;MaskGaussian[11] <= 26;MaskGaussian[12] <= 41;MaskGaussian[13] <= 26;MaskGaussian[14] <= 7;
		MaskGaussian[15] <= 4;MaskGaussian[16] <= 16;MaskGaussian[17] <= 26;MaskGaussian[18] <= 16;MaskGaussian[19] <= 4;
		MaskGaussian[20] <= 1;MaskGaussian[21] <= 4;MaskGaussian[22] <= 7;MaskGaussian[23] <= 4;MaskGaussian[24] <= 1;	
	end

	always @(posedge Clk) begin
		if(Rst == 1'b1) begin
			P_Addr <= {`A_WIDTH{1'b0}};
			B_Addr <= {`A_WIDTH{1'b0}};
			G_Addr <= {5{1'b0}};
			I_RW <= 1'b0;
			I_En <= 1'b0;
			O_RW <= 1'b0;
			O_En <= 1'b0;
			Done <= 1'b0;
			State <= S0;
			Val <= 0;
			T_Out <= 17'b0;
			X <= 0;
			Y <= 0;
			I <= 0;
			J <= 0;
		end
		else begin
			P_Addr <= {`A_WIDTH{1'b0}};
			B_Addr <= {`A_WIDTH{1'b0}};
			G_Addr <= {5{1'b0}};
			I_RW <= 1'b0;
			I_En <= 1'b0;
			O_RW <= 1'b0;
			O_En <= 1'b0;
			Done <= 1'b0;
			T_Out <= 17'b0;

			case(State)
				S0: begin
					if (Go == 1'b1)
						State <= S1;
					else
						State <= S0;
				end
				S1: begin
					Y <= 0;
					State <= S2;
				end
				S2: begin
					if (Y < `ROW) begin
						X <= 0;
						State <= S3;
					end
					else
						State <= S12;
				end
				S3: begin
					if (X < `COL) begin
						Val <= 0;
						I <= -`SIZE;
						State <= S4;
					end
					else
						State <= S11;
				end
				S4: begin
					if (I <= `SIZE) begin
						J <= -`SIZE;
						State <= S5;
					end
					else
						State <= S9;
				end
				S5: begin
					if (J <= `SIZE) begin
						P_Addr <= `COL*(Y+I)+(X+J);
						I_RW <= 0;
						I_En <= 1;
						State <= S6a;
					end
					else
						State <= S8;
				end
				S6a: begin
					G_Addr <= (I+`SIZE)*`KSIZE + (J+`SIZE);
					State <= S6;
				end
				S6: begin
					if (Y+I >= 0 && Y+I < `ROW && X+J >= 0 && X+J < `COL) begin
						Val <= Val + P_Data*MaskGaussian[G_Addr];
					end
					State <= S7;
				end
				S7: begin
					J <= J + 1;
					State <= S5;
				end
				S8: begin
					I <= I + 1;
					State <= S4;
				end
				S9: begin
					Val <= Val/`SUM;
					P_Addr <= Y*`COL + X;
					I_RW <= 0;
					I_En <= 1;
					State <= S10a;
				end
				S10a: begin
					State <= S10;
				end
				S10: begin
					T_Out <= (P_Data < Val)? 255 : 0;
					B_Addr <= Y*`COL + X;
					O_RW <= 1;
					O_En <= 1;
					X <= X + 1;
					State <= S3;
				end
				S11: begin
					Y <= Y + 1; 
					State <= S2;
				end
				S12: begin
					Done <= 1;
					State <= S0;
				end
			endcase
		end
	end

endmodule
