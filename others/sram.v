// ***********************************************************************
// TITLE       : Adaptive Thresholding 
// AUTHOR      : Jiseon Kim 
// AFFILIATION : Dept. of CS, Sookmyung Women's University 
// DESCRIPTION : Designing 320x240 SRAM                  
// ***********************************************************************

`timescale 1 ns/1 ns
`define A_WIDTH 17
`define D_WIDTH 8

module Sram_Operand(Data_In, Data_Out, Addr, RW, En, Clk, Rst);

	input [(`A_WIDTH - 1):0] Addr;
	input RW;
	input En;
	input Clk;
	input Rst;
	input [(`D_WIDTH -1):0] Data_In;
	output reg[(`D_WIDTH-1):0] Data_Out;
	reg [(`D_WIDTH-1):0] Memory [0:(2**`A_WIDTH-1)];
	integer Index;

	always @(posedge Clk) begin
		Data_Out <= `D_WIDTH'b0;
		if (Rst==1) begin
			for(Index=0;Index<(2**`A_WIDTH);Index=Index+1)  
				Memory[Index] <= `D_WIDTH'b0;
		end
		else if (En==1'b1 && RW==1'b1) // write operation 
			Memory[Addr] <= Data_In;
		else if (En==1'b1 && RW==1'b0) // read operation 
			Data_Out <= Memory[Addr];
	end    
endmodule

