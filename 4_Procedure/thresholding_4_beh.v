// ***********************************************************************
// TITLE       : Adaptive Thresholding for 4-Procedure
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

module Tresholding_4(Go, P_Addr, P_Data, B_Addr, I_RW, I_En, O_RW, O_En, Done, T_Out, Clk, Rst);

	input Go;
	input [(`D_WIDTH-1):0] P_Data;
	output reg [(`A_WIDTH-1):0] P_Addr, B_Addr;
	output reg [(`V_WIDTH-1):0] T_Out;
	output reg I_RW, I_En, O_RW, O_En, Done;
	input Clk, Rst;

	parameter S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, 
		S4 = 4'b0100, S5 = 4'b0101, S6 = 4'b0110, S7 = 4'b0111, 
		S8 = 4'b1000, S9 = 4'b1001, S10 = 4'b1010, S11 = 4'b1011, 
		S12 = 4'b1100;

	reg [3:0] State;
	reg [16:0] Val;
	reg [4:0] G_Addr;
	reg [5:0] MaskGaussian [0:24]; 
	integer X, Y, I, J;

	//Next Regs
	reg [(`A_WIDTH-1):0] P_AddrNext, B_AddrNext;
	reg [4:0] G_AddrNext;
	reg [(`V_WIDTH-1):0] T_OutNext;
	reg [3:0] StateNext;
	reg [16:0] ValNext;
	integer XNext, YNext, INext, JNext;

	reg J_lt_SIZE, J_Inc, J_Clr;
	reg I_lt_SIZE, I_Inc, I_Clr;
	reg Y_lt_ROW, Y_Inc, Y_Clr;
	reg X_lt_COL, X_Inc, X_Clr;
	reg P_Addr_Ld, P_Addr_Clr, P_Addr_Mux;
	reg B_Addr_Ld, B_Addr_Clr;
	reg G_Addr_Ld, G_Addr_Clr;
	reg Val_Ld, Val_Clr, Val_Mux;
	reg T_Out_Ld, T_Out_Clr;
	reg All_lt_ROWCOL;

	initial begin
		MaskGaussian[0] <= 1;MaskGaussian[1] <= 4;MaskGaussian[2] <= 7;MaskGaussian[3] <= 4;MaskGaussian[4] <= 1;
		MaskGaussian[5] <= 4;MaskGaussian[6] <= 16;MaskGaussian[7] <= 26;MaskGaussian[8] <= 16;MaskGaussian[9] <= 4;
		MaskGaussian[10] <= 7;MaskGaussian[11] <= 26;MaskGaussian[12] <= 41;MaskGaussian[13] <= 26;MaskGaussian[14] <= 7;
		MaskGaussian[15] <= 4;MaskGaussian[16] <= 16;MaskGaussian[17] <= 26;MaskGaussian[18] <= 16;MaskGaussian[19] <= 4;
		MaskGaussian[20] <= 1;MaskGaussian[21] <= 4;MaskGaussian[22] <= 7;MaskGaussian[23] <= 4;MaskGaussian[24] <= 1;	
	end

	//Ctrl Regs
	always @(posedge Clk) begin
		if(Rst == 1'b1)
			State <= S0;
		else
			State <= StateNext;
	end
	
	//Ctrl CombLogic
	always @(State, Go, Y_lt_ROW, X_lt_COL, I_lt_SIZE, J_lt_SIZE, All_lt_ROWCOL) begin
		I_RW <= 1'b0; I_En <= 1'b0;
		O_RW <= 1'b0; O_En <= 1'b0;
		Done <= 1'b0;
		J_Inc <= 1'b0; J_Clr <= 1'b0;
		I_Inc <= 1'b0; I_Clr <= 1'b0;
		Y_Inc <= 1'b0; Y_Clr <= 1'b0;
		X_Inc <= 1'b0; X_Clr <= 1'b0;
		P_Addr_Ld <= 1'b0; P_Addr_Clr <= 1'b0; P_Addr_Mux <= 1'b0;
		B_Addr_Ld <= 1'b0; B_Addr_Clr <= 1'b0;
		G_Addr_Ld <= 1'b0; G_Addr_Clr <= 1'b0;
		Val_Ld <= 1'b0; Val_Clr <= 1'b0; Val_Mux <= 1'b0;
		T_Out_Ld <= 1'b0; T_Out_Clr <= 1'b0;
		
		case(State)
			S0: begin
				if (Go == 1'b1)
					StateNext <= S1;
				else
					StateNext <= S0;
			end
			S1: begin
				Y_Clr <= 1;
				StateNext <= S2;
			end
			S2: begin
				if (Y_lt_ROW) begin
					X_Clr <= 1;
					StateNext <= S3;
				end
				else
					StateNext <= S12;
			end
			S3: begin
				if (X_lt_COL) begin
					Val_Clr <= 1;
					I_Clr <= 1;
					StateNext <= S4;
				end
				else
					StateNext <= S11;
			end
			S4: begin
				if (I_lt_SIZE) begin
					J_Clr <= 1;
					StateNext <= S5;
				end
				else
					StateNext <= S9;
			end
			S5: begin
				if (J_lt_SIZE) begin
					P_Addr_Ld <= 1; P_Addr_Mux <= 0;
					I_RW <= 0;
					I_En <= 1;
					G_Addr_Ld <= 1;
					StateNext <= S6;
				end
				else
					StateNext <= S8;
			end
			S6: begin
				if (All_lt_ROWCOL) begin
					Val_Ld <= 1; Val_Mux <= 0;
				end
				StateNext <= S7;
			end
			S7: begin
				J_Inc <= 1;
				StateNext <= S5;
			end
			S8: begin
				I_Inc <= 1;
				StateNext <= S4;
			end
			S9: begin
				Val_Ld <= 1; Val_Mux <= 1;
				P_Addr_Ld <= 1; P_Addr_Mux <= 1;
				I_RW <= 0;
				I_En <= 1;
				StateNext <= S10;
			end
			S10: begin
				T_Out_Ld <= 1;
				B_Addr_Ld <= 1;
				O_RW <= 1;
				O_En <= 1;
				X_Inc <= 1;
				StateNext <= S3;
			end
			S11: begin
				Y_Inc <= 1; 
				StateNext <= S2;
			end
			S12: begin
				Done <= 1;
				StateNext <= S0;
			end
		endcase
	end

	//DP Regs
	always @(posedge Clk) begin
		if(Rst == 1'b1) begin
			P_Addr <= {`A_WIDTH{1'b0}};
			B_Addr <= {`A_WIDTH{1'b0}};
			G_Addr <= {5{1'b0}};
			Val <= 0;
			T_Out <= 17'b0;
			X <= 0;
			Y <= 0;
			I <= 0;
			J <= 0;
	
			ValNext <= 0;
			XNext <= 0;
			YNext <= 0;
			INext <= 0;
			JNext <= 0;
		end
		else begin
			Val <= ValNext;
			X <= XNext;
			Y <= YNext;
			I <= INext;
			J <= JNext;
		end
	end
	
	//DP CombLogic
	always @(X_Clr, Y_Clr,I_Clr,J_Clr,Val_Clr,
		P_Addr_Clr,B_Addr_Clr,G_Addr_Clr,T_Out_Clr,
		X_Inc,Y_Inc,I_Inc,J_Inc,
		P_Addr_Ld, P_Addr_Mux,G_Addr_Ld,B_Addr_Ld,Val_Ld,Val_Mux,T_Out_Ld) begin
	
		//Clr
		if(X_Clr)
			XNext <= 0;
		if(Y_Clr)
			YNext <= 0;
		if(I_Clr)
			INext <= -`SIZE;
		if(J_Clr)
			JNext <= -`SIZE;
		if(Val_Clr)
			ValNext <= 0;
		if(P_Addr_Clr)
			P_Addr <= 0;
		if(B_Addr_Clr)
			B_Addr <= 0;
		if(G_Addr_Clr)
			G_Addr <= 0;
		if(T_Out_Clr)
			T_OutNext <= 0;

		//Inc
		if(X_Inc)
			XNext <= X + 1;
		if(Y_Inc)
			YNext <= Y + 1;
		if(I_Inc)
			INext <= I + 1;
		if(J_Inc)
			JNext <= J + 1;
		
		//Ld
		if(P_Addr_Ld && ~P_Addr_Mux)
			P_Addr <= `COL*(Y+I)+(X+J);
		if(P_Addr_Ld && P_Addr_Mux)
			P_Addr <= Y*`COL + X;
		if(G_Addr_Ld)
			G_Addr <= (I+`SIZE)*`KSIZE + (J+`SIZE);
		if(B_Addr_Ld)
			B_Addr <= Y*`COL + X;
		if(Val_Ld && ~Val_Mux)
			ValNext <= Val + P_Data*MaskGaussian[G_Addr];
		if(Val_Ld && Val_Mux)
			ValNext <= Val/`SUM;
		if(T_Out_Ld)
			T_Out <= (P_Data < Val)? 255 : 0;
		//lt
		Y_lt_ROW <= (Y < `ROW)? 1:0;
		X_lt_COL <= (X < `COL)? 1:0;
		I_lt_SIZE <= (I <= `SIZE)? 1:0;
		J_lt_SIZE <= (J <= `SIZE)? 1:0;
		All_lt_ROWCOL <= (Y+I >= 0 && Y+I < `ROW && X+J >= 0 && X+J < `COL)? 1:0;
	end
endmodule
