// ***********************************************************************
// TITLE       : Testbench Adaptive Thresholding
// AUTHOR      : Jiseon Kim 
// AFFILIATION : Dept. of CS, Sookmyung Women's University 
// DESCRIPTION : Testbench simulating Adaptive Thresholding with Gaussian               
// ***********************************************************************

`timescale 1 ns/1 ns

`define A_WIDTH 17
`define D_WIDTH 8
`define V_WIDTH 8

module Testbench();
	reg Go_s;
	wire[(`A_WIDTH-1):0] P_Addr_s, B_Addr_s;
	wire[(`D_WIDTH-1):0] P_Data_s, P_Di_s, B_Data_s;
	wire[(`V_WIDTH-1):0] T_Out_s;
	wire I_RW_s, I_En_s, O_RW_s, O_En_s, Done_s;
	reg Clk_s, Rst_t, Rst_p, Rst_b;

	parameter ClkPeriod = 20;

	Tresholding CompToTest(Go_s, P_Addr_s, P_Data_s, B_Addr_s, I_RW_s, I_En_s, O_RW_s, O_En_s, Done_s, T_Out_s, Clk_s, Rst_t);
	Sram_Operand MemP(P_Di_s, P_Data_s, P_Addr_s, I_RW_s, I_En_s, Clk_s, Rst_p);
	Sram_Operand MemB(T_Out_s, B_Data_s, B_Addr_s, O_RW_s, O_En_s, Clk_s, Rst_b);

	// Clock Procedure
	always begin
		Clk_s <= 1'b0; #(ClkPeriod/2);
		Clk_s <= 1'b1; #(ClkPeriod/2);
	end
	
	reg[(`D_WIDTH-1):0] Ref [0:(76800-1)];
	
	reg [17:0] Count;
	reg [16:0] correct, incorrect;

	//Initialize Arrays
	initial $readmemh("MemP.txt", MemP.Memory);
	initial $readmemh("sw_result.txt", Ref);

	//Vector Procedure
	initial begin
		Rst_t <= 1'b1; Rst_b <= 1'b1; Rst_p <= 1'b0;
		@(posedge Clk_s);
		Rst_t <= 1'b0; Rst_b <= 1'b0; Go_s <= 1'b1;
		@(posedge Clk_s);
		Go_s <= 1'b0;
		@(posedge Clk_s);
		while(Done_s != 1'b1)
			@(posedge Clk_s);
		
		correct <= 0; incorrect <= 0;
		@(posedge Clk_s);
		for(Count = 0;Count < 76800;Count = Count + 1)begin
			if(MemB.Memory[Count] == Ref[Count]) begin
				$display("%d. memB : %d and is equal to sw_result: %d", Count, MemB.Memory[Count], Ref[Count]);
				correct <= correct + 1;
			end	
			else begin
				$display("%d. FAIL!! memB : %d and is not equal to sw_result: %d", Count, MemB.Memory[Count], Ref[Count]);
				incorrect <= incorrect + 1;
			end
			@(posedge Clk_s);
		end
		$display("correct : %d, incorrect : %d", correct, incorrect);
		$stop;
	end
endmodule
